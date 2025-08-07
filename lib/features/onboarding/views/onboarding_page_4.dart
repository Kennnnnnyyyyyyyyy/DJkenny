import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage4 extends StatelessWidget {
  const OnboardingPage4({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    // Navigate to home
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF4AE2), // Top pink
              Color(0xFF7A4BFF), // Bottom purple
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => _completeOnboarding(context),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Main Content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.rocket_launch,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Title
                      const Text(
                        'Ready to\nCreate Magic?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Manrope',
                          height: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Description
                      const Text(
                        'Start your musical journey today. From simple ideas to complete compositions, your creativity has no limits.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontFamily: 'Manrope',
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Navigation
                Column(
                  children: [
                    // Page indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 8),
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 8),
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 8),
                        Container(width: 24, height: 8, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Get Started button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)], // Pink to purple gradient
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ElevatedButton(
                        onPressed: () => _completeOnboarding(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Manrope',
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
      ),
    );
  }
}
