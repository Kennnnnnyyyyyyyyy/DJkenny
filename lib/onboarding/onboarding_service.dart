import 'package:flutter/foundation.dart';
import '../data/onboarding_repo.dart';
import '../data/onboarding_track.dart';
import '../audio/player_controller.dart';
import 'choice_normalizers.dart';

/// Service that composes OnboardingRepo and PlayerController for track management
class OnboardingService {
  final OnboardingRepo _repo = OnboardingRepo();
  final PlayerController _player = PlayerController();

  /// New: Fetch a track based on UI choices WITHOUT auto-playing
  Future<OnboardingTrack?> findTrackFromChoices({
    required String moodUI,
    required String genreUI,
    required String topicUI,
  }) async {
    debugPrint('Finding track from choices (no autoplay): mood=$moodUI, genre=$genreUI, topic=$topicUI');

    final mood = normalizeMood(moodUI);
    final genre = normalizeGenre(genreUI);
    final topic = normalizeTopic(topicUI);

    if (!isValidPage3(mood, genre, topic)) {
      throw ArgumentError('Invalid combination: mood=$mood, genre=$genre, topic=$topic');
    }

    final track = await _repo.getPage3Track(mood: mood, genre: genre, topic: topic);
    if (track == null) {
      throw StateError('Track not found for mood=$mood, genre=$genre, topic=$topic');
    }
    return track;
  }

  /// Plays a track based on UI choice selections (legacy behavior)
  Future<OnboardingTrack?> playFromChoices({
    required String moodUI,
    required String genreUI,
    required String topicUI,
  }) async {
    debugPrint('Playing from choices: mood=$moodUI, genre=$genreUI, topic=$topicUI');

    // Normalize UI labels to DB keys
    final mood = normalizeMood(moodUI);
    final genre = normalizeGenre(genreUI);
    final topic = normalizeTopic(topicUI);

    debugPrint('Normalized: mood=$mood, genre=$genre, topic=$topic');

    // Validate combination
    if (!isValidPage3(mood, genre, topic)) {
      throw ArgumentError('Invalid combination: mood=$mood, genre=$genre, topic=$topic');
    }

    // Fetch track
    final track = await _repo.getPage3Track(
      mood: mood,
      genre: genre,
      topic: topic,
    );

    if (track == null) {
      throw StateError('Track not found for mood=$mood, genre=$genre, topic=$topic');
    }

    // Play track
    await _player.playUrl(track.publicUrl);
    debugPrint('Successfully playing track: ${track.title}');

    return track;
  }

  /// Loads all page 2 custom tracks
  Future<List<OnboardingTrack>> loadPage2Customs() async {
    debugPrint('Loading page 2 custom tracks');
    return await _repo.getPage2Tracks();
  }

  /// Plays a custom track
  Future<void> playCustom(OnboardingTrack track) async {
    debugPrint('Playing custom track: ${track.title}');
    await _player.playUrl(track.publicUrl);
  }

  /// Disposes the service and its resources
  void dispose() {
    debugPrint('Disposing OnboardingService');
    _player.dispose();
  }
}
