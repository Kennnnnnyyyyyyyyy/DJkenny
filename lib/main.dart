import 'package:flutter/material.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:audio_session/audio_session.dart';
import 'app.dart';
import 'core/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize audio session for music playback (fixes iOS silent switch issue)
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  await session.setActive(true);
  
  // Initialize Supabase using Env-based bootstrap
  await initSupabase();
  
  // Initialize Superwall for iOS
  await Superwall.configure('pk_faef7874706620e075c87409d669b260cd9ef40f8cc09eca');
  
  runApp(const MyApp());
}

