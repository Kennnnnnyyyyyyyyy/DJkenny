class SupabaseConfig {
  // TODO: Replace these with your actual Supabase credentials
  static const String supabaseUrl = 'https://mukyldpzbsmyifjftuix.supabase.co/';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im11a3lsZHB6YnNteWlmamZ0dWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxNTQ3NTEsImV4cCI6MjA2NzczMDc1MX0.muHvGK0wjukhB4IeWybp1--3Bf5Qz3QjejhY9ywzN6c';
  
  // Alternative: Use environment variables (recommended for production)
  static String get url => const String.fromEnvironment(
    'SUPABASE_URL', 
    defaultValue: supabaseUrl,
  );
  
  static String get anonKey => const String.fromEnvironment(
    'SUPABASE_ANON', 
    defaultValue: supabaseAnonKey,
  );
  
  // Check if credentials are configured
  static bool get isConfigured => 
    url != 'https://your-project-id.supabase.co' && 
    anonKey != 'your-anon-key-here' &&
    url.isNotEmpty && 
    anonKey.isNotEmpty;
}
