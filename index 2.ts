// /supabase/functions/generate-track/index.ts
//
// Env vars required (set in Functions → Settings)
// ───────────────────────────────────────────────
// SUPABASE_URL
// SUPABASE_ANON_KEY
// SUPABASE_FUNCTIONS_URL       e.g. https://xyz.functions.supabase.co
// SUNO_API_KEY                 your secret Suno key
//
import { createClient } from 'npm:@supabase/supabase-js@2';
Deno.serve(async (req)=>{
  /* 1️⃣  -------- read payload coming from Flutter ---------- */ const { prompt, model, customMode = false, instrumental = false, style = '', title = '', negativeTags = '' } = await req.json();
  /* 2️⃣  -------- identify the caller via JWT --------------- */ const supa = createClient(Deno.env.get('SUPABASE_URL'), Deno.env.get('SUPABASE_ANON_KEY'), {
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
  /* 3️⃣  -------- build callback that tags the user --------- */ const callBackUrl = `${Deno.env.get('SUPABASE_FUNCTIONS_URL')}/suno-callback?uid=${user.id}`;
  /* 4️⃣  -------- dispatch the job to Suno ------------------ */ const sunoRes = await fetch('https://api.suno.ai/v1/generate', {
    method: 'POST',
    headers: {
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
  /* 5️⃣  -------- hand task-id back to the app -------------- */ return Response.json({
    status: 'queued',
    task_id
  }, {
    status: 202
  });
});
