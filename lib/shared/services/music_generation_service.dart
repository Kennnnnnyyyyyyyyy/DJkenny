import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/suno_payload.dart';

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

      // Build the payload using the existing suno_payload service
      final payload = buildSunoPayload(
        prompt: prompt,
        modelLabel: modelLabel,
        isCustomMode: isCustomMode,
        instrumentalToggle: instrumentalToggle,
        styleInput: styleInput,
        title: title,
        negativeTags: negativeTags,
      );

      // Add user ID to payload
      payload['user_id'] = _authService.currentUserId;

      print('🎵 Calling supabase-suno Edge Function with payload: $payload');

      // Call the Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'supabase-suno',
        body: payload,
        headers: {
          'Authorization': 'Bearer ${_authService.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      print('🎵 Edge Function Response: ${response.data}');

      if (response.status == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Track generation started successfully!',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to generate track: ${response.data}',
          'message': 'Generation failed. Please try again.',
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
          'Authorization': 'Bearer ${_authService.accessToken}',
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

  /// Get user's generated tracks from database
  Future<List<Map<String, dynamic>>> getUserTracks() async {
    try {
      if (!_authService.isAuthenticated) {
        return [];
      }

      final response = await _supabase
          .from('tracks')
          .select('*')
          .eq('user_id', _authService.currentUserId!)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Get User Tracks Error: $e');
      return [];
    }
  }

  /// Subscribe to track updates for real-time status changes
  Stream<List<Map<String, dynamic>>> trackUpdatesStream() {
    if (!_authService.isAuthenticated) {
      return Stream.value([]);
    }

    return _supabase
        .from('tracks')
        .stream(primaryKey: ['id'])
        .eq('user_id', _authService.currentUserId!)
        .order('created_at', ascending: false);
  }
}
