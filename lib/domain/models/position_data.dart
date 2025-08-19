/// Model for audio playback position data
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const PositionData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });

  /// Progress as a value between 0.0 and 1.0
  double get progress {
    if (duration.inMilliseconds <= 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Buffered progress as a value between 0.0 and 1.0
  double get bufferedProgress {
    if (duration.inMilliseconds <= 0) return 0.0;
    return (bufferedPosition.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Remaining time
  Duration get remaining => duration - position;

  /// Format position as string (mm:ss)
  String get positionText => _formatDuration(position);

  /// Format duration as string (mm:ss)
  String get durationText => _formatDuration(duration);

  /// Format remaining time as string (mm:ss)
  String get remainingText => _formatDuration(remaining);

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Create a copy with updated values
  PositionData copyWith({
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
  }) {
    return PositionData(
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionData &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          bufferedPosition == other.bufferedPosition &&
          duration == other.duration;

  @override
  int get hashCode => position.hashCode ^ bufferedPosition.hashCode ^ duration.hashCode;

  @override
  String toString() {
    return 'PositionData(position: $positionText, duration: $durationText, progress: ${(progress * 100).toStringAsFixed(1)}%)';
  }

  /// Create empty/initial position data
  static const PositionData empty = PositionData(
    position: Duration.zero,
    bufferedPosition: Duration.zero,
    duration: Duration.zero,
  );
}
