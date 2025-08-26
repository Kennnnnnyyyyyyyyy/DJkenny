import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiLyricsService {
  static const String _fnName = 'groq-lyrics';

  /// Ensures a Supabase session (anonymous is fine) and fetches lyrics via Edge Function.
  static Future<String> fetchRandomLyrics() async {
    final supa = Supabase.instance.client;
    if (supa.auth.currentSession == null) {
      await supa.auth.signInAnonymously();
    }

    final response = await supa.functions.invoke(_fnName, body: {});

    // Some SDK versions return a FunctionResponse with status/data only.
    if (response.status >= 400) {
      throw Exception('Edge Function HTTP ${response.status}: ${response.data}');
    }

    dynamic raw = response.data; // could be Map or String
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        // leave as string
      }
    }
    if (raw is! Map) {
      throw Exception('Unexpected response format: $raw');
    }
    var text = (raw['lyrics'] as String?)?.trim() ?? '';
    if (text.isEmpty) throw Exception('Empty lyrics from server');
    if (text.length < 10) throw Exception('Lyrics too short (<10 chars)');
    if (text.length > 500) text = text.substring(0, 500).trim();
    return text;
  }
}
