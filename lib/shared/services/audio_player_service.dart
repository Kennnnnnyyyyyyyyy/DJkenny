import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentTrackId;

  // Getters for streams
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  
  // Current state getters
  PlayerState get playerState => _audioPlayer.playerState;
  Duration? get duration => _audioPlayer.duration;
  Duration get position => _audioPlayer.position;
  bool get isPlaying => _audioPlayer.playing;
  String? get currentTrackId => _currentTrackId;

  /// Play a track from URL
  Future<void> playTrack(String trackId, String audioUrl) async {
    try {
      // Validate and clean the audio URL
      if (audioUrl.isEmpty) {
        throw Exception('Audio URL is empty');
      }

      // If same track is playing, just toggle play/pause
      if (_currentTrackId == trackId && _audioPlayer.playerState.playing) {
        await pause();
        return;
      }

      // Clean and validate URL
      String cleanUrl = audioUrl.trim();
      
      // Handle different URL formats
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        throw Exception('Invalid URL format: $cleanUrl');
      }

      if (kDebugMode) {
        debugPrint('🎵 Attempting to play: $cleanUrl');
      }

      // If different track or stopped, load and play new track
      if (_currentTrackId != trackId) {
        _currentTrackId = trackId;
        
        try {
          // For Supabase signed URLs, use the simple setUrl method which works better with query parameters
          if (cleanUrl.contains('supabase.co') && cleanUrl.contains('token=')) {
            if (kDebugMode) {
              debugPrint('🎵 Detected Supabase signed URL, using setUrl method');
            }
            await _audioPlayer.setUrl(cleanUrl);
          } else {
            // For other URLs, try ProgressiveAudioSource with headers
            final uri = Uri.parse(cleanUrl);
            await _audioPlayer.setAudioSource(
              ProgressiveAudioSource(
                uri,
                headers: {
                  'User-Agent': 'Mozilla/5.0 (compatible; MusicApp/1.0)',
                  'Accept': 'audio/*,*/*;q=0.9',
                },
              ),
              preload: true,
            );
          }
          
          if (kDebugMode) {
            debugPrint('🎵 Audio source loaded successfully');
          }
        } catch (sourceError) {
          if (kDebugMode) {
            debugPrint('❌ Primary audio source method failed: $sourceError');
            debugPrint('❌ Trying fallback setUrl method');
          }
          
          // Fallback to basic setUrl for all cases
          await _audioPlayer.setUrl(cleanUrl);
        }
      }

      await _audioPlayer.play();
      
      if (kDebugMode) {
        debugPrint('🎵 Successfully playing track: $trackId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error playing track $trackId: $e');
        debugPrint('❌ URL was: $audioUrl');
      }
      
      // Clear current track on error
      _currentTrackId = null;
      rethrow;
    }
  }

  /// Pause current playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      if (kDebugMode) {
        debugPrint('⏸️ Paused playback');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error pausing: $e');
      }
    }
  }

  /// Resume current playback
  Future<void> resume() async {
    try {
      await _audioPlayer.play();
      if (kDebugMode) {
        debugPrint('▶️ Resumed playback');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error resuming: $e');
      }
    }
  }

  /// Stop current playback
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _currentTrackId = null;
      if (kDebugMode) {
        debugPrint('⏹️ Stopped playback');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error stopping: $e');
      }
    }
  }

  /// Seek to specific position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      if (kDebugMode) {
        debugPrint('⏭️ Seeked to: ${position.inSeconds}s');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error seeking: $e');
      }
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error setting volume: $e');
      }
    }
  }

  /// Check if a specific track is currently playing
  bool isTrackPlaying(String trackId) {
    return _currentTrackId == trackId && _audioPlayer.playerState.playing;
  }

  /// Check if a specific track is currently loaded (playing or paused)
  bool isTrackLoaded(String trackId) {
    return _currentTrackId == trackId;
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _currentTrackId = null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing audio player: $e');
      }
    }
  }
}
