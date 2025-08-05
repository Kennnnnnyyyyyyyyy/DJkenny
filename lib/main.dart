import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'shared/services/realtime.dart';
import 'shared/services/bootstrap.dart';
import 'shared/services/auth_service.dart';
import 'features/onboarding/views/onboarding_screen.dart'; // Import SplashIntro

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode only for better music app experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure status bar for consistent appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  try {
    // Get Supabase credentials from config
    final supabaseUrl = SupabaseConfig.url;
    final supabaseAnonKey = SupabaseConfig.anonKey;

    // Check if credentials are configured
    if (!SupabaseConfig.isConfigured) {
      if (kDebugMode) {
        debugPrint('❌ Supabase credentials not configured.');
        debugPrint('Edit lib/config/supabase_config.dart or use environment variables');
      }
      // Run app without Supabase for UI testing
      runApp(const MyApp());
      return;
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    // Initialize Anonymous Authentication
    final authService = AuthService();
    await authService.signInAnonymously();

    initRealtime();      // opens WebSocket channel
    await bootstrapLists(); // pulls existing rows once

  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Initialization error: $e');
    }
    // Continue to run app even if Supabase fails
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MELO AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Manrope', // Set Manrope as the default font for the entire app
        useMaterial3: true,
      ),
      home: const SplashIntro(), // Start directly with SplashIntro
    );
  }
}

class _TestScreen extends StatelessWidget {
  const _TestScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, color: Colors.purple, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Music App',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text(
                    'Supabase Not Connected',
                    style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'To connect Supabase:\n\n1. Edit lib/config/supabase_config.dart\n2. Replace with your Supabase URL and anon key\n\nOR use environment variables:\nflutter run --dart-define=SUPABASE_URL=your-url',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Manrope'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/onboarding');
                    },
                    child: const Text('Continue with UI Test'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
