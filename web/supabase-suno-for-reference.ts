import { createClient } from "jsr:@supabase/supabase-js@2";
Deno.serve(async (req)=>{
  /* 1️⃣ -------- read payload coming from Flutter ---------- */ const { prompt, model, customMode = false, instrumental = false, style = '', title = '', negativeTags = '' } = await req.json();
  /* 2️⃣ -------- identify the caller via JWT --------------- */ const supa = createClient(Deno.env.get('SUPABASE_URL'), Deno.env.get('SUPABASE_ANON_KEY'), {
    global: {
      headers: {
        Authorization: req.headers.get('Authorization')
      }
    }
  });
  const { data: { user } } = await supa.auth.getUser();
  if (!user) return new Response('unauthenticated', {
    status: 401
  });
  /* 3️⃣ -------- build callback that tags the user --------- */ const callBackUrl = `https://mukyldpzbsmyifjftuix.supabase.co/functions/v1/suno-callback`;
  /* 4️⃣ -------- dispatch the job to Suno ------------------ */ const sunoRes = await fetch('https://api.sunoapi.org/api/v1/generate', {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      Authorization: `Bearer ${Deno.env.get('SUNO_API_KEY')}`
    },
    body: JSON.stringify({
      prompt,
      model,
      customMode,
      instrumental,
      style: customMode ? style : prompt,
      title,
      negativeTags,
      callBackUrl
    })
  });
  if (!sunoRes.ok) {
    const msg = await sunoRes.text();
    console.error('Suno error', msg);
    return new Response(`suno_error: ${msg}`, {
      status: 502
    });
  }
  const { task_id } = await sunoRes.json();
  const { error: insertError } = await supa.from('tracks').insert({
    task_id,
    user_id: user.id,
    status: 'processing',
    created_at: new Date().toISOString()
  });
  if (insertError) {
    console.error("Insert failed:", insertError);
  }
  /* 5️⃣ -------- hand task-id back to the app -------------- */ console.log("Returning queued response:", {
    task_id
  });
  return Response.json({
    success: true,
    message: "Song generation started!",
    status: "queued",
    task_id
  }, {
    status: 200
  });
});
