import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Track {
  final int index;
  final String title;
  final Uri url;
  final String? coverUrl;
  
  Track.fromJson(Map<String, dynamic> j)
      : index = j['list_index'],
        title = j['title'],
        url   = Uri.parse(j['public_url']),
        coverUrl = j['cover_url'] as String?;
}

final page2TracksProvider = FutureProvider<List<Track>>((ref) async {
  try {
    // Debug: Print that we're attempting to fetch
    print('🔍 Attempting to fetch from onboarding_tracks table...');
    print('🔍 Using Supabase instance client...');
    
    // Try to ensure we're using the right client
    final client = Supabase.instance.client;
    
    final res = await client
        .from('onboarding_tracks')
        .select('*')
        .eq('page_tag', 'page2')      // only 3 page-2 songs
        .order('list_index');

    print('✅ Response received: ${res.length} tracks');
    return (res as List)
        .map((e) => Track.fromJson(e))
        .toList();
  } catch (error) {
    print('❌ Error in page2TracksProvider: $error');
    // If there's an error, return sample data for now
    return [
      Track.fromJson({
        'list_index': 0,
        'title': 'Sample Track 1',
        'public_url': 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav'
      }),
      Track.fromJson({
        'list_index': 1,
        'title': 'Sample Track 2', 
        'public_url': 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav'
      }),
      Track.fromJson({
        'list_index': 2,
        'title': 'Sample Track 3',
        'public_url': 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav'
      }),
    ];
  }
});
