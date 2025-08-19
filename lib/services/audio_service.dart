import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../core/logging/logger.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/result.dart';
import '../audio/audio_session_helper.dart';

/// Service for managing audio playback using just_audio
class AudioService {
  late final AudioPlayer _player;
  late final AudioSession _session;
  bool _isInitialized = false;

  AudioService() {
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      _session = await AudioSession.instance;
      await _session.configure(const AudioSessionConfiguration.music());
      _isInitialized = true;
      Logger.audio('AudioService initialized successfully');
    } catch (e, st) {
      Logger.e('Failed to initialize AudioService', error: e, stackTrace: st, tag: 'AUDIO');
    }
  }

  /// Load audio from URL
  Future<Result<void>> load(String url) async {
    try {
      Logger.audio('Loading audio', metadata: {'url': url});
      
      // Ensure proper audio session before loading
      await ensurePlaybackSession();
      
      await _player.setUrl(url);
      Logger.audio('Audio loaded successfully');
      return Result.success(null);
    } catch (e, st) {
      Logger.e('Failed to load audio', error: e, stackTrace: st, tag: 'AUDIO');
      return Result.failure(AppException.audio('Failed to load audio: ${e.toString()}', cause: e, stackTrace: st));
    }
  }

  /// Play audio
  Future<Result<void>> play() async {
    try {
      Logger.audio('Playing audio');
      await _player.play();
      return Result.success(null);
    } catch (e, st) {
      Logger.e('Failed to play audio', error: e, stackTrace: st, tag: 'AUDIO');
      return Result.failure(AppException.audio('Failed to play audio: ${e.toString()}', cause: e, stackTrace: st));
    }
  }

  /// Pause audio
  Future<Result<void>> pause() async {
    try {
      Logger.audio('Pausing audio');
      await _player.pause();
      return Result.success(null);
    } catch (e, st) {
      Logger.e('Failed to pause audio', error: e, stackTrace: st, tag: 'AUDIO');
      return Result.failure(AppException.audio('Failed to pause audio: ${e.toString()}', cause: e, stackTrace: st));
    }
  }

  /// Seek to position
  Future<Result<void>> seek(Duration position) async {
    try {
      Logger.audio('Seeking to position', metadata: {'position': position.toString()});
      await _player.seek(position);
      return Result.success(null);
    } catch (e, st) {
      Logger.e('Failed to seek audio', error: e, stackTrace: st, tag: 'AUDIO');
      return Result.failure(AppException.audio('Failed to seek audio: ${e.toString()}', cause: e, stackTrace: st));
    }
  }

  /// Stop audio
  Future<Result<void>> stop() async {
    try {
      Logger.audio('Stopping audio');
      await _player.stop();
      return Result.success(null);
    } catch (e, st) {
      Logger.e('Failed to stop audio', error: e, stackTrace: st, tag: 'AUDIO');
      return Result.failure(AppException.audio('Failed to stop audio: ${e.toString()}', cause: e, stackTrace: st));
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<Result<void>> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      Logger.audio('Setting volume to: $clampedVolume');
      await _player.setVolume(clampedVolume);
      return Result.success(null);
    } catch (e, st) {
      Logger.e('Failed to set volume', error: e, stackTrace: st, tag: 'AUDIO');
      return Result.failure(AppException.audio('Failed to set volume: ${e.toString()}', cause: e, stackTrace: st));
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      Logger.audio('Disposing AudioService');
      await _player.dispose();
    } catch (e, st) {
      Logger.e('Error disposing AudioService', error: e, stackTrace: st, tag: 'AUDIO');
    }
  }

  // Stream getters for reactive UI
  
  /// Stream of current playback position
  Stream<Duration> get positionStream => _player.positionStream;

  /// Stream of total duration
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Stream of buffered position
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  /// Stream of playing state
  Stream<bool> get playingStream => _player.playingStream;

  /// Stream of player state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Stream of processing state
  Stream<ProcessingState> get processingStateStream => _player.processingStateStream;

  // Synchronous getters

  /// Current position
  Duration get position => _player.position;

  /// Total duration
  Duration? get duration => _player.duration;

  /// Current playing state
  bool get playing => _player.playing;

  /// Current processing state
  ProcessingState get processingState => _player.processingState;

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;
}
