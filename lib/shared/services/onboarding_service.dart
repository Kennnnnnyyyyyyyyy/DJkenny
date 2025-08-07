import 'package:supabase_flutter/supabase_flutter.dart';

/// Model for onboarding tracks that matches your existing table structure
class OnboardingTrack {
  final String id;
  final String pageTag;
  final int listIndex;
  final String title;
  final String publicUrl;
  final DateTime createdAt;

  OnboardingTrack({
    required this.id,
    required this.pageTag,
    required this.listIndex,
    required this.title,
    required this.publicUrl,
    required this.createdAt,
  });

  factory OnboardingTrack.fromJson(Map<String, dynamic> json) {
    return OnboardingTrack(
      id: json['id'],
      pageTag: json['page_tag'],
      listIndex: json['list_index'],
      title: json['title'],
      publicUrl: json['public_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Service to interact with your existing Supabase backend
/// IMPORTANT: This service only READS from your existing resources
/// It does NOT modify any buckets, tables, or policies
class OnboardingService {
  static final _supabase = Supabase.instance.client;

  /// Fetch tracks for a specific page from your existing onboarding_tracks table
  /// Uses your exact table structure: page_tag, list_index, title, public_url
  /// 
  /// Example usage:
  /// - getTracksForPage('page2') → returns 3 tracks for onboarding page 2
  /// - getTracksForPage('page3') → returns tracks for page 3 (when added)
  static Future<List<OnboardingTrack>> getTracksForPage(String pageTag) async {
    try {
      print('🎵 Fetching onboarding tracks for: $pageTag');
      
      final response = await _supabase
          .from('onboarding_tracks')
          .select('*')
          .eq('page_tag', pageTag)
          .order('list_index', ascending: true);

      final tracks = (response as List)
          .map((json) => OnboardingTrack.fromJson(json))
          .toList();

      print('✅ Found ${tracks.length} tracks for $pageTag');
      return tracks;
    } catch (e) {
      print('❌ Error fetching onboarding tracks for $pageTag: $e');
      return [];
    }
  }

  /// Get direct public URL from your existing 'onboarding-songs' bucket
  /// This bucket is PUBLIC and contains: intro.mp3, Neon Shadows.mp3, final_lift.mp3
  /// 
  /// Example usage:
  /// - getOnboardingSongUrl('intro.mp3') → returns public URL
  static String getOnboardingSongUrl(String filename) {
    final url = _supabase.storage
        .from('onboarding-songs')
        .getPublicUrl(filename);
    
    print('🔗 Generated URL for $filename: $url');
    return url;
  }

  /// Utility method to verify your backend setup (read-only check)
  /// This helps debug connectivity without modifying anything
  static Future<bool> testConnection() async {
    try {
      print('🔌 Testing Supabase connection...');
      
      // Test table access
      await _supabase
          .from('onboarding_tracks')
          .select('count')
          .limit(1);
      
      // Test bucket access
      final bucketFiles = await _supabase.storage
          .from('onboarding-songs')
          .list();
      
      print('✅ Connection successful - Table accessible, ${bucketFiles.length} files in bucket');
      return true;
    } catch (e) {
      print('❌ Connection failed: $e');
      return false;
    }
  }

  /// Helper method to check if your sample data exists
  /// This is read-only and won't modify anything
  static Future<Map<String, int>> getTrackCounts() async {
    try {
      final allTracks = await _supabase
          .from('onboarding_tracks')
          .select('page_tag');

      final Map<String, int> counts = {};
      for (final track in allTracks) {
        final pageTag = track['page_tag'] as String;
        counts[pageTag] = (counts[pageTag] ?? 0) + 1;
      }

      print('📊 Track counts by page: $counts');
      return counts;
    } catch (e) {
      print('❌ Error getting track counts: $e');
      return {};
    }
  }

  /// Get all available audio files from your onboarding-songs bucket
  /// This is read-only and helps verify your audio files
  static Future<List<String>> getAvailableAudioFiles() async {
    try {
      final files = await _supabase.storage
          .from('onboarding-songs')
          .list();

      final audioFiles = files
          .where((file) => file.name.endsWith('.mp3') || 
                          file.name.endsWith('.wav'))
          .map((file) => file.name)
          .toList();

      print('🎵 Available audio files: $audioFiles');
      return audioFiles;
    } catch (e) {
      print('❌ Error listing audio files: $e');
      return [];
    }
  }
}
