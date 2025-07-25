import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/suno_payload.dart';
import '../models/song.dart';

class MusicGenerationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  /// Generate music track using Supabase Edge Function
  Future<Map<String, dynamic>> generateTrack({
    required String prompt,
    required String modelLabel,
    required bool isCustomMode,
    required bool instrumentalToggle,
    required String styleInput,
    String title = '',
    String negativeTags = '',
  }) async {
    try {
      // Ensure user is authenticated
      if (!_authService.isAuthenticated) {
        await _authService.signInAnonymously();
      }

      final currentUserId = _authService.currentUserId;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('User not authenticated - cannot generate track');
      }

      // Build the payload using the existing suno_payload service (for Suno API only)
      final sunoPayload = buildSunoPayload(
        prompt: prompt,
        modelLabel: modelLabel,
        isCustomMode: isCustomMode,
        instrumentalToggle: instrumentalToggle,
        styleInput: styleInput,
        title: title,
        negativeTags: negativeTags,
      );

      // Create the complete payload for Edge Function
      // This includes both Suno parameters AND user metadata
      final edgeFunctionPayload = {
        // Suno API parameters
        ...sunoPayload,
        
        // User metadata (NOT sent to Suno API)
        'user_id': currentUserId,
        'user_metadata': {
          'user_id': currentUserId,
          'timestamp': DateTime.now().toIso8601String(),
        }
      };

      print('🎵 Calling supabase-suno Edge Function');
      print('   User ID: $currentUserId');
      print('   Suno Payload: $sunoPayload');
      print('   Full Edge Function Payload: $edgeFunctionPayload');
      print('   JWT TOKEN: ${_authService.accessToken}');

      // Call the Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'supabase-suno',
        body: edgeFunctionPayload,
        headers: {
          'Authorization': 'Bearer ${_authService.accessToken ?? ''}',
          'Content-Type': 'application/json',
        },
      );

      print('🎵 Edge Function Response: ${response.data}');

      // ✅ Updated handling: Works with new backend response
      final data = response.data;
      final bool successFlag = data is Map && data['success'] == true;

      if (successFlag || response.status == 200 || response.status == 202) {
        return {
          'success': true,
          'message': data['message'] ?? 'Track generation started!',
          'task_id': data['task_id'],
          'user_id': currentUserId,
        };
      } else {
        return {
          'success': false,
          'message': data?['error'] ?? 'Generation failed. Please try again.',
          'error': data,
        };
      }
    } catch (e) {
      print('❌ Music Generation Error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Something went wrong. Please check your connection.',
      };
    }
  }

  /// Check track generation status (assuming same function handles status checks)
  Future<Map<String, dynamic>> checkTrackStatus(String trackId) async {
    try {
      final response = await _supabase.functions.invoke(
        'supabase-suno',
        body: {'action': 'check_status', 'track_id': trackId},
        headers: {
          'Authorization': 'Bearer ${_authService.accessToken ?? ''}',
          'Content-Type': 'application/json',
        },
      );

      if (response.status == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to check status: ${response.data}',
        };
      }
    } catch (e) {
      print('❌ Status Check Error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get user's generated tracks from database (legacy method - use getUserLibrarySongs for better filtering)
  Future<List<Map<String, dynamic>>> getUserTracks() async {
    try {
      // Delegate to the new user library method for consistency
      final songs = await getUserLibrarySongs();
      return songs.map((song) => {
        'id': song.id,
        'user_id': song.userId,
        'title': song.title,
        'public_url': song.publicUrl,
        'style': song.style.join(','),
        'instrumental': song.instrumental,
        'model': song.model,
      }).toList();
    } catch (e) {
      print('❌ Get User Tracks Error: $e');
      return [];
    }
  }

  /// Subscribe to track updates for real-time status changes
  Stream<List<Map<String, dynamic>>> trackUpdatesStream() {
    try {
      if (!_authService.isAuthenticated || _authService.currentUserId == null) {
        print('❌ trackUpdatesStream: User not authenticated');
        return Stream.value([]);
      }

      print('🎵 trackUpdatesStream: Setting up stream for user ${_authService.currentUserId}');
      
      return _supabase
          .from('tracks')
          .stream(primaryKey: ['id'])
          .eq('user_id', _authService.currentUserId!)
          .order('created_at', ascending: false)
          .handleError((error) {
            print('❌ trackUpdatesStream error: $error');
            return [];
          });
    } catch (e) {
      print('❌ trackUpdatesStream setup error: $e');
      return Stream.error(e);
    }
  }

  /// Get explore songs with specific apiboxfiles URL format
  Future<List<Song>> getExploreSongs({int limit = 50}) async {
    try {
      print('🔍 Fetching explore songs with apiboxfiles URLs...');
      
      final response = await _supabase
          .from('songs')
          .select('*')
          .not('public_url', 'is', null)
          .not('public_url', 'eq', '')
          .like('public_url', '%apiboxfiles.erweima.ai%')
          .order('created_at', ascending: false)
          .limit(limit);

      print('📊 Raw explore response: $response');

      if (response.isEmpty) {
        print('❌ Empty response from explore query');
        return [];
      }

      final songs = (response as List).map((track) {
        try {
          return Song.fromMap(track);
        } catch (e) {
          print('❌ Error converting track to Song: $e');
          print('📊 Problematic track data: $track');
          return null;
        }
      }).where((song) => song != null).cast<Song>().toList();

      print('✅ Processed ${songs.length} explore songs');
      
      // Double-check that all songs have the specific URL format
      final validSongs = songs.where((song) => 
        song.publicUrl.isNotEmpty && 
        song.publicUrl.contains('apiboxfiles.erweima.ai')
      ).toList();
      
      print('✅ Found ${validSongs.length} songs with valid apiboxfiles URLs');
      
      return validSongs;
    } catch (e) {
      print('❌ Error fetching explore songs: $e');
      return [];
    }
  }

  /// Get songs for the current user's library (user-specific)
  Future<List<Song>> getUserLibrarySongs({int limit = 100}) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null || currentUserId.isEmpty) {
        print('❌ No authenticated user found');
        return [];
      }

      print('🔍 Fetching library songs for user: $currentUserId');
      
      final response = await _supabase
          .from('songs')
          .select('*')
          .eq('user_id', currentUserId)
          .not('public_url', 'is', null)
          .not('public_url', 'eq', '')
          .like('public_url', '%apiboxfiles.erweima.ai%')
          .order('created_at', ascending: false)
          .limit(limit);

      print('📊 Raw library response for user $currentUserId: $response');

      if (response.isEmpty) {
        print('❌ Empty response from library query');
        return [];
      }

      final songs = (response as List).map((track) {
        try {
          return Song.fromMap(track);
        } catch (e) {
          print('❌ Error converting track to Song: $e');
          print('📊 Problematic track data: $track');
          return null;
        }
      }).where((song) => song != null).cast<Song>().toList();

      print('✅ Processed ${songs.length} library songs for user $currentUserId');
      
      // Double-check that all songs belong to current user and have valid URLs
      final validSongs = songs.where((song) => 
        song.publicUrl.isNotEmpty && 
        song.publicUrl.contains('apiboxfiles.erweima.ai') &&
        song.userId == currentUserId
      ).toList();
      
      print('✅ Found ${validSongs.length} valid library songs for user $currentUserId');
      
      return validSongs;
    } catch (e) {
      print('❌ Error fetching library songs: $e');
      return [];
    }
  }
}
