import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreCover {
  final String id;
  final String title;
  final String? coverUrl;
  final String? audioUrl;
  final String? mood;
  final String? genre;
  final String? topic;
  final int listIndex;

  const ExploreCover({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.audioUrl,
    required this.mood,
    required this.genre,
    required this.topic,
    required this.listIndex,
  });

  factory ExploreCover.fromMap(Map<String, dynamic> m) => ExploreCover(
        id: m['id'] as String,
        title: (m['title'] ?? '${m['mood']} ${m['genre']} · ${m['topic']}') as String,
        coverUrl: m['cover_url'] as String?,
        audioUrl: m['public_url'] as String?,
        mood: m['mood'] as String?,
        genre: m['genre'] as String?,
        topic: m['topic'] as String?,
        listIndex: (m['list_index'] as num).toInt(),
      );
}

class ExploreService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ExploreCover>> fetchOnboardingCovers({int limit = 36}) async {
    final rows = await _client
        .from('onboarding_tracks')
        .select('id,title,public_url,cover_url,mood,genre,topic,list_index,created_at')
        .eq('page_tag', 'page3')
        .order('list_index', ascending: true)
        .limit(limit);

    final list = (rows as List)
        .map((e) => ExploreCover.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
    return list;
  }
}
