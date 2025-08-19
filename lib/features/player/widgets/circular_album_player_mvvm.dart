import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logging/logger.dart';
import '../../../domain/models/track.dart';
import '../viewmodels/player_viewmodel.dart';

/// MVVM version of CircularAlbumPlayer using PlayerViewModel
class CircularAlbumPlayerMVVM extends ConsumerStatefulWidget {
  final Track track;
  final VoidCallback? onFinished;
  final VoidCallback? onContinue;

  const CircularAlbumPlayerMVVM({
    super.key,
    required this.track,
    this.onFinished,
    this.onContinue,
  });

  @override
  ConsumerState<CircularAlbumPlayerMVVM> createState() => _CircularAlbumPlayerMVVMState();
}

class _CircularAlbumPlayerMVVMState extends ConsumerState<CircularAlbumPlayerMVVM> {
  @override
  void initState() {
    super.initState();
    Logger.d('Initializing CircularAlbumPlayerMVVM for track: ${widget.track.title}', tag: 'PLAYER_UI');
    
    // Load the track when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerViewModelProvider.notifier).loadTrack(widget.track);
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerViewModelProvider);
    final playerVM = ref.read(playerViewModelProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Album Art with Progress Ring
          _buildAlbumArtWithProgress(playerState, playerVM),
          
          const SizedBox(height: 24),
          
          // Track Info
          _buildTrackInfo(),
          
          const SizedBox(height: 16),
          
          // Time Display
          _buildTimeDisplay(playerState),
          
          const SizedBox(height: 24),
          
          // Controls
          _buildControls(playerState, playerVM),
          
          // Continue Button (if provided)
          if (widget.onContinue != null) ...[
            const SizedBox(height: 24),
            _buildContinueButton(),
          ],
          
          // Error Display
          if (playerState.error != null)
            _buildErrorDisplay(playerState, playerVM),
        ],
      ),
    );
  }

  Widget _buildAlbumArtWithProgress(PlayerState state, PlayerViewModel vm) {
    const size = 240.0;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress Ring
          CustomPaint(
            size: const Size(size, size),
            painter: _ProgressRingPainter(
              progress: state.positionData.progress,
              bufferedProgress: state.positionData.bufferedProgress,
            ),
          ),
          
          // Album Art
          Container(
            width: size - 20,
            height: size - 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: widget.track.coverUrl?.isNotEmpty == true
                  ? CachedNetworkImage(
                      imageUrl: widget.track.coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildPlaceholderArt(),
                      errorWidget: (context, url, error) => _buildPlaceholderArt(),
                    )
                  : _buildPlaceholderArt(),
            ),
          ),
          
          // Seek Gesture Detector
          GestureDetector(
            onPanUpdate: (details) => _handleSeekGesture(details, vm, size),
            child: Container(
              width: size,
              height: size,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderArt() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.music_note,
        color: Colors.white,
        size: 64,
      ),
    );
  }

  Widget _buildTrackInfo() {
    return Column(
      children: [
        Text(
          widget.track.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Melo AI',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDisplay(PlayerState state) {
    final position = state.positionData.positionText;
    final duration = state.positionData.durationText;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          position,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          duration,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildControls(PlayerState state, PlayerViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Skip Backward 5 seconds
        _buildControlButton(
          icon: Icons.replay_5,
          onPressed: state.canPlay ? () => vm.skipBackward() : null,
        ),
        
        // Play/Pause
        _buildControlButton(
          icon: state.isLoading 
              ? Icons.hourglass_empty
              : state.isPlaying 
                  ? Icons.pause 
                  : Icons.play_arrow,
          onPressed: state.isLoading ? null : () => vm.togglePlayPause(),
          size: 56,
        ),
        
        // Skip Forward 5 seconds
        _buildControlButton(
          icon: Icons.forward_5,
          onPressed: state.canPlay ? () => vm.skipForward() : null,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onPressed,
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: onPressed != null ? Colors.white : Colors.white.withOpacity(0.5),
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ElevatedButton(
        onPressed: widget.onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDisplay(PlayerState state, PlayerViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            state.error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => vm.clearError(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _handleSeekGesture(DragUpdateDetails details, PlayerViewModel vm, double size) {
    final center = Offset(size / 2, size / 2);
    final position = details.localPosition - center;
    final angle = atan2(position.dy, position.dx);
    final normalizedAngle = (angle + pi) / (2 * pi);
    
    final playerState = ref.read(playerViewModelProvider);
    final duration = playerState.positionData.duration;
    
    if (duration.inMilliseconds > 0) {
      final seekPosition = Duration(
        milliseconds: (normalizedAngle * duration.inMilliseconds).round(),
      );
      vm.seek(seekPosition);
      Logger.d('Seek gesture: angle=$normalizedAngle, position=${seekPosition.inSeconds}s', tag: 'PLAYER_UI');
    }
  }
}

/// Custom painter for the progress ring
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double bufferedProgress;

  _ProgressRingPainter({
    required this.progress,
    required this.bufferedProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const strokeWidth = 4.0;

    // Background ring
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Buffered progress ring
    if (bufferedProgress > 0) {
      final bufferedPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * bufferedProgress,
        false,
        bufferedPaint,
      );
    }

    // Progress ring
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
