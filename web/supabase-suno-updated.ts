import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  try {
    /* 1️⃣ -------- Read payload coming from Flutter ---------- */
    const payload = await req.json();
    console.log('📥 Received payload:', payload);
    
    // Extract user metadata from payload (separate from Suno parameters)
    const { 
      user_id: payloadUserId, 
      user_metadata,
      // Suno API parameters
      prompt, 
      model, 
      customMode = false, 
      instrumental = false, 
      style = '', 
      title = '', 
      negativeTags = '' 
    } = payload;

    /* 2️⃣ -------- Identify the caller via JWT --------------- */
    const supa = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      {
        global: {
          headers: {
            Authorization: req.headers.get('Authorization')
          }
        }
      }
    );

    const { data: { user } } = await supa.auth.getUser();
    if (!user) {
      return new Response('unauthenticated', { status: 401 });
    }

    /* 3️⃣ -------- Validate user ID consistency --------------- */
    const jwtUserId = user.id;
    console.log('🔍 User ID validation:');
    console.log('   JWT User ID:', jwtUserId);
    console.log('   Payload User ID:', payloadUserId);
    
    // Use JWT user ID as the authoritative source, but log if there's a mismatch
    if (payloadUserId && payloadUserId !== jwtUserId) {
      console.warn('⚠️  User ID mismatch! Using JWT user ID for security.');
    }

    const authorizedUserId = jwtUserId; // Always use JWT-derived user ID

    /* 4️⃣ -------- Build clean Suno API payload -------------- */
    const sunoApiPayload = {
      prompt,
      model,
      customMode,
      instrumental,
      style: customMode ? style : prompt,
      title,
      negativeTags,
      callBackUrl: `https://mukyldpzbsmyifjftuix.supabase.co/functions/v1/suno-callback`
    };

    console.log('🎵 Suno API Payload (clean):', sunoApiPayload);

    /* 5️⃣ -------- Dispatch the job to Suno ------------------ */
    const sunoRes = await fetch('https://api.sunoapi.org/api/v1/generate', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        Authorization: `Bearer ${Deno.env.get('SUNO_API_KEY')}`
      },
      body: JSON.stringify(sunoApiPayload) // Clean payload without user_id
    });

    if (!sunoRes.ok) {
      const msg = await sunoRes.text();
      console.error('❌ Suno API error:', msg);
      return new Response(`suno_error: ${msg}`, { status: 502 });
    }

    const sunoResponse = await sunoRes.json();
    const task_id = sunoResponse.data.taskId; // Fixed: Use correct field name from Suno response
    console.log('✅ Suno API Response - Task ID:', task_id);

    /* 6️⃣ -------- Store initial record in database with user ID ------------ */
    const { error: insertError } = await supa
      .from('songs')
      .insert({
        task_id,
        user_id: authorizedUserId, // Use JWT-derived user ID
        status: 'processing',
        title: title || 'Untitled',
        // Initialize fields that will be updated by callback
        public_url: null,
        duration: null,
        track_id: null,
        model_name: null,
        likes: 0,
        plays: 0,
        created_at: new Date().toISOString()
      });

    if (insertError) {
      console.error("❌ Database insert failed:", insertError);
      return new Response(`database_error: ${insertError.message}`, { status: 500 });
    }

    console.log('✅ Database record created for user:', authorizedUserId);

    /* 7️⃣ -------- Return success response to Flutter ------- */
    const response = {
      success: true,
      message: "Song generation started!",
      status: "queued",
      task_id,
      user_id: authorizedUserId
    };

    console.log("✅ Returning response:", response);
    return Response.json(response, { status: 200 });

  } catch (error) {
    console.error('❌ Edge Function error:', error);
    return new Response(`server_error: ${error.message}`, { status: 500 });
  }
});
