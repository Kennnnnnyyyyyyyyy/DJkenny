import 'package:flutter/material.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/vecteezy_night-club-dj-wearing-headphones-under-party-lights_27447062.jpg'),
                  fit: BoxFit.cover, // This ensures the image covers the entire screen
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          Center(
            child: Stack(
              children: [
                // Black outline layer (stroke)
                Text(
                  'IMAGINE\nCREATE\nPLAY',
                  style: TextStyle(
                    fontFamily: 'Boulder',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1.0 // Thin 1px outline
                      ..color = Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                // Gradient text layer (fill)
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'IMAGINE\nCREATE\nPLAY',
                    style: TextStyle(
                      fontFamily: 'Boulder',
                      color: Colors.white, // Base color for ShaderMask
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.25),
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
