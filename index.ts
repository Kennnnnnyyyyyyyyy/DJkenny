import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
const supabaseAdmin = createClient(Deno.env.get("SUPABASE_URL") ?? "", Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "");
// ---- helper --------------------------------------------------------------
const bad = (msg, extra = {})=>new Response(JSON.stringify({
    error: msg,
    extra
  }), {
    status: 400,
    headers: {
      "Content-Type": "application/json"
    }
  });
// --------------------------------------------------------------------------
serve(async (req)=>{
  try {
    if (req.method !== "POST") return new Response("Method Not Allowed", {
      status: 405
    });
    const payload = await req.json();
    console.log("↪︎ Suno callback:", JSON.stringify(payload).slice(0, 400), "...");
    // 1️⃣ top-level checks ---------------------------------------------------
    if (payload.code !== 200) return bad("Unexpected code from Suno", payload);
    const inner = payload.data;
    if (!inner || !Array.isArray(inner.data)) return bad("Missing track array in callback", inner);
    const taskId = inner.task_id ?? "unknown-task";
    const tracks = inner.data;
    if (tracks.length === 0) return bad("Track list empty", inner);
    // 2️⃣ iterate tracks ----------------------------------------------------
    const results = [];
    for (const t of tracks){
      const id = t.id ?? crypto.randomUUID();
      const url = t.audio_url || t.source_audio_url; // fallback key
      const title = (t.title ?? "untitled").replace(/[^a-zA-Z0-9]/g, "_").substring(0, 50);
      if (!url) {
        console.error("❌ no audio_url for", id);
        results.push({
          id,
          success: false,
          error: "audio_url missing"
        });
        continue;
      }
      // download -----------------------------------------------------------
      const r = await fetch(url);
      if (!r.ok) {
        console.error("❌ fetch failed", r.status, id);
        results.push({
          id,
          success: false,
          error: `fetch ${r.status}`
        });
        continue;
      }
      const blob = await r.blob();
      if (blob.size === 0) {
        results.push({
          id,
          success: false,
          error: "empty blob"
        });
        continue;
      }
      // upload -------------------------------------------------------------
      const filename = `${title}_${id}.mp3`;
      const { error: upErr } = await supabaseAdmin.storage.from("audiofiles").upload(filename, blob, {
        contentType: "audio/mpeg",
        upsert: true
      });
      if (upErr) {
        console.error("❌ upload failed", upErr);
        results.push({
          id,
          success: false,
          error: upErr.message
        });
        continue;
      }
      // public URL ---------------------------------------------------------
      const { data: { publicUrl } } = supabaseAdmin.storage.from("audiofiles").getPublicUrl(filename);
      // optional DB insert --------------------------------------------------
      await supabaseAdmin.from("songs").insert({
        task_id: taskId,
        track_id: id,
        title: t.title,
        model_name: t.model_name,
        public_url: publicUrl,
        duration: t.duration,
        created_at: new Date().toISOString()
      });
      results.push({
        id,
        success: true,
        publicUrl,
        duration: t.duration
      });
      console.log("✅ stored track", id);
    }
    return new Response(JSON.stringify({
      success: true,
      processed: results.length,
      results
    }), {
      headers: {
        "Content-Type": "application/json"
      }
    });
  } catch (e) {
    console.error("💥 callback handler crashed:", e);
    return new Response(JSON.stringify({
      error: e.message
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json"
      }
    });
  }
});
