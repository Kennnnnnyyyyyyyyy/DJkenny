import 'package:flutter/material.dart';
import 'package:music_app/features/home/views/home_page.dart';
import 'package:music_app/features/splash_screen/views/splash_screen.dart';
import 'package:music_app/features/onboarding/views/onboarding_screen.dart';
import 'package:music_app/features/qonversion/views/qonversion_screen.dart';
import 'package:music_app/features/explore/views/explore_page.dart';
import 'package:music_app/features/library/views/library_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, // ✅ Match brightness
        ),
        useMaterial3: true,
      ),
      initialRoute: '/onboarding', // Start from Onboarding
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/qonversion': (context) => const QonversionScreen(),
        '/explore': (context) => ExplorePage(),
        '/library': (context) => LibraryPage(),
      },
    );
  }
}
