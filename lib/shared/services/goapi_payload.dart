// GoAPI Payload Builder Service
// This service builds the payload structure required for GoAPI requests

Map<String, dynamic> buildGoApiPayload({
  required String prompt,
  required String modelLabel,
  required bool isCustomMode,
  required bool instrumentalToggle,
  required String styleInput,
  String title = '',
  String negativeTags = '',
}) {
  // Determine the style prompt
  String stylePrompt = 'pop'; // Default style
  
  if (isCustomMode && styleInput.isNotEmpty) {
    stylePrompt = styleInput;
  } else if (!isCustomMode) {
    // For simple mode, we could map modelLabel to a style
    // For now, using default 'pop'
    stylePrompt = 'pop';
  }

  return {
    "model": "Qubico/diffrhythm",
    "task_type": "txt2audio-base",
    "input": {
      "lyrics": instrumentalToggle ? "" : prompt,
      "style_prompt": stylePrompt,
      "style_audio": ""
    },
    "config": {
      "webhook_config": {
        "endpoint": "https://your-supabase-project.supabase.co/functions/v1/goapi-callback",
        "secret": "your-optional-hmac-secret"
      }
    }
  };
}
