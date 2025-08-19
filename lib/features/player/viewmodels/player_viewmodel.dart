import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/logging/logger.dart';
import '../../../domain/models/position_data.dart';
import '../../../domain/models/track.dart';
import '../../../services/audio_service.dart';
import '../../../app/di.dart';

/// State for the audio player
class PlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Track? currentTrack;
  final PositionData positionData;
  final ProcessingState processingState;
  final String? error;
  final double volume;
  final bool isFavorite;

  const PlayerState({
    required this.isPlaying,
    required this.isLoading,
    this.currentTrack,
    required this.positionData,
    required this.processingState,
    this.error,
    required this.volume,
    required this.isFavorite,
  });

  /// Initial state
  factory PlayerState.initial() => const PlayerState(
        isPlaying: false,
        isLoading: false,
        currentTrack: null,
        positionData: PositionData.empty,
        processingState: ProcessingState.idle,
        error: null,
        volume: 1.0,
        isFavorite: false,
      );

  /// Create a copy with updated values
  PlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Track? currentTrack,
    PositionData? positionData,
    ProcessingState? processingState,
    String? error,
    double? volume,
    bool? isFavorite,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentTrack: currentTrack ?? this.currentTrack,
      positionData: positionData ?? this.positionData,
      processingState: processingState ?? this.processingState,
      error: error,
      volume: volume ?? this.volume,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Clear error
  PlayerState clearError() => copyWith(error: null);

  /// Whether the player can play
  bool get canPlay => currentTrack != null && processingState != ProcessingState.loading;

  /// Whether the player is ready
  bool get isReady => processingState == ProcessingState.ready;

  /// Whether the player has completed
  bool get isCompleted => processingState == ProcessingState.completed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerState &&
          runtimeType == other.runtimeType &&
          isPlaying == other.isPlaying &&
          isLoading == other.isLoading &&
          currentTrack == other.currentTrack &&
          positionData == other.positionData &&
          processingState == other.processingState &&
          error == other.error &&
          volume == other.volume &&
          isFavorite == other.isFavorite;

  @override
  int get hashCode =>
      isPlaying.hashCode ^
      isLoading.hashCode ^
      currentTrack.hashCode ^
      positionData.hashCode ^
      processingState.hashCode ^
      error.hashCode ^
      volume.hashCode ^
      isFavorite.hashCode;

  @override
  String toString() {
    return 'PlayerState(isPlaying: $isPlaying, track: ${currentTrack?.title}, state: $processingState, error: $error)';
  }
}

/// ViewModel for audio player functionality
class PlayerViewModel extends StateNotifier<PlayerState> {
  final AudioService _audioService;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _bufferedSubscription;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<ProcessingState>? _processingStateSubscription;

  PlayerViewModel(this._audioService) : super(PlayerState.initial()) {
    _initializeStreams();
  }

  void _initializeStreams() {
    Logger.d('Initializing player streams', tag: 'PLAYER_VM');

    // Listen to position changes
    _positionSubscription = _audioService.positionStream.listen((position) {
      _updatePositionData(position: position);
    });

    // Listen to duration changes
    _durationSubscription = _audioService.durationStream.listen((duration) {
      _updatePositionData(duration: duration ?? Duration.zero);
    });

    // Listen to buffered position changes
    _bufferedSubscription = _audioService.bufferedPositionStream.listen((buffered) {
      _updatePositionData(bufferedPosition: buffered);
    });

    // Listen to playing state changes
    _playingSubscription = _audioService.playingStream.listen((isPlaying) {
      Logger.audio('Playing state changed: $isPlaying');
      state = state.copyWith(isPlaying: isPlaying);
    });

    // Listen to processing state changes
    _processingStateSubscription = _audioService.processingStateStream.listen((processingState) {
      Logger.audio('Processing state changed: $processingState');
      state = state.copyWith(processingState: processingState);
    });
  }

  void _updatePositionData({
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
  }) {
    final currentPosition = position ?? state.positionData.position;
    final currentDuration = duration ?? state.positionData.duration;
    final currentBuffered = bufferedPosition ?? state.positionData.bufferedPosition;

    final newPositionData = PositionData(
      position: currentPosition,
      duration: currentDuration,
      bufferedPosition: currentBuffered,
    );

    state = state.copyWith(positionData: newPositionData);
  }

  /// Load and play a track
  Future<void> loadTrack(Track track) async {
    try {
      Logger.audio('Loading track: ${track.title}');
      state = state.copyWith(
        isLoading: true,
        currentTrack: track,
        error: null,
      );

      final result = await _audioService.load(track.audioUrl);
      result.fold(
        (error) {
          Logger.e('Failed to load track', error: error, tag: 'PLAYER_VM');
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
        },
        (_) {
          Logger.audio('Track loaded successfully: ${track.title}');
          state = state.copyWith(isLoading: false);
        },
      );
    } catch (e, st) {
      Logger.e('Unexpected error loading track', error: e, stackTrace: st, tag: 'PLAYER_VM');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load track: ${e.toString()}',
      );
    }
  }

  /// Play the current track
  Future<void> play() async {
    if (!state.canPlay) {
      Logger.w('Cannot play: no track loaded or not ready', tag: 'PLAYER_VM');
      return;
    }

    final result = await _audioService.play();
    result.fold(
      (error) {
        Logger.e('Failed to play', error: error, tag: 'PLAYER_VM');
        state = state.copyWith(error: error.message);
      },
      (_) => Logger.audio('Started playing'),
    );
  }

  /// Pause the current track
  Future<void> pause() async {
    final result = await _audioService.pause();
    result.fold(
      (error) {
        Logger.e('Failed to pause', error: error, tag: 'PLAYER_VM');
        state = state.copyWith(error: error.message);
      },
      (_) => Logger.audio('Paused playback'),
    );
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    final maxDuration = state.positionData.duration;
    final clampedPosition = position < Duration.zero 
        ? Duration.zero 
        : position > maxDuration 
            ? maxDuration 
            : position;
    Logger.audio('Seeking to position: ${clampedPosition.inSeconds}s');

    final result = await _audioService.seek(clampedPosition);
    result.fold(
      (error) {
        Logger.e('Failed to seek', error: error, tag: 'PLAYER_VM');
        state = state.copyWith(error: error.message);
      },
      (_) => Logger.audio('Seeked to: ${clampedPosition.inSeconds}s'),
    );
  }

  /// Skip forward by specified duration (default 5 seconds)
  Future<void> skipForward([Duration duration = const Duration(seconds: 5)]) async {
    final currentPosition = state.positionData.position;
    final newPosition = currentPosition + duration;
    await seek(newPosition);
  }

  /// Skip backward by specified duration (default 5 seconds)
  Future<void> skipBackward([Duration duration = const Duration(seconds: 5)]) async {
    final currentPosition = state.positionData.position;
    final newPosition = currentPosition - duration;
    await seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  /// Stop playback
  Future<void> stop() async {
    final result = await _audioService.stop();
    result.fold(
      (error) {
        Logger.e('Failed to stop', error: error, tag: 'PLAYER_VM');
        state = state.copyWith(error: error.message);
      },
      (_) {
        Logger.audio('Stopped playback');
        state = state.copyWith(
          isPlaying: false,
          positionData: PositionData.empty,
        );
      },
    );
  }

  /// Clear any error state
  void clearError() {
    state = state.clearError();
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    Logger.audio('Setting volume to: $clampedVolume');
    
    final result = await _audioService.setVolume(clampedVolume);
    result.fold(
      (error) {
        Logger.e('Failed to set volume', error: error, tag: 'PLAYER_VM');
        state = state.copyWith(error: error.message);
      },
      (_) {
        state = state.copyWith(volume: clampedVolume);
        Logger.audio('Volume set to: $clampedVolume');
      },
    );
  }

  /// Toggle favorite status for current track
  void toggleFavorite() {
    if (state.currentTrack != null) {
      final newFavoriteStatus = !state.isFavorite;
      state = state.copyWith(isFavorite: newFavoriteStatus);
      Logger.d('Track favorite status changed to: $newFavoriteStatus', tag: 'PLAYER_VM');
      
      // TODO: Persist favorite status to local storage or backend
      // This could be integrated with a FavoritesRepository later
    }
  }

  @override
  void dispose() {
    Logger.d('Disposing PlayerViewModel', tag: 'PLAYER_VM');
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferedSubscription?.cancel();
    _playingSubscription?.cancel();
    _processingStateSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for PlayerViewModel
final playerViewModelProvider = StateNotifierProvider.autoDispose<PlayerViewModel, PlayerState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return PlayerViewModel(audioService);
});
