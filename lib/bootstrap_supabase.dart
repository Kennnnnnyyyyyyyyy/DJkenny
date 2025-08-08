import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes Supabase with project URL and anonymous key from environment
Future<void> bootstrapSupabase() async {
  await Supabase.initialize(
    url: 'https://mukyldpzbsmyifjftuix.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im11a3lsZHB6YnNteWlmamZ0dWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxNTQ3NTEsImV4cCI6MjA2NzczMDc1MX0.muHvGK0wjukhB4IeWybp1--3Bf5Qz3QjejhY9ywzN6c',
  );
}

/// Global Supabase client instance
final supabase = Supabase.instance.client;
