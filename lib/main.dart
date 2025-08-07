import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';                           // contains MyApp widget

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Clean initialization with explicit URL and key
  print('🔧 Initializing Supabase with URL: https://mukyldpzbsmyifjftuix.supabase.co');
  await Supabase.initialize(
    url: 'https://mukyldpzbsmyifjftuix.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im11a3lsZHB6YnNteWlmamZ0dWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxNTQ3NTEsImV4cCI6MjA2NzczMDc1MX0.muHvGK0wjukhB4IeWybp1--3Bf5Qz3QjejhY9ywzN6c',
  );
  print('✅ Supabase initialization completed');
  
  runApp(const MyApp());
}

