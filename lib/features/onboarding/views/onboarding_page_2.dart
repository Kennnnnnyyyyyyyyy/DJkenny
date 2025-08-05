import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../features/onboarding/views/onboarding_page_3.dart';

class SongPreview {
  final String title;
  final String coverImageUrl;
  final String audioUrl;

  SongPreview({
    required this.title,
    required this.coverImageUrl,
    required this.audioUrl,
  });
}

class OnboardingPage2 extends StatefulWidget {
  final List<SongPreview> previews;
  final VoidCallback onTryNow;

  const OnboardingPage2({
    super.key,
    required this.previews,
    required this.onTryNow,
  });

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2> with WidgetsBindingObserver {
  late PageController _pageController;
  late AudioPlayer _audioPlayer;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isAppActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('🎵 OnboardingPage2 initialized!');
    _pageController = PageController(viewportFraction: 0.75, initialPage: 0);
    _audioPlayer = AudioPlayer();
    
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          // Removed loading state tracking for better UX
        });
      }
    });

    // Auto-play first song
    if (widget.previews.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAndPlaySong(0);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) {
      setState(() {
        _isAppActive = state == AppLifecycleState.resumed;
      });
    }
  }

  Future<void> _loadAndPlaySong(int index) async {
    if (index >= widget.previews.length) return;
    
    try {
      // Don't show loading state for better UX during track switches
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(widget.previews[index].audioUrl);
      await _audioPlayer.play();
      
      // Update playing state after successful load
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      print('❌ Error loading song: $e');
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  void _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      print('❌ Error toggling play/pause: $e');
    }
  }

  void _previousSong() {
    if (_currentIndex > 0) {
      final newIndex = _currentIndex - 1;
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex = newIndex);
      _loadAndPlaySong(newIndex);
    }
  }

  void _nextSong() {
    if (_currentIndex < widget.previews.length - 1) {
      final newIndex = _currentIndex + 1;
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex = newIndex);
      _loadAndPlaySong(newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAccessibilityReduceMotion = MediaQuery.of(context).disableAnimations;
    final shouldShowWaves = _isPlaying && _isAppActive && !isAccessibilityReduceMotion;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF4AE2), // Top gradient colour
                  Color(0xFF7A4BFF), // Bottom gradient colour
                ],
              ),
            ),
          ),

          // Psychedelic MultiWaveVisualizer
          if (shouldShowWaves)
            Positioned.fill(
              child: _PsychedelicWaveVisualizer(
                audioPlayer: _audioPlayer,
              ),
            )
          else if (!isAccessibilityReduceMotion)
            // Static gradient overlay for accessibility
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF6FD8).withOpacity(0.2),
                      Color(0xFF3813C2).withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ),

          // Dark scrim for legibility
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.26),
            ),
          ),

          // Main content (unchanged)
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand line
                      Text(
                        'MELO AI',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'Type your Universe in words,',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        'stream its heartbeat aloud',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'The Magic it Brews:',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Song Preview Carousel
                Expanded(
                  child: Column(
                    children: [
                        // Current Song Title (above carousel)
                        if (widget.previews.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              widget.previews[_currentIndex].title,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3.0,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        
                        const SizedBox(height: 2),
                      
                      // Carousel
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentIndex = index);
                            _loadAndPlaySong(index);
                          },
                          itemCount: widget.previews.length,
                          itemBuilder: (context, index) {
                            final isCenter = index == _currentIndex;
                            
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              transform: Matrix4.identity()
                                ..scale(isCenter ? 1.0 : 0.85),
                              child: _buildSongCard(widget.previews[index], isCenter),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),

                // Player Controls Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous Button
                      IconButton(
                        onPressed: _currentIndex > 0 ? _previousSong : null,
                        splashRadius: 32,
                        padding: const EdgeInsets.all(16),
                        icon: Icon(
                          Icons.skip_previous,
                          color: _currentIndex > 0 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.3),
                          size: 30,
                        ),
                        ),

                        const SizedBox(width: 32),

                        // Play/Pause Button
                        IconButton(
                          onPressed: _togglePlayPause,
                          splashRadius: 32,
                          padding: const EdgeInsets.all(16),
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              _isPlaying 
                                  ? Icons.pause_circle_filled 
                                  : Icons.play_circle_filled,
                              key: ValueKey(_isPlaying ? 'pause' : 'play'),
                              color: Colors.white,
                              size: 68,
                            ),
                          ),
                        ),

                        const SizedBox(width: 32),                      // Next Button
                      IconButton(
                        onPressed: _currentIndex < widget.previews.length - 1 
                            ? _nextSong 
                            : null,
                        splashRadius: 32,
                        padding: const EdgeInsets.all(16),
                        icon: Icon(
                          Icons.skip_next,
                          color: _currentIndex < widget.previews.length - 1 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.3),
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // CTA Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF6FD8), // Primary accent
                          Color(0xFF3813C2), // Secondary accent
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(32),
                        onTap: () {
                          // Navigate to onboarding page 3
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OnboardingPage3(
                                onDone: () {
                                  // Handle completion - could navigate to main app
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_note,
                                size: 18,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Try Now',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 12,
                                  color: Color(0xFF3813C2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongCard(SongPreview preview, bool isCenter) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardSize = screenWidth * 0.62; // Adjusted size
    
    return ClipRect(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        width: cardSize,
        height: cardSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating particle lines around the album
            if (_isPlaying && isCenter)
              ClipOval(
                child: _RotatingParticleRing(
                  size: cardSize + 12,
                  isPlaying: _isPlaying,
                ),
              ),
            
            // Main circular album cover
            Container(
              width: cardSize,
              height: cardSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(cardSize / 2), // Perfect circle
                child: Container(
                  color: Color(0xFF1D1E24),
                  child: Image.network(
                    preview.coverImageUrl,
                    fit: BoxFit.cover,
                    width: cardSize,
                    height: cardSize,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6FD8), Color(0xFF3813C2)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Psychedelic MultiWave Visualizer Widget
class _PsychedelicWaveVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const _PsychedelicWaveVisualizer({
    required this.audioPlayer,
  });

  @override
  _PsychedelicWaveVisualizerState createState() => _PsychedelicWaveVisualizerState();
}

class _PsychedelicWaveVisualizerState extends State<_PsychedelicWaveVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _colorController;
  late AnimationController _driftController;

  @override
  void initState() {
    super.initState();
    
    // Main wave animation
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat();
    
    // Color cycling animation
    _colorController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    // Slow drift animation
    _driftController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _colorController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _colorController, _driftController]),
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _PsychedelicWavePainter(
            waveProgress: _waveController.value,
            colorProgress: _colorController.value,
            driftProgress: _driftController.value,
          ),
        );
      },
    );
  }
}

// Custom Painter for Psychedelic Wave Effect
class _PsychedelicWavePainter extends CustomPainter {
  final double waveProgress;
  final double colorProgress;
  final double driftProgress;

  _PsychedelicWavePainter({
    required this.waveProgress,
    required this.colorProgress,
    required this.driftProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    const waveCount = 3;
    const amplitude = 0.8;
    const frequency = 1.6;
    const lowFrequency = 0.2;

    for (int waveIndex = 0; waveIndex < waveCount; waveIndex++) {
      final path = Path();
      final waveOffset = (waveIndex * 2 * pi / waveCount) + (waveProgress * 2 * pi);
      final driftOffset = driftProgress * lowFrequency * 2 * pi;
      
      // Create wave path
      for (double x = 0; x <= size.width; x += 2) {
        final normalizedX = x / size.width;
        
        // Multiple sine waves for complexity
        final wave1 = sin((normalizedX * frequency * 2 * pi) + waveOffset) * amplitude;
        final wave2 = sin((normalizedX * frequency * 4 * pi) + (waveOffset * 1.3)) * (amplitude * 0.5);
        final wave3 = sin((normalizedX * frequency * 0.5 * pi) + driftOffset) * (amplitude * 0.3);
        
        final combinedWave = wave1 + wave2 + wave3;
        final y = (size.height * 0.5) + (combinedWave * size.height * 0.2);
        
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      // Create trippy gradient color based on position and time
      final colorPhase = (colorProgress + (waveIndex * 0.33)) % 1.0;
      final color1 = Color(0xFFFF6FD8); // Pink
      final color2 = Color(0xFF3813C2); // Purple
      
      // Lerp between colors with trippy cycling
      final lerpValue = (sin(colorPhase * 2 * pi) + 1) / 2;
      final waveColor = Color.lerp(color1, color2, lerpValue)!;
      
      paint.color = waveColor.withOpacity(0.35);
      
      // Draw multiple offset versions for glow effect
      for (int i = 0; i < 3; i++) {
        final offsetPath = path.shift(Offset(0, i * 2 - 2));
        paint.color = waveColor.withOpacity(0.35 - (i * 0.1));
        canvas.drawPath(offsetPath, paint);
      }
    }
    
    // Add radial gradient overlay for extra psychedelic effect
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Color(0xFFFF6FD8).withOpacity(0.1),
          Color(0xFF3813C2).withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Rotating Particle Ring Widget
class _RotatingParticleRing extends StatefulWidget {
  final double size;
  final bool isPlaying;

  const _RotatingParticleRing({
    required this.size,
    required this.isPlaying,
  });

  @override
  _RotatingParticleRingState createState() => _RotatingParticleRingState();
}

class _RotatingParticleRingState extends State<_RotatingParticleRing>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _beatController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    
    // Rotation animation - continuous
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    // Beat animation - fast pulse
    _beatController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    
    // Particle animation - medium speed
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _beatController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _beatController, _particleController]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _ParticleRingPainter(
              beatProgress: _beatController.value,
              particleProgress: _particleController.value,
              isPlaying: widget.isPlaying,
            ),
          ),
        );
      },
    );
  }
}

// Custom Painter for Particle Ring
class _ParticleRingPainter extends CustomPainter {
  final double beatProgress;
  final double particleProgress;
  final bool isPlaying;

  _ParticleRingPainter({
    required this.beatProgress,
    required this.particleProgress,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isPlaying) return;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.42; // Just outside the album circle
    final beatOffset = beatProgress * 8; // Beat expansion
    
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    // Draw particle lines around the circle
    const particleCount = 24;
    for (int i = 0; i < particleCount; i++) {
      final angle = (i * 2 * pi / particleCount) + (particleProgress * 2 * pi);
      final radius = baseRadius + beatOffset + (sin(particleProgress * 4 * pi + i) * 5);
      
      // Calculate particle position
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      
      // Create gradient colors for particles
      final colorPhase = (i / particleCount + particleProgress) % 1.0;
      final color1 = Color(0xFFFF6FD8); // Pink
      final color2 = Color(0xFF3813C2); // Purple
      final color3 = Color(0xFFFFFFFF); // White
      
      Color particleColor;
      if (colorPhase < 0.5) {
        particleColor = Color.lerp(color1, color2, colorPhase * 2)!;
      } else {
        particleColor = Color.lerp(color2, color3, (colorPhase - 0.5) * 2)!;
      }
      
      // Particle size varies with beat
      final particleSize = 3.0 + (beatProgress * 4);
      
      paint.color = particleColor.withOpacity(0.8);
      
      // Draw particle as small circle
      canvas.drawCircle(Offset(x, y), particleSize, paint);
      
      // Draw trailing line for motion effect
      final trailLength = 8.0;
      final trailX = x - cos(angle) * trailLength;
      final trailY = y - sin(angle) * trailLength;
      
      paint.color = particleColor.withOpacity(0.3);
      paint.strokeWidth = 1.5;
      paint.style = PaintingStyle.stroke;
      
      canvas.drawLine(Offset(x, y), Offset(trailX, trailY), paint);
      
      // Reset paint style for next particle
      paint.style = PaintingStyle.fill;
    }
    
    // Add inner glow ring
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    paint.color = Color(0xFFFF6FD8).withOpacity(0.4 + (beatProgress * 0.3));
    canvas.drawCircle(center, baseRadius - 5, paint);
    
    // Add outer glow ring
    paint.color = Color(0xFF3813C2).withOpacity(0.3 + (beatProgress * 0.2));
    canvas.drawCircle(center, baseRadius + 15 + beatOffset, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
