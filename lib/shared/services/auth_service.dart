import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user (null if not authenticated)
  User? get currentUser => _supabase.auth.currentUser;

  /// Get current user ID (null if not authenticated)
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Sign in anonymously
  Future<bool> signInAnonymously() async {
    try {
      // Check if already authenticated
      if (isAuthenticated) {
        if (kDebugMode) {
          debugPrint('✅ User already authenticated: $currentUserId');
        }
        return true;
      }

      if (kDebugMode) {
        debugPrint('🔄 Signing in anonymously...');
      }
      final response = await _supabase.auth.signInAnonymously();
      
      if (response.user != null) {
        if (kDebugMode) {
          debugPrint('✅ Anonymous authentication successful: ${response.user!.id}');
        }
        return true;
      } else {
        if (kDebugMode) {
          debugPrint('❌ Anonymous authentication failed: No user returned');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Anonymous authentication error: $e');
      }
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      if (kDebugMode) {
        debugPrint('✅ User signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Sign out error: $e');
      }
    }
  }

  /// Listen to authentication state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Get JWT token for API calls
  String? get accessToken => _supabase.auth.currentSession?.accessToken;
}
