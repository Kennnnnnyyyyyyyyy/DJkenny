import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL") ?? "", 
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
);

// Helper function for error responses
const bad = (msg, extra = {}) => new Response(JSON.stringify({
  error: msg,
  extra
}), {
  status: 400,
  headers: {
    "Content-Type": "application/json"
  }
});

serve(async (req) => {
  try {
    // Only accept POST requests
    if (req.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405 });
    }

    // Extract UID from URL parameters
    const url = new URL(req.url);
    const uid = url.searchParams.get('uid');
    
    if (!uid) {
      console.error("❌ Missing UID in callback URL:", req.url);
      return bad("Missing UID parameter in callback URL");
    }

    console.log(`✅ Callback received for user: ${uid}`);

    // Parse the payload from Suno
    const payload = await req.json();
    console.log("↪︎ Suno callback:", JSON.stringify(payload).slice(0, 400), "...");

    // Validate payload structure
    if (payload.code !== 200) {
      console.error("❌ Unexpected code from Suno:", payload.code);
      return bad("Unexpected code from Suno", payload);
    }

    const inner = payload.data;
    if (!inner || !Array.isArray(inner.data)) {
      console.error("❌ Missing track array in callback:", inner);
      return bad("Missing track array in callback", inner);
    }

    const taskId = inner.task_id ?? "unknown-task";
    const tracks = inner.data;
    
    if (tracks.length === 0) {
      console.error("❌ Empty track list:", inner);
      return bad("Track list empty", inner);
    }

    console.log(`🎵 Processing ${tracks.length} tracks for user ${uid}, task ${taskId}`);

    // Process each track
    const results = [];
    
    for (const t of tracks) {
      const id = t.id ?? crypto.randomUUID();
      const audioUrl = t.audio_url || t.source_audio_url;
      const title = (t.title ?? "untitled").replace(/[^a-zA-Z0-9\s\-_]/g, "").substring(0, 50);
      
      console.log(`📀 Processing track: ${id} - ${title}`);
      
      if (!audioUrl) {
        console.error("❌ No audio URL for track:", id);
        results.push({
          id,
          success: false,
          error: "audio_url missing"
        });
        continue;
      }

      try {
        // Download the audio file
        console.log(`📥 Downloading audio for track ${id}...`);
        const r = await fetch(audioUrl);
        
        if (!r.ok) {
          console.error(`❌ Download failed for track ${id}:`, r.status);
          results.push({
            id,
            success: false,
            error: `download_failed_${r.status}`
          });
          continue;
        }

        const blob = await r.blob();
        
        if (blob.size === 0) {
          console.error(`❌ Empty audio file for track ${id}`);
          results.push({
            id,
            success: false,
            error: "empty_audio_file"
          });
          continue;
        }

        console.log(`📁 Audio downloaded: ${blob.size} bytes`);

        // Create filename with user organization
        const timestamp = new Date().toISOString().slice(0, 19).replace(/[:-]/g, '');
        const sanitizedTitle = title.replace(/\s+/g, '_').toLowerCase();
        const filename = `${uid}/${timestamp}_${sanitizedTitle}_${id}.mp3`;
        
        // Upload to Supabase Storage
        console.log(`📤 Uploading to storage: ${filename}`);
        const { error: upErr } = await supabaseAdmin.storage
          .from("audiofiles")
          .upload(filename, blob, {
            contentType: "audio/mpeg",
            upsert: true
          });

        if (upErr) {
          console.error(`❌ Upload failed for track ${id}:`, upErr);
          results.push({
            id,
            success: false,
            error: `upload_failed: ${upErr.message}`
          });
          continue;
        }

        // Get public URL
        const { data: { publicUrl } } = supabaseAdmin.storage
          .from("audiofiles")
          .getPublicUrl(filename);

        // Insert into database with user_id
        console.log(`💾 Inserting track ${id} into database for user ${uid}...`);
        const { error: dbErr } = await supabaseAdmin
          .from("songs")
          .insert({
            id: id,
            user_id: uid,                    // Associate with user
            task_id: taskId,
            title: t.title || 'Untitled',
            public_url: publicUrl,
            model_name: t.model_name || 'unknown',
            duration: t.duration || 0,
            style: t.tags || '',
            instrumental: t.type === 'instrumental' || false,
            status: 'completed',
            created_at: new Date().toISOString()
          });

        if (dbErr) {
          console.error(`❌ Database insert failed for track ${id}:`, dbErr);
          results.push({
            id,
            success: false,
            error: `db_insert_failed: ${dbErr.message}`
          });
          continue;
        }

        // Success
        results.push({
          id,
          success: true,
          publicUrl,
          duration: t.duration,
          title: t.title
        });

        console.log(`✅ Track ${id} processed successfully for user ${uid}`);

      } catch (trackError) {
        console.error(`❌ Error processing track ${id}:`, trackError);
        results.push({
          id,
          success: false,
          error: `processing_error: ${trackError.message}`
        });
      }
    }

    // Calculate summary
    const successCount = results.filter(r => r.success).length;
    const failureCount = results.length - successCount;
    
    console.log(`📊 Callback complete for user ${uid}: ${successCount} successful, ${failureCount} failed`);

    // Return comprehensive response
    return new Response(JSON.stringify({
      success: true,
      user_id: uid,
      task_id: taskId,
      processed: results.length,
      successful: successCount,
      failed: failureCount,
      results
    }), {
      status: 200,
      headers: {
        "Content-Type": "application/json"
      }
    });

  } catch (error) {
    console.error("💥 Callback handler crashed:", error);
    
    return new Response(JSON.stringify({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json"
      }
    });
  }
});
