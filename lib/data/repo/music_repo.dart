import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../env.dart';
import '../models/song.dart';
import '../models/onboarding_track.dart';

class MusicRepo {
  final SupabaseClient _db;
  MusicRepo(this._db);

  Future<List<OnboardingTrackModel>> fetchOnboardingPage3() async {
    final rows = await _db
        .from('onboarding_tracks')
        .select()
        .eq('page_tag', 'page3')
        .order('list_index', ascending: true);
    return (rows as List)
        .map((e) => OnboardingTrackModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Song>> fetchExploreSongs({int limit = 30}) async {
    final rows = await _db
        .from('songs')
        .select()
        .order('inserted_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((e) => Song.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String?> generateCover({
    required String prompt,
    String style =
        'album cover, center composition, bold typography, high contrast',
    String model = 'runware:101@1',
    int width = 1024,
    int height = 1024,
    int steps = 30,
    int numberResults = 1,
    String? songId,
    String? trackId,
    String? pageTag,
    String? mood,
    String? genre,
    String? topic,
  }) async {
    final res = await http.post(
      Uri.parse(Env.swiftServiceUrl),
      headers: {
        'Authorization': 'Bearer ${Env.supabaseAnonKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': prompt,
        'style': style,
        'model': model,
        'width': width,
        'height': height,
        'steps': steps,
        'numberResults': numberResults,
        'song_id': songId,
        'track_id': trackId,
        'page_tag': pageTag,
        'mood': mood,
        'genre': genre,
        'topic': topic,
      }),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return j['imageUrl'] as String?;
    }
    throw Exception('swift-service failed: ${res.statusCode} ${res.body}');
  }

  Future<int> backfillSongCovers({
    int limit = 50,
    Duration throttle = const Duration(milliseconds: 600),
    String defaultStyle =
        'album cover, center composition, bold typography, clean vector, bright gradients, glossy shapes',
  }) async {
    final rows = await _db
        .from('songs')
        .select('id,title,prompt,cover_url')
        .isFilter('cover_url', null)
        .limit(limit);
    int ok = 0;
    for (final r in rows as List) {
      final id = r['id'] as String;
      final title = r['title'] as String? ?? 'Melo AI';
      final prompt = r['prompt'] as String? ?? title;
      try {
        final url = await generateCover(
          prompt: prompt,
          style: defaultStyle,
          songId: id,
        );
        if (url != null) ok++;
      } catch (_) {}
      await Future.delayed(throttle);
    }
    return ok;
  }
}
