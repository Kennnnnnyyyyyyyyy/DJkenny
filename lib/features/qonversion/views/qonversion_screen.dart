import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class QonversionScreen extends StatefulWidget {
  const QonversionScreen({super.key});

  @override
  State<QonversionScreen> createState() => _QonversionScreenState();
}

class _QonversionScreenState extends State<QonversionScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/IMG_3754.MOV')
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Container(color: Colors.black),
          ),
          Positioned(
            top: 10,
            right: 18,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () {
                  context.go('/');
                },
                tooltip: 'Close',
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Melo AI Music',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black.withValues(alpha: 0.25),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI Music Generator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Features
                      ...[
                        _FeatureText('Unlimited song creation'),
                        _FeatureText('Create original music'),
                        _FeatureText('Save music to device'),
                        _FeatureText('Turn inspiration into music'),
                      ],
                      const SizedBox(height: 24),
                      // Stacked plan cards
                      const _StackedPlanCards(),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {},
                          child: const Text('Continue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Text('₹6,900.00/year. Cancel anytime', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Manrope')),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Restore Purchase', style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 12, fontFamily: 'Manrope')),
                                const SizedBox(width: 12),
                                Text('Terms of Use', style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 12, fontFamily: 'Manrope')),
                                const SizedBox(width: 12),
                                Text('Privacy Policy', style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 12, fontFamily: 'Manrope')),
                              ],
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureText extends StatelessWidget {
  final String text;
  const _FeatureText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.deepPurple, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Manrope')),
        ],
      ),
    );
  }
}

// Stacked plan cards widget
class _StackedPlanCards extends StatelessWidget {
  const _StackedPlanCards();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StackedPlanCard(
          title: 'Annually',
          price: '₹6,900.00',
          period: '/year',
          subPrice: '₹132.32 /week',
          selected: true,
        ),
        const SizedBox(height: 16),
        _StackedPlanCard(
          title: 'Weekly',
          price: '₹699.00',
          period: '/week',
          subPrice: '₹699.00 /week',
          selected: false,
        ),
      ],
    );
  }
}

class _StackedPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String subPrice;
  final bool selected;
  const _StackedPlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.subPrice,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: selected ? Colors.deepPurple.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? Colors.deepPurpleAccent : Colors.white24,
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
                    if (selected)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.check_circle, color: Colors.white, size: 20),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(price, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
                    Text(period, style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Manrope')),
                  ],
                ),
                const SizedBox(height: 6),
                Text(subPrice, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontFamily: 'Manrope')),
                const SizedBox(height: 6),
                Text('Unlimited song creation', style: TextStyle(color: selected ? Colors.greenAccent : Colors.white70, fontSize: 14, fontFamily: 'Manrope')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

