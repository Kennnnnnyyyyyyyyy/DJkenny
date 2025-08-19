import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/viewmodels/auth_viewmodel.dart';
import '../features/onboarding/views/onboarding_page_3_mvvm.dart';

/// Main application widget with MVVM architecture
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'MELO AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: _createRouter(ref),
      debugShowCheckedModeBanner: false,
    );
  }

  GoRouter _createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final authState = ref.read(authViewModelProvider);
        final isLoggedIn = authState.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
        
        // If not logged in and trying to access protected routes
        if (!isLoggedIn && state.matchedLocation == '/home') {
          return '/onboarding1';
        }
        
        // If logged in and trying to access auth pages
        if (isLoggedIn && isLoggingIn) {
          return '/home';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => '/onboarding1',
        ),
        GoRoute(
          path: '/onboarding1',
          name: 'onboarding1',
          builder: (context, state) => const OnboardingPage1(),
        ),
        GoRoute(
          path: '/onboarding2',
          name: 'onboarding2',
          builder: (context, state) => const OnboardingPage2(),
        ),
        GoRoute(
          path: '/onboarding3',
          name: 'onboarding3',
          builder: (context, state) => OnboardingPage3MVVM(
            onDone: () {
              debugPrint('🎯 OnboardingPage3 onDone called - navigating to login');
              context.go('/login');
            },
          ),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
      ],
    );
  }
}

// Temporary placeholder widgets - these will be replaced with actual implementations
class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to MELO AI', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/onboarding2'),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Features Overview', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/onboarding3'),
              child: const Text('Try Now'),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage3 extends StatelessWidget {
  final VoidCallback onDone;
  
  const OnboardingPage3({super.key, required this.onDone});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Interactive Experience', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onDone,
              child: const Text('Continue to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(
        child: Text('Login Page - Will be implemented with AuthViewModel'),
      ),
    );
  }
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: const Center(
        child: Text('Signup Page - Will be implemented with AuthViewModel'),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text('Home Page - Main app content'),
      ),
    );
  }
}
