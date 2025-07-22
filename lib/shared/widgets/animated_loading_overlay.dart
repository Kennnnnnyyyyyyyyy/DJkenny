import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedLoadingOverlay extends StatefulWidget {
  final bool isVisible;
  final String? successMessage;
  final VoidCallback? onGenerationComplete;

  const AnimatedLoadingOverlay({
    super.key,
    required this.isVisible,
    this.successMessage,
    this.onGenerationComplete,
  });

  @override
  State<AnimatedLoadingOverlay> createState() => _AnimatedLoadingOverlayState();
}

class _AnimatedLoadingOverlayState extends State<AnimatedLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  
  String? _currentLoadingText;
  
  // List of random loading messages
  final List<String> _loadingMessages = [
    "Synthesizing your sound...",
    "Calibrating frequencies...",
    "Decrypting beats...",
    "Rendering sonic waves...",
    "Building audio algorithms...",
    "Assembling your soundtrack...",
    "Translating data into groove...",
    "Generating sound architecture...",
    "Compiling music code...",
    "Booting up your melody...",
  ];

  @override
  void initState() {
    super.initState();
    
    // Setup rotation animation (360° every 4 seconds - slower)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    // Setup pulse animation (gentle scaling)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations if initially visible and not showing success
    if (widget.isVisible && widget.successMessage == null) {
      _startAnimations();
      _selectRandomLoadingText();
    }
  }

  @override
  void didUpdateWidget(AnimatedLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible && !oldWidget.isVisible && widget.successMessage == null) {
      // Started generating (not showing success)
      _startAnimations();
      _selectRandomLoadingText();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      // Stopped generating
      _stopAnimations();
    } else if (widget.successMessage != null && oldWidget.successMessage == null) {
      // Showing success message - stop animations
      _stopAnimations();
    }
  }

  void _startAnimations() {
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _rotationController.stop();
    _pulseController.stop();
  }

  void _selectRandomLoadingText() {
    final random = Random();
    final index = random.nextInt(_loadingMessages.length);
    setState(() {
      _currentLoadingText = _loadingMessages[index];
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Blurred background overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        
        // Purple aura spreading across screen
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  const Color(0xFF3813C2).withOpacity(0.6),
                  const Color(0xFF3813C2).withOpacity(0.4),
                  const Color(0xFF3813C2).withOpacity(0.2),
                  const Color(0xFF3813C2).withOpacity(0.1),
                  const Color(0xFF3813C2).withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
              ),
            ),
          ),
        ),
        
        // Centered loading content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo with enhanced focus (no blue outline)
              AnimatedBuilder(
                animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(70),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3813C2).withOpacity(0.6),
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFF6FD8).withOpacity(0.4),
                              blurRadius: 35,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: Image.asset(
                            'assets/music_logo.png',
                            width: 140,
                            height: 140,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if logo doesn't load
                              return Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3813C2), Color(0xFFFF6FD8)],
                                  ),
                                  borderRadius: BorderRadius.circular(70),
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 70,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 50),
              
              // Loading or success text without outline
              if (_currentLoadingText != null || widget.successMessage != null)
                Text(
                  widget.successMessage ?? _currentLoadingText!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              
              const SizedBox(height: 30),
              
              // Enhanced progress indicator
              Container(
                width: 250,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3813C2).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF3813C2).withOpacity(0.9),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Helper class for easy integration
class LoadingManager extends ChangeNotifier {
  bool _isGenerating = false;
  
  bool get isGenerating => _isGenerating;
  
  void startGenerating() {
    if (!_isGenerating) {
      _isGenerating = true;
      notifyListeners();
    }
  }
  
  void stopGenerating() {
    if (_isGenerating) {
      _isGenerating = false;
      notifyListeners();
    }
  }
}
