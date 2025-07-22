// Updated Supabase Edge Function: suno-callback
// File: /supabase/functions/suno-callback/index.ts
//
// Required Environment Variables:
// - SUPABASE_URL
// - SUPABASE_SERVICE_ROLE_KEY
//
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL") ?? "", 
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
);

// ---- Helper Functions --------------------------------------------------------
const bad = (msg: string, extra = {}) => new Response(JSON.stringify({
  error: msg,
  extra
}), {
  status: 400,
  headers: {
    "Content-Type": "application/json"
  }
});

const logError = (message: string, data?: any) => {
  console.error(`❌ ${message}`, data ? JSON.stringify(data) : '');
};

const logSuccess = (message: string, data?: any) => {
  console.log(`✅ ${message}`, data ? JSON.stringify(data) : '');
};

// ---- Main Handler ------------------------------------------------------------
serve(async (req) => {
  try {
    // 🔒 Method validation
    if (req.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405 });
    }

    // 🔍 Extract UID from URL parameters
    const url = new URL(req.url);
    const uid = url.searchParams.get('uid');
    
    if (!uid) {
      logError("Missing UID in callback URL", { url: req.url });
      return bad("Missing UID parameter in callback URL");
    }

    logSuccess("Callback received", { uid, url: req.url });

    // 📨 Parse payload from Suno
    let payload;
    try {
      payload = await req.json();
    } catch (parseError) {
      logError("Failed to parse JSON payload", parseError);
      return bad("Invalid JSON payload");
    }

    console.log("↪︎ Suno callback payload:", JSON.stringify(payload).slice(0, 400), "...");

    // 🧪 Validate payload structure
    if (payload.code !== 200) {
      logError("Unexpected response code from Suno", payload);
      return bad("Unexpected code from Suno", payload);
    }

    const inner = payload.data;
    if (!inner || !Array.isArray(inner.data)) {
      logError("Missing or invalid track array in callback", inner);
      return bad("Missing track array in callback", inner);
    }

    const taskId = inner.task_id ?? "unknown-task";
    const tracks = inner.data;
    
    if (tracks.length === 0) {
      logError("Empty track list received", inner);
      return bad("Track list empty", inner);
    }

    logSuccess(`Processing ${tracks.length} tracks for user ${uid}`, { taskId });

    // 🎵 Process each track
    const results = [];
    
    for (let i = 0; i < tracks.length; i++) {
      const t = tracks[i];
      const trackId = t.id ?? crypto.randomUUID();
      
      console.log(`📀 Processing track ${i + 1}/${tracks.length}: ${trackId}`);
      
      try {
        // Validate track data
        const audioUrl = t.audio_url || t.source_audio_url;
        const title = (t.title ?? "untitled").replace(/[^a-zA-Z0-9\s\-_]/g, "").substring(0, 50);
        
        if (!audioUrl) {
          logError("Missing audio URL for track", { trackId, track: t });
          results.push({
            id: trackId,
            success: false,
            error: "audio_url missing"
          });
          continue;
        }

        // 📥 Download audio file from Suno
        console.log(`📥 Downloading audio for track ${trackId}...`);
        const downloadResponse = await fetch(audioUrl);
        
        if (!downloadResponse.ok) {
          logError(`Download failed for track ${trackId}`, { 
            status: downloadResponse.status, 
            statusText: downloadResponse.statusText 
          });
          results.push({
            id: trackId,
            success: false,
            error: `download_failed_${downloadResponse.status}`
          });
          continue;
        }

        const audioBlob = await downloadResponse.blob();
        
        if (audioBlob.size === 0) {
          logError(`Empty audio file for track ${trackId}`);
          results.push({
            id: trackId,
            success: false,
            error: "empty_audio_file"
          });
          continue;
        }

        console.log(`📁 Audio downloaded: ${audioBlob.size} bytes`);

        // 📤 Upload to Supabase Storage
        const timestamp = new Date().toISOString().slice(0, 19).replace(/[:-]/g, '');
        const sanitizedTitle = title.replace(/\s+/g, '_').toLowerCase();
        const filename = `${uid}/${timestamp}_${sanitizedTitle}_${trackId}.mp3`;
        
        console.log(`📤 Uploading to storage: ${filename}`);
        
        const { error: uploadError } = await supabaseAdmin.storage
          .from("audiofiles")
          .upload(filename, audioBlob, {
            contentType: "audio/mpeg",
            upsert: true
          });

        if (uploadError) {
          logError(`Upload failed for track ${trackId}`, uploadError);
          results.push({
            id: trackId,
            success: false,
            error: `upload_failed: ${uploadError.message}`
          });
          continue;
        }

        // 🔗 Get public URL
        const { data: { publicUrl } } = supabaseAdmin.storage
          .from("audiofiles")
          .getPublicUrl(filename);

        // 💾 Insert track record into database
        const dbRecord = {
          id: trackId,                    // Primary key
          user_id: uid,                   // 🎯 USER ID EXTRACTED FROM URL
          task_id: taskId,
          title: t.title || 'Untitled',
          public_url: publicUrl,
          model_name: t.model_name || 'unknown',
          duration: t.duration || 0,
          style: t.tags || '',
          instrumental: t.type === 'instrumental' || false,
          status: 'completed',
          created_at: new Date().toISOString()
        };

        console.log(`💾 Inserting into database for user ${uid}...`);
        
        const { error: dbError } = await supabaseAdmin
          .from("songs")
          .insert(dbRecord);

        if (dbError) {
          logError(`Database insert failed for track ${trackId}`, dbError);
          results.push({
            id: trackId,
            success: false,
            error: `db_insert_failed: ${dbError.message}`
          });
          continue;
        }

        // ✅ Success
        results.push({
          id: trackId,
          success: true,
          publicUrl,
          duration: t.duration,
          title: t.title
        });

        logSuccess(`Track processed successfully`, { trackId, uid, title: t.title });

      } catch (trackError) {
        logError(`Error processing track ${trackId}`, trackError);
        results.push({
          id: trackId,
          success: false,
          error: `processing_error: ${trackError.message}`
        });
      }
    }

    // 📊 Summary response
    const successCount = results.filter(r => r.success).length;
    const failureCount = results.length - successCount;
    
    logSuccess(`Callback processing complete`, {
      uid,
      taskId,
      total: results.length,
      successful: successCount,
      failed: failureCount
    });

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
    logError("Callback handler crashed", error);
    
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
