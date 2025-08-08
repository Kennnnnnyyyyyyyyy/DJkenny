import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Controller for audio playback using just_audio package
class PlayerController {
  final AudioPlayer _player = AudioPlayer();

  /// Plays audio from the given URL
  Future<void> playUrl(String url) async {
    try {
      debugPrint('Setting audio URL: $url');
      await _player.setUrl(url);
      debugPrint('Playing audio');
      await _player.play();
    } catch (e) {
      debugPrint('Error playing URL $url: $e');
      rethrow;
    }
  }

  /// Stops audio playback
  Future<void> stop() async {
    try {
      await _player.stop();
      debugPrint('Audio stopped');
    } catch (e) {
      debugPrint('Error stopping audio: $e');
      rethrow;
    }
  }

  /// Stream of player state changes
  Stream<PlayerState> get stateStream => _player.playerStateStream;

  /// Disposes the audio player
  void dispose() {
    debugPrint('Disposing PlayerController');
    _player.dispose();
  }
}
