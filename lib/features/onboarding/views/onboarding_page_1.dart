import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';
import 'onboarding_page_2.dart';

class OnboardingPage1 extends StatefulWidget {
  const OnboardingPage1({super.key});

  @override
  State<OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<OnboardingPage1> 
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Start particle animation
    _particleController.repeat();
    
    // Auto-navigate to OnboardingPage2 after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/onboarding2');
      }
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF4AE2), // Fallback color
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Animated particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    animationProgress: _particleController.value,
                  ),
                );
              },
            ),
          ),

          // Neon logo with better blending
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main neon image with better blending
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Image.asset(
                      'assets/images/neon3.png',
                      fit: BoxFit.contain,
                      colorBlendMode: BlendMode.lighten,
                      color: Colors.white.withOpacity(0.05),
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback design
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF6FD8).withOpacity(0.8),
                                Color(0xFF3813C2).withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'MELO AI',
                                  style: TextStyle(
                                    fontFamily: 'Playfair Display',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'MUSIC',
                                  style: TextStyle(
                                    fontFamily: 'Playfair Display',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Subtle overlay to blend edges
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Colors.transparent,
                          Color(0xFFFF4AE2).withOpacity(0.08),
                          Color(0xFF7A4BFF).withOpacity(0.12),
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Floating Particles
class _ParticlePainter extends CustomPainter {
  final double animationProgress;

  _ParticlePainter({required this.animationProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    // Create floating particles
    for (int i = 0; i < 20; i++) {
      final random = Random(i);
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      
      // Animate particles in a floating motion
      final floatOffset = sin((animationProgress * 2 * pi) + (i * 0.5)) * 20;
      final x = baseX + floatOffset;
      final y = baseY + (animationProgress * 50) % size.height;
      
      // Vary particle colors
      final colorPhase = (animationProgress + (i * 0.1)) % 1.0;
      Color particleColor;
      if (colorPhase < 0.33) {
        particleColor = Color(0xFFFF6FD8);
      } else if (colorPhase < 0.66) {
        particleColor = Color(0xFF3813C2);
      } else {
        particleColor = Colors.white;
      }
      
      paint.color = particleColor.withOpacity(0.6);
      
      // Vary particle sizes
      final particleSize = 2.0 + (sin(animationProgress * 3 * pi + i) * 3);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
      
      // Add glow effect for some particles
      if (i % 3 == 0) {
        paint.color = particleColor.withOpacity(0.2);
        canvas.drawCircle(Offset(x, y), particleSize * 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
