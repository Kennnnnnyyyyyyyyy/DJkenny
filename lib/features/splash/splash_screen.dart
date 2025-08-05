import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to onboarding after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/onboarding1');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen background image (same as onboarding 1)
          Positioned.fill(
            child: Image.asset(
              'assets/images/vecteezy_night-club-dj-wearing-headphones-under-party-lights_27447062.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Centered logo (same as onboarding 1)
          Center(
            child: Container(
              width: 140,
              height: 140,
              child: Image.asset(
                'assets/music_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
