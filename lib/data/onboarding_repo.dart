import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bootstrap_supabase.dart';
import 'onboarding_track.dart';

/// Repository for fetching onboarding tracks from Supabase
class OnboardingRepo {
  /// Fetches a single page 3 track based on mood, genre, and topic
  Future<OnboardingTrack?> getPage3Track({
    required String mood,
    required String genre,
    required String topic,
  }) async {
    try {
      debugPrint('Fetching page3 track: mood=$mood, genre=$genre, topic=$topic');
      
      final response = await supabase
          .from('onboarding_tracks')
          .select()
          .eq('page_tag', 'page3')
          .eq('mood', mood)
          .eq('genre', genre)
          .eq('topic', topic)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        debugPrint('No track found for mood=$mood, genre=$genre, topic=$topic');
        return null;
      }

      final track = OnboardingTrack.fromMap(response);
      debugPrint('Found track: $track');
      return track;
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException in getPage3Track: ${e.message} (${e.code})');
      rethrow;
    } catch (e) {
      debugPrint('Error in getPage3Track: $e');
      rethrow;
    }
  }

  /// Fetches all page 2 tracks ordered by list_index
  Future<List<OnboardingTrack>> getPage2Tracks() async {
    try {
      debugPrint('Fetching page2 tracks');
      
      final response = await supabase
          .from('onboarding_tracks')
          .select()
          .eq('page_tag', 'page2')
          .order('list_index');

      final tracks = (response as List)
          .map((row) => OnboardingTrack.fromMap(row))
          .toList();

      debugPrint('Found ${tracks.length} page2 tracks');
      return tracks;
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException in getPage2Tracks: ${e.message} (${e.code})');
      rethrow;
    } catch (e) {
      debugPrint('Error in getPage2Tracks: $e');
      rethrow;
    }
  }

  /// Lists all tracks for a given page tag, ordered by list_index
  Future<List<OnboardingTrack>> listByPage(String pageTag) async {
    try {
      debugPrint('Fetching tracks for page: $pageTag');
      
      final response = await supabase
          .from('onboarding_tracks')
          .select()
          .eq('page_tag', pageTag)
          .order('list_index');

      final tracks = (response as List)
          .map((row) => OnboardingTrack.fromMap(row))
          .toList();

      debugPrint('Found ${tracks.length} tracks for page $pageTag');
      return tracks;
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException in listByPage: ${e.message} (${e.code})');
      rethrow;
    } catch (e) {
      debugPrint('Error in listByPage: $e');
      rethrow;
    }
  }
}
