import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_app/features/home/views/home_page.dart';
import 'package:music_app/features/onboarding/views/onboarding_page_1.dart';
import 'package:music_app/features/onboarding/views/onboarding_page_2.dart';
import 'package:music_app/features/onboarding/views/onboarding_page_3.dart';
import 'package:music_app/features/onboarding/views/onboarding_page_3_mvvm.dart';
import 'package:music_app/features/onboarding/views/onboarding_page_4.dart';
import 'package:music_app/router/router_constants.dart';


final GoRouter _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    
    // If user hasn't completed onboarding and not already on onboarding pages
    if (!onboardingCompleted && !state.uri.path.startsWith('/onboarding')) {
      return '/onboarding1';
    }
    
    // If user completed onboarding but trying to access onboarding pages
    if (onboardingCompleted && state.uri.path.startsWith('/onboarding')) {
      return '/';
    }
    
    return null; // No redirect needed
  },
  
  routes: [
    // ✅ Home Page
    GoRoute(
      path: '/',
      name: RouterConstants.home,
      builder: (context, state) => const HomePage(),
    ),
    // ✅ Onboarding Page 1 (DJ silhouette)
    GoRoute(
      path: '/onboarding1',
      name: RouterConstants.onboarding1,
      builder: (context, state) => const OnboardingPage1(),
    ),
    // ✅ Onboarding Page 2 (Song preview carousel)
    GoRoute(
      path: '/onboarding2',
      name: RouterConstants.onboarding2,
      builder: (context, state) => const OnboardingPage2(),
    ),
    // ✅ Onboarding Page 3 (AI-Powered Creativity)
    GoRoute(
      path: '/onboarding3',
      name: 'onboarding3',
      builder: (context, state) => OnboardingPage3(
        onDone: () => context.go('/onboarding4'),
      ),
    ),
    // ✅ Onboarding Page 3 MVVM (Testing)
    GoRoute(
      path: '/onboarding3-mvvm',
      name: 'onboarding3-mvvm',
      builder: (context, state) => OnboardingPage3MVVM(
        onDone: () => context.go('/onboarding4'),
      ),
    ),
    // ✅ Onboarding Page 4 (Ready to Create)
    GoRoute(
      path: '/onboarding4',
      name: 'onboarding4',
      builder: (context, state) => const OnboardingPage4(),
    ),

  ],
);

// Export with different name to avoid conflicts
GoRouter get routerNew => _router;
