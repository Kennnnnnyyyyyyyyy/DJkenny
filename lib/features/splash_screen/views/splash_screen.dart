import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    /// Wait 3 seconds, then navigate to OnboardingPage2 (Song carousel)
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        print('🔄 Navigating from OnboardingPage1 to OnboardingPage2...');
        context.go('/onboarding2');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/xyz.jpg',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            Text(
              'Melo AI',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    color: Colors.white,
                    fontFamily: 'Manrope',
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 40),
            // Debug button to test onboarding 2
            ElevatedButton(
              onPressed: () {
                context.go('/onboarding2');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6FD8),
                foregroundColor: Colors.white,
              ),
              child: const Text('Test Onboarding 2'),
            ),
            const SizedBox(height: 10),
            // Test Onboarding 1 button
            ElevatedButton(
              onPressed: () {
                context.go('/onboarding1');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A4BFF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Test Onboarding 1'),
            ),
          ],
        ),
      ),
    );
  }
}
