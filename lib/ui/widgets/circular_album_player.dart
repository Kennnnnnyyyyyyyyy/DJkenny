import 'dart:async';
import 'dart:math';
import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class PositionData {
  final Duration position;
  final Duration buffered;
  final Duration? duration;
  const PositionData(this.position, this.buffered, this.duration);
}

class CircularAlbumPlayer extends StatefulWidget {
  final String title;
  final String subtitle;
  final String audioUrl;
  final String coverUrl;
  final Duration? initialPos;
  final VoidCallback? onFinished;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;

  const CircularAlbumPlayer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.audioUrl,
    required this.coverUrl,
    this.initialPos,
    this.onFinished,
    this.onNext,
    this.onPrev,
  });

  @override
  State<CircularAlbumPlayer> createState() => _CircularAlbumPlayerState();
}

class _CircularAlbumPlayerState extends State<CircularAlbumPlayer> with WidgetsBindingObserver {
  final AudioPlayer _player = AudioPlayer();
  late final Stream<PositionData> _posStream;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
    _posStream = Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      _player.positionStream,
      _player.bufferedPositionStream,
      _player.durationStream,
      (p, b, d) => PositionData(p, b, d),
    ).asBroadcastStream();
  }

  Future<void> _setup() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _player.setUrl(widget.audioUrl);
      if (widget.initialPos != null) {
        await _player.seek(widget.initialPos);
      }
      setState(() => _loading = false);
      // Auto-play once loaded
      unawaited(_player.play());
      _player.playbackEventStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          widget.onFinished?.call();
        }
      }, onError: (_) {
        setState(() => _hasError = true);
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
      debugPrint('CircularAlbumPlayer error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  void _seekPercent(double p) {
    final d = _player.duration;
    if (d == null) return;
    final targetMs = (d.inMilliseconds * p.clamp(0.0, 1.0)).round();
    final target = Duration(milliseconds: targetMs);
    _player.seek(target);
  }

  @override
  Widget build(BuildContext context) {
    final processing = _player.processingState;
    final canControl = !_loading && !_hasError && processing != ProcessingState.loading && processing != ProcessingState.buffering;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Manrope'), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(widget.subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontFamily: 'Manrope')), 

              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: StreamBuilder<PositionData>(
                    stream: _posStream,
                    builder: (context, snap) {
                      final position = snap.data?.position ?? Duration.zero;
                      final buffered = snap.data?.buffered ?? Duration.zero;
                      final duration = snap.data?.duration ?? _player.duration;
                      final dMs = duration?.inMilliseconds ?? 1;
                      final p = (position.inMilliseconds / dMs).clamp(0.0, 1.0);
                      final b = (buffered.inMilliseconds / dMs).clamp(0.0, 1.0);

                      return SizedBox(
                        width: 280,
                        height: 280,
                        child: _RingSeekBar(
                          progress: p,
                          buffered: b,
                          strokeWidth: 10,
                          onSeekPercent: canControl ? _seekPercent : null,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: widget.coverUrl,
                              fit: BoxFit.cover,
                              width: 240,
                              height: 240,
                              errorWidget: (_, __, ___) => Container(color: Colors.white10, child: const Icon(Icons.music_note, color: Colors.white70, size: 48)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),
              StreamBuilder<PositionData>(
                stream: _posStream,
                builder: (context, snap) {
                  final pos = snap.data?.position ?? Duration.zero;
                  final dur = snap.data?.duration ?? _player.duration ?? Duration.zero;
                  String fmt(Duration d) {
                    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
                    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
                    return '$m:$s';
                  }
                  final remaining = dur - pos;
                  return Text('${fmt(pos)} • ${fmt(remaining)}', style: const TextStyle(color: Colors.white70, fontFamily: 'Manrope'));
                },
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: canControl ? widget.onPrev : null,
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    iconSize: 30,
                  ),
                  const SizedBox(width: 24),
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snap) {
                      final playing = snap.data?.playing ?? _player.playing;
                      final isLoading = _loading || _hasError || _player.processingState == ProcessingState.loading || _player.processingState == ProcessingState.buffering;
                      return SizedBox(
                        width: 72,
                        height: 72,
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : InkResponse(
                                onTap: canControl
                                    ? () async {
                                        if (playing) {
                                          await _player.pause();
                                        } else {
                                          await _player.play();
                                        }
                                      }
                                    : null,
                                radius: 40,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 150),
                                  child: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled, key: ValueKey(playing), color: Colors.white, size: 72),
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: canControl ? widget.onNext : null,
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    iconSize: 30,
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite_border, color: Colors.white54),
                  SizedBox(width: 24),
                  Icon(Icons.shuffle, color: Colors.white54),
                ],
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading && !_hasError ? null : widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF7A4BFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingSeekBar extends StatelessWidget {
  final double progress;
  final double buffered;
  final double strokeWidth;
  final void Function(double percent)? onSeekPercent;
  final Widget child;

  const _RingSeekBar({
    required this.progress,
    required this.buffered,
    required this.onSeekPercent,
    required this.child,
    this.strokeWidth = 10,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size.square(constraints.biggest.shortestSide);
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanDown: onSeekPercent == null
            ? null
            : (d) => _handleSeek(d.localPosition, size),
        onPanUpdate: onSeekPercent == null
            ? null
            : (d) => _handleSeek(d.localPosition, size),
        child: CustomPaint(
          painter: _RingPainter(progress: progress, buffered: buffered, strokeWidth: strokeWidth),
          child: Center(
            child: SizedBox(width: size.width - strokeWidth * 6, height: size.height - strokeWidth * 6, child: child),
          ),
        ),
      );
    });
  }

  void _handleSeek(Offset localPos, Size size) {
    final center = size.center(Offset.zero);
    final v = localPos - center;
    final angle = atan2(v.dy, v.dx); // -pi..pi, 0 at +x
    var percent = (angle + pi / 2) / (2 * pi); // -0.25..0.75
    if (percent < 0) percent += 1; // 0..1
    onSeekPercent?.call(percent.clamp(0.0, 1.0));
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double buffered;
  final double strokeWidth;
  _RingPainter({required this.progress, required this.buffered, required this.strokeWidth});

  @override
  void paint(Canvas c, Size s) {
    final center = s.center(Offset.zero);
    final r = s.shortestSide / 2 - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: r);
    final start = -pi / 2;

    final bg = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final buf = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFFF6FD8), Color(0xFF3813C2)])
          .createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // background full circle
    c.drawArc(rect, start, 2 * pi, false, bg);
    // buffered arc
    c.drawArc(rect, start, 2 * pi * buffered.clamp(0, 1), false, buf);
    // progress arc
    c.drawArc(rect, start, 2 * pi * progress.clamp(0, 1), false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.buffered != buffered || old.strokeWidth != strokeWidth;
}
