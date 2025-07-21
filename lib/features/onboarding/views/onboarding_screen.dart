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
            child: Image.asset(
              'assets/images/xyz.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(-0.5, 0), // Crop to show DJ a bit left of center
            ),
          ),
          Center(
            child: Text(
              'IMAGINE\nCREATE\nPLAY',
              style: TextStyle(
                fontFamily: 'Boulder',
                color: const Color(0xFFF5F5F5).withOpacity(0.85), // off-white, reduced contrast
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.25),
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
