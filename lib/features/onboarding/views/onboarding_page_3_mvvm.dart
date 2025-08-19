import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/logging/logger.dart';
import '../../../domain/models/chat_message.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../../../ui/widgets/circular_album_player.dart';

/// MVVM version of OnboardingPage3 using ViewModels
class OnboardingPage3MVVM extends ConsumerStatefulWidget {
  final VoidCallback onDone;

  const OnboardingPage3MVVM({super.key, required this.onDone});

  @override
  ConsumerState<OnboardingPage3MVVM> createState() => _OnboardingPage3MVVMState();
}

class _OnboardingPage3MVVMState extends ConsumerState<OnboardingPage3MVVM> 
    with TickerProviderStateMixin {
  
  final ScrollController _scrollController = ScrollController();
  late AnimationController _discController;
  late AnimationController _messageAnimationController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _colorController;
  late AnimationController _driftController;

  @override
  void initState() {
    super.initState();
    Logger.d('Initializing OnboardingPage3MVVM', tag: 'ONBOARDING_UI');
    
    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _messageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _colorController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _driftController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    // Start animations
    _particleController.repeat();
    _waveController.repeat();
    _colorController.repeat();
    _driftController.repeat();
  }

  @override
  void dispose() {
    Logger.d('Disposing OnboardingPage3MVVM', tag: 'ONBOARDING_UI');
    _scrollController.dispose();
    _discController.dispose();
    _messageAnimationController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _colorController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingViewModelProvider);
    final onboardingVM = ref.read(onboardingViewModelProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: onboardingState.showPsychedelicBackground
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Background particles
            if (!onboardingState.showPsychedelicBackground)
              AnimatedBuilder(
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

            // Psychedelic wave visualizer
            if (onboardingState.showPsychedelicBackground && onboardingState.hasTrack)
              _PsychedelicWaveVisualizer(
                waveController: _waveController,
                colorController: _colorController,
                driftController: _driftController,
              ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Chat messages
                  Expanded(
                    child: _buildChatArea(onboardingState, onboardingVM),
                  ),
                  
                  // Bottom area for player or choices
                  _buildBottomArea(onboardingState, onboardingVM),
                ],
              ),
            ),

            // Error overlay
            if (onboardingState.error != null)
              _buildErrorOverlay(onboardingState, onboardingVM),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Spacer(),
          const Text(
            'MELO AI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildChatArea(OnboardingState state, OnboardingViewModel vm) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return _buildMessage(message, state, vm);
      },
    );
  }

  Widget _buildMessage(ChatMessage message, OnboardingState state, OnboardingViewModel vm) {
    return Container(
      key: message.key,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: _buildMessageContent(message, state, vm),
    );
  }

  Widget _buildMessageContent(ChatMessage message, OnboardingState state, OnboardingViewModel vm) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(message);
      case MessageType.choices:
        return _buildChoicesMessage(message, state, vm);
      case MessageType.creating:
        return _buildCreatingMessage();
      case MessageType.songCreated:
        return _buildSongCreatedMessage(state);
      case MessageType.upgrade:
        return _buildUpgradeMessage();
      case MessageType.payment:
        return _buildPaymentMessage(vm);
    }
  }

  Widget _buildTextMessage(ChatMessage message) {
    return Align(
      alignment: message.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isFromUser 
              ? const Color(0xFFFF6FD8) 
              : const Color(0x20FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: message.isFromUser 
              ? null 
              : Border.all(color: const Color(0x30FFFFFF)),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildChoicesMessage(ChatMessage message, OnboardingState state, OnboardingViewModel vm) {
    if (message.choices == null || message.choices!.isEmpty) return const SizedBox.shrink();

    return Column(
      children: message.choices!.map((choice) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ElevatedButton(
            onPressed: state.isProcessingChoice 
                ? null 
                : () => vm.handleChoice(choice),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0x20FFFFFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0x30FFFFFF)),
              ),
            ),
            child: Text(choice),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCreatingMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0x20FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x30FFFFFF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFFFF6FD8),
            ),
            const SizedBox(height: 16),
            const Text(
              'Creating your song...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongCreatedMessage(OnboardingState state) {
    final track = state.track;
    if (track == null) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, child) {
        return CircularAlbumPlayer(
          title: track.title,
          subtitle: 'Melo AI',
          audioUrl: track.audioUrl,
          coverUrl: track.coverUrl ?? '',
          onFinished: () {},
          onNext: widget.onDone,
          onPrev: () {},
          onContinue: () {
            Logger.d('Continue button pressed in MVVM player', tag: 'ONBOARDING_UI');
            ref.read(onboardingViewModelProvider.notifier).navigateToUpgrade();
          },
        );
      },
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
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
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMessage(OnboardingViewModel vm) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ElevatedButton(
            onPressed: () {
              Logger.nav('Payment', 'Start Trial', tag: 'ONBOARDING_UI');
              vm.handlePaymentChoice("Start Trial");
              // Navigate to subscription flow
              context.go('/home'); // For now, just go to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6FD8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Start Free Trial'),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: TextButton(
            onPressed: () {
              Logger.nav('Payment', 'Continue Free', tag: 'ONBOARDING_UI');
              vm.handlePaymentChoice("Continue Free");
              debugPrint('🎯 OnboardingPage3MVVM: Calling widget.onDone()');
              widget.onDone();
            },
            child: const Text(
              'Continue Free',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomArea(OnboardingState state, OnboardingViewModel vm) {
    // Show player if we have a track and song is created
    if (state.hasTrack && state.currentStep == OnboardingStep.songCreated) {
      return const SizedBox.shrink(); // Player is shown in the message
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildErrorOverlay(OnboardingState state, OnboardingViewModel vm) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.clearError(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Chat Background Particles (reused from original)
class _ChatParticlePainter extends CustomPainter {
  final double animationProgress;

  _ChatParticlePainter({required this.animationProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent particles
    
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animationProgress * 100) % size.height;
      final radius = random.nextDouble() * 2 + 1;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Psychedelic Wave Visualizer (simplified from original)
class _PsychedelicWaveVisualizer extends StatelessWidget {
  final AnimationController waveController;
  final AnimationController colorController;
  final AnimationController driftController;

  const _PsychedelicWaveVisualizer({
    required this.waveController,
    required this.colorController,
    required this.driftController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([waveController, colorController, driftController]),
      builder: (context, child) {
        return CustomPaint(
          painter: _PsychedelicWavePainter(
            waveProgress: waveController.value,
            colorProgress: colorController.value,
            driftProgress: driftController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// Custom Painter for Psychedelic Wave Effect (simplified from original)
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
      ..strokeWidth = 2;

    // Create wave effect
    final path = Path();
    final waveHeight = size.height * 0.1;
    final waveLength = size.width / 4;
    
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 + 
          sin((x / waveLength + waveProgress * 2 * pi)) * waveHeight +
          sin((x / (waveLength * 0.7) + driftProgress * pi)) * waveHeight * 0.5;
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Animated colors
    final hue = (colorProgress * 360) % 360;
    paint.color = HSVColor.fromAHSV(0.5, hue, 1.0, 1.0).toColor();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
