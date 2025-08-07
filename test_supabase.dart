import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://mukyldpzbsmyifjftuix.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im11a3lsZHB6YnNteWlmamZ0dWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxNTQ3NTEsImV4cCI6MjA2NzczMDc1MX0.muHvGK0wjukhB4IeWybp1--3Bf5Qz3QjejhY9ywzN6c',
  );

  print('🔍 Testing Supabase connection...');
  
  try {
    final client = Supabase.instance.client;
    
    // Test basic connection
    print('✅ Supabase client initialized');
    
    // Test querying the onboarding_tracks table
    print('🔍 Querying onboarding_tracks table...');
    final res = await client
        .from('onboarding_tracks')
        .select('*')
        .limit(10);
    
    print('✅ Query successful! Found ${res.length} total tracks');
    for (var track in res) {
      print('  - Track: ${track['title']} (page: ${track['page_tag']}, index: ${track['list_index']})');
      print('    URL: ${track['public_url']}');
    }
    
    // Test specifically for page2 tracks
    print('\n🔍 Querying page2 tracks specifically...');
    final page2Res = await client
        .from('onboarding_tracks')
        .select('*')
        .eq('page_tag', 'page2')
        .order('list_index');
    
    print('✅ Page2 query successful! Found ${page2Res.length} page2 tracks');
    for (var track in page2Res) {
      print('  - Page2 Track: ${track['title']} (index: ${track['list_index']})');
      print('    URL: ${track['public_url']}');
    }
    
  } catch (error) {
    print('❌ Error testing Supabase: $error');
  }
}
