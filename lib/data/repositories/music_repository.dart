import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/logging/logger.dart';
import '../../domain/models/track.dart';
import '../models/onboarding_track.dart';
import '../models/song.dart';

/// Repository for music-related data operations
class MusicRepository {
  final SupabaseClient supabase;

  MusicRepository({required this.supabase});

  /// Find track based on user choices during onboarding
  Future<Result<Track>> findTrackFromChoices({
    String? mood,
    String? genre, 
    String? subject,
  }) async {
    try {
      Logger.network('Finding track from choices: mood=$mood, genre=$genre, subject=$subject');

      var query = supabase
          .from('onboarding_tracks')
          .select()
          .eq('page_tag', 'page3');

      // Apply filters based on user choices
      if (mood != null && mood.isNotEmpty) {
        query = query.ilike('mood', '%$mood%');
      }
      if (genre != null && genre.isNotEmpty) {
        query = query.ilike('genre', '%$genre%');
      }
      if (subject != null && subject.isNotEmpty) {
        query = query.ilike('topic', '%$subject%');
      }

      final response = await query.limit(1);

      if (response.isEmpty) {
        Logger.w('No track found for choices', tag: 'MUSIC_REPO');
        return Result.failure(AppException.notFound('No track matched your choices'));
      }

      final trackData = response.first;
      final track = Track.fromOnboardingTrack(OnboardingTrackModel.fromJson(trackData));
      
      Logger.network('Track found successfully: ${track.id} - ${track.title}');

      return Result.success(track);
    } catch (e, st) {
      Logger.e('Failed to find track from choices', error: e, stackTrace: st, tag: 'MUSIC_REPO');
      return Result.failure(AppException.from(e, st));
    }
  }

  /// Fetch onboarding tracks for a specific page
  Future<Result<List<OnboardingTrackModel>>> fetchOnboardingTracks(String pageTag) async {
    try {
      Logger.network('Fetching onboarding tracks for: $pageTag');

      final response = await supabase
          .from('onboarding_tracks')
          .select()
          .eq('page_tag', pageTag)
          .order('list_index', ascending: true);

      final tracks = (response as List)
          .map((e) => OnboardingTrackModel.fromJson(e as Map<String, dynamic>))
          .toList();

      Logger.network('Onboarding tracks fetched successfully: ${tracks.length} tracks for $pageTag');

      return Result.success(tracks);
    } catch (e, st) {
      Logger.e('Failed to fetch onboarding tracks', error: e, stackTrace: st, tag: 'MUSIC_REPO');
      return Result.failure(AppException.from(e, st));
    }
  }

  /// Fetch explore songs
  Future<Result<List<Song>>> fetchExploreSongs({int limit = 30}) async {
    try {
      Logger.network('Fetching explore songs with limit: $limit');

      final response = await supabase
          .from('songs')
          .select()
          .order('inserted_at', ascending: false)
          .limit(limit);

      final songs = (response as List)
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList();

      Logger.network('Explore songs fetched successfully: ${songs.length} songs');

      return Result.success(songs);
    } catch (e, st) {
      Logger.e('Failed to fetch explore songs', error: e, stackTrace: st, tag: 'MUSIC_REPO');
      return Result.failure(AppException.from(e, st));
    }
  }

  /// Generate cover art for a track
  Future<Result<String>> generateCoverArt({
    required String prompt,
    String? trackId,
    String? mood,
    String? genre,
    String? topic,
  }) async {
    try {
      Logger.network('Generating cover art: $prompt (trackId: $trackId)');

      // TODO: Implement cover art generation
      // This would call your existing cover generation logic
      // For now, return a placeholder
      
      return Result.failure(AppException.server('Cover art generation not implemented yet'));
    } catch (e, st) {
      Logger.e('Failed to generate cover art', error: e, stackTrace: st, tag: 'MUSIC_REPO');
      return Result.failure(AppException.from(e, st));
    }
  }

  /// Ensure cover exists for a track
  Future<Result<String?>> ensureCoverForTrack(
    String trackId, {
    String? mood,
    String? genre,
    String? topic,
    required String pageTag,
  }) async {
    try {
      Logger.network('Ensuring cover for track: $trackId (pageTag: $pageTag)');

      // TODO: Implement cover checking and generation logic
      // This would check if cover exists and generate if needed
      
      return Result.success(null);
    } catch (e, st) {
      Logger.e('Failed to ensure cover for track', error: e, stackTrace: st, tag: 'MUSIC_REPO');
      return Result.failure(AppException.from(e, st));
    }
  }
}
