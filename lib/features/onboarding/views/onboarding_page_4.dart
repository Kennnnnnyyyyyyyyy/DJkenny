import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum MessageType {
  text,
  upgrade,
  payment,
}

class ChatMessage {
  final String text;
  final bool isFromUser;
  final MessageType type;
  final GlobalKey key;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.type,
  }) : key = GlobalKey();
}

class OnboardingPage4 extends StatefulWidget {
  final VoidCallback onDone;

  const OnboardingPage4({super.key, required this.onDone});

  @override
  State<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<OnboardingPage4> 
    with TickerProviderStateMixin {
  
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late AnimationController _particleController;
  late AnimationController _messageAnimationController;
  
  String _currentStep = "upgrade";
  bool _isSecondPaymentPrompt = false;
  bool _isProcessingChoice = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🎯 OnboardingPage4 initialized - showing unlock potential flow');
    
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _messageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Start particle animation
    _particleController.repeat();

    // Start the upgrade flow immediately
    _showUpgradeFlow();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _particleController.dispose();
    _messageAnimationController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    debugPrint('🔥 Adding message: "${message.text}" (type: ${message.type})');
    setState(() {
      _messages.add(message);
    });
    debugPrint('🔥 Total messages now: ${_messages.length}');
    
    _messageAnimationController.forward().then((_) {
      _messageAnimationController.reset();
    });
    
    // Smooth scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _showUpgradeFlow() {
    debugPrint('🔓 Starting upgrade flow');
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      _addMessage(ChatMessage(
        text: "Unlock Full Potential — here's what you get:",
        isFromUser: false,
        type: MessageType.text,
      ));
      
      Future.delayed(const Duration(milliseconds: 800), () {
        _addMessage(ChatMessage(
          text: "",
          isFromUser: false,
          type: MessageType.upgrade,
        ));
        
        Future.delayed(const Duration(milliseconds: 2000), () {
          _addMessage(ChatMessage(
            text: "How does it sound?",
            isFromUser: false,
            type: MessageType.text,
          ));
          
          Future.delayed(const Duration(milliseconds: 800), () {
            _addMessage(ChatMessage(
              text: "",
              isFromUser: false,
              type: MessageType.payment,
            ));
          });
        });
      });
    });
  }

  void _handlePaymentChoice(String choice) {
    debugPrint('💰 Payment choice selected: $choice');
    
    if (_isProcessingChoice) return;
    setState(() => _isProcessingChoice = true);
    
    if (choice == "Sounds great!") {
      // Show slide-up paywall modal
      _showPaywallModal();
    } else if (choice == "Explain some more") {
      if (!_isSecondPaymentPrompt) {
        setState(() {
          _isSecondPaymentPrompt = true;
          _messages.clear();
        });
        
        // Show additional explanation messages
        Future.delayed(const Duration(milliseconds: 500), () {
          _addMessage(ChatMessage(
            text: "Here's why Melo AI Premium is perfect for you:",
            isFromUser: false,
            type: MessageType.text,
          ));
          
          Future.delayed(const Duration(milliseconds: 800), () {
            _addMessage(ChatMessage(
              text: "✨ Unlimited song generation with advanced AI models\n🎤 Professional voice cloning technology\n📱 Priority processing and faster generation\n💾 High-quality downloads (MP3, WAV)\n🎵 Advanced music customization options\n🔄 Version history and remix capabilities",
              isFromUser: false,
              type: MessageType.text,
            ));
            
            Future.delayed(const Duration(milliseconds: 1000), () {
              _addMessage(ChatMessage(
                text: "Ready to unlock your musical potential?",
                isFromUser: false,
                type: MessageType.text,
              ));
              
              Future.delayed(const Duration(milliseconds: 500), () {
                _addMessage(ChatMessage(
                  text: "",
                  isFromUser: false,
                  type: MessageType.payment,
                ));
                
                setState(() => _isProcessingChoice = false);
              });
            });
          });
        });
      } else {
        // If already shown explanation, navigate to subscription
        context.go('/');
      }
    }
  }

  void _showPaywallModal() {
    setState(() => _isProcessingChoice = false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Premium plan card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6),
                      const Color(0xFFA855F7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Melo AI Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'MOST POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '\$9.99/month',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '3-day free trial, then \$9.99/month',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Features list
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModalFeatureItem(Icons.music_note, 'Unlimited AI song generation'),
                    _buildModalFeatureItem(Icons.mic, 'Advanced voice cloning'),
                    _buildModalFeatureItem(Icons.high_quality, 'High-quality downloads'),
                    _buildModalFeatureItem(Icons.palette, 'Custom album artwork'),
                    _buildModalFeatureItem(Icons.speed, 'Priority processing'),
                    _buildModalFeatureItem(Icons.history, 'Version history & remixes'),
                  ],
                ),
              ),
              
              // Action buttons
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start Free Trial',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onDone();
                        context.go('/');
                      },
                      child: const Text(
                        'Continue with Free Version',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF8B5CF6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient - matching your app theme
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF4AE2), // Top gradient colour - matching your theme
                  Color(0xFF7A4BFF), // Bottom gradient colour - matching your theme
                ],
              ),
            ),
          ),

          // Animated particles background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ChatParticlePainter(
                    animationProgress: _particleController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // Dark scrim for better text readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with MELO AI branding
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: const Center(
                    child: Text(
                      'MELO AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
                
                // Chat messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(_messages[index]);
                    },
                  ),
                ),
                
                // Bottom choice area
                _buildBottomChoiceArea(),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomChoiceArea() {
    // Find the last payment message if any
    final lastPaymentMessage = _messages.lastWhere(
      (msg) => msg.type == MessageType.payment,
      orElse: () => ChatMessage(text: "", isFromUser: false, type: MessageType.text),
    );
    
    if (lastPaymentMessage.type == MessageType.payment) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)], // Pink to purple gradient
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: () => _handlePaymentChoice("Sounds great!"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Sounds great!",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ),
            // Only show "Explain some more" button if it's NOT the second payment prompt
            if (!_isSecondPaymentPrompt)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: () => _handlePaymentChoice("Explain some more"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2), // Transparent white background
                    foregroundColor: Colors.white, // White text color
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Explain some more",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    
    return const SizedBox(height: 20);
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      key: message.key,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: _buildMessageContent(message),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(message);
      case MessageType.upgrade:
        return _buildUpgradeMessage();
      case MessageType.payment:
        return const SizedBox.shrink(); // Payment buttons are handled at bottom
    }
  }

  Widget _buildTextMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: message.isFromUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/music_logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if logo doesn't load
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6FD8), Color(0xFF3813C2)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded, 
                        color: Colors.white, 
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: message.isFromUser 
                    ? const Color(0xFFFF6FD8) // Updated to match your theme
                    : const Color(0x20FFFFFF), // More transparent for better readability
                borderRadius: BorderRadius.circular(message.isFromUser ? 25 : 20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: message.isFromUser ? FontWeight.w600 : FontWeight.w400,
                  fontFamily: 'SF Pro Display',
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0x20FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x30FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureItem(
            icon: Icons.music_note,
            title: "Create More AI Songs",
            subtitle: "Generate unlimited tracks in any style",
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.mic,
            title: "Voice Cloning",
            subtitle: "Clone your voice for personalized vocals",
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.download,
            title: "Download & Share",
            subtitle: "Export your creations in high quality",
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6FD8), Color(0xFF3813C2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom Painter for Chat Background Particles
class _ChatParticlePainter extends CustomPainter {
  final double animationProgress;

  _ChatParticlePainter({required this.animationProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Create floating particles throughout the chat background
    for (int i = 0; i < 25; i++) {
      // Create consistent particle positions using index as seed
      final Random rng = Random(i);
      
      // Base positions across the screen
      double baseX = rng.nextDouble() * size.width;
      double baseY = rng.nextDouble() * size.height;
      
      // Animate particles in a gentle floating motion
      double offsetX = sin((animationProgress * 2 * pi) + (i * 0.3)) * 30;
      double offsetY = cos((animationProgress * 2 * pi) + (i * 0.5)) * 20;
      
      double finalX = baseX + offsetX;
      double finalY = baseY + offsetY;
      
      // Vary particle colors to match your theme
      Color particleColor;
      if (i % 3 == 0) {
        particleColor = const Color(0xFFFF6FD8); // Pink from your theme
      } else if (i % 3 == 1) {
        particleColor = const Color(0xFF7A4BFF); // Purple from your theme
      } else {
        particleColor = Colors.white;
      }
      
      paint.color = particleColor.withOpacity(0.4);
      
      // Vary particle sizes
      double particleSize = (i % 3) == 0 ? 3.0 : 2.0;
      
      canvas.drawCircle(Offset(finalX, finalY), particleSize, paint);
    }

    // Add some larger glowing particles
    for (int i = 0; i < 8; i++) {
      final Random rng = Random(i + 100);
      
      double baseX = rng.nextDouble() * size.width;
      double baseY = rng.nextDouble() * size.height;
      
      // Slower movement for larger particles
      double offsetX = sin((animationProgress * pi) + (i * 0.8)) * 50;
      double offsetY = cos((animationProgress * pi) + (i * 0.6)) * 40;
      
      double finalX = baseX + offsetX;
      double finalY = baseY + offsetY;
      
      // Glow effect
      paint.color = const Color(0xFFFF6FD8).withOpacity(0.15);
      canvas.drawCircle(Offset(finalX, finalY), 8, paint);
      
      paint.color = const Color(0xFFFF6FD8).withOpacity(0.3);
      canvas.drawCircle(Offset(finalX, finalY), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
