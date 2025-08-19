import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:music_app/features/home/views/home_page.dart';
import 'package:music_app/features/onboarding/views/onboarding_page_1.dart';
import 'package:music_app/features/onboarding/views/onboarding_page_2.dart';
import '../features/onboarding/views/onboarding_page_3.dart';
import '../features/onboarding/views/onboarding_page_4.dart';
import 'package:music_app/features/onboarding/views/onboarding_screen.dart';
import 'package:music_app/router/router_constants.dart';

// Quick slide transition
Page<void> _buildPageWithTransition(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200), // Quick transition
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Right to left slide
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Start from right
          end: Offset.zero, // End at center
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        )),
        child: child,
      );
    },
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  errorBuilder: (context, state) {
    debugPrint('🚨 GoRouter Error: ${state.error}');
    debugPrint('🚨 Attempted location: ${state.matchedLocation}');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Navigation Error', style: TextStyle(fontSize: 20, color: Colors.red)),
            const SizedBox(height: 16),
            Text('Error: ${state.error}', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/splash'),
              child: const Text('Go to Splash'),
            ),
          ],
        ),
      ),
    );
  },
  routes: [
        // ✅ Splash Screen (DJ image + MELO AI logo)
    GoRoute(
      path: '/splash',
      name: RouterConstants.splash,
      pageBuilder: (context, state) => _buildPageWithTransition(const SplashIntro(), state),
    ),
    
    // ✅ Home Page
    GoRoute(
      path: '/',
      name: RouterConstants.home,
      pageBuilder: (context, state) => _buildPageWithTransition(const HomePage(), state),
    ),
    
    // ✅ Onboarding Page 1 (DJ silhouette)
    GoRoute(
      path: '/onboarding1',
      name: RouterConstants.onboarding1,
      pageBuilder: (context, state) => _buildPageWithTransition(const OnboardingPage1(), state),
    ),
    
    // ✅ Onboarding Page 2 (Song preview carousel) - Now fetches from Supabase
    GoRoute(
      path: '/onboarding2',
      name: RouterConstants.onboarding2,
      pageBuilder: (context, state) => _buildPageWithTransition(const OnboardingPage2(), state),
    ),
    // ✅ Onboarding Page 3 (AI-Powered Creativity) - MVVM Version
    GoRoute(
      path: '/onboarding3',
      name: RouterConstants.onboarding3,
      pageBuilder: (context, state) => _buildPageWithTransition(OnboardingPage3(
        onDone: () {
          debugPrint('🎯 OnboardingPage3 onDone called - navigating to home');
          // Navigate directly to home page
          context.go('/');
        },
      ), state),
    ),
    // ✅ Onboarding Page 4 (Upgrade Flow)
    GoRoute(
      path: '/onboarding4',
      name: RouterConstants.onboarding4,
      pageBuilder: (context, state) => _buildPageWithTransition(OnboardingPage4(
        onDone: () {
          debugPrint('🎯 OnboardingPage4 onDone called - navigating to home');
          // Navigate directly to home page
          context.go('/');
        },
      ), state),
    ),

  ],
);

GoRouter get router => _router;
