Map<String, dynamic> buildSunoPayload({
  required String prompt,
  required String modelLabel,        // "Melo 3.5" | "Melo 4" | "Melo 4.5"
  required bool isCustomMode,
  required bool instrumentalToggle,  // switch value (ignored in custom)
  required String styleInput,        // textbox in custom, blank in simple
  String title = '',
  String negativeTags = '',
}) {
  const modelMap = {
    'Melo 3.5': 'V3_5',
    'Melo 4'  : 'V4_0',
    'Melo 4.5': 'V4_5',
  };

  return {
    'prompt'      : prompt,
    'style'       : isCustomMode ? styleInput : prompt,
    'title'       : title,
    'customMode'  : isCustomMode,
    'instrumental': isCustomMode ? false : instrumentalToggle,
    'model'       : modelMap[modelLabel] ?? 'V3_5',
    'negativeTags': negativeTags,
  };
}
