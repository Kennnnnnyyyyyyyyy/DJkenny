import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:music_app/features/onboarding/views/onboarding_page_1.dart';

class SplashIntro extends StatefulWidget {
  const SplashIntro({super.key});

  @override
  State<SplashIntro> createState() => _SplashIntroState();
}

class _SplashIntroState extends State<SplashIntro> {
  @override
  void initState() {
    super.initState();
    
    // Navigate to OnboardingPage1 after 3 seconds
    Timer(const Duration(seconds: 3), () {
      context.go('/onboarding1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/vecteezy_night-club-dj-wearing-headphones-under-party-lights_27447062.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Image.asset(
              'assets/music_logo.png',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
