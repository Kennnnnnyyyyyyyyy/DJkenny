import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/logging/logger.dart';
import '../../domain/models/user.dart' as domain;

/// Repository for authentication operations
class AuthRepository {
  final SupabaseClient supabase;
  late final StreamController<domain.User?> _userController;

  AuthRepository({required this.supabase}) {
    _userController = StreamController<domain.User?>.broadcast();
    _init();
  }

  void _init() {
    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        _userController.add(domain.User.fromSupabaseUser(user));
        Logger.i('User authenticated: ${user.email}', tag: 'AUTH');
      } else {
        _userController.add(null);
        Logger.i('User signed out', tag: 'AUTH');
      }
    });
  }

  /// Stream of authentication state changes
  Stream<domain.User?> get onAuthStateChanged => _userController.stream;

  /// Current authenticated user
  domain.User? get currentUser {
    final user = supabase.auth.currentUser;
    return user != null ? domain.User.fromSupabaseUser(user) : null;
  }

  /// Sign in with email and password
  Future<Result<domain.User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Logger.i('Attempting sign in for: $email', tag: 'AUTH');

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Result.failure(AppException.auth('Sign in failed: No user returned'));
      }

      final user = domain.User.fromSupabaseUser(response.user!);
      Logger.i('Sign in successful for user: ${user.id}', tag: 'AUTH');
      
      return Result.success(user);
    } catch (e, st) {
      Logger.e('Sign in failed', error: e, stackTrace: st, tag: 'AUTH');
      return Result.failure(AppException.auth('Sign in failed: ${e.toString()}', cause: e, stackTrace: st));
    }
  }

  /// Sign up with email and password
  Future<Result<domain.User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      Logger.i('Attempting sign up for: $email', tag: 'AUTH');

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      if (response.user == null) {
        return Result.failure(AppException.auth('Sign up failed: No user returned'));
      }

      final user = domain.User.fromSupabaseUser(response.user!);
      Logger.i('Sign up successful for user: ${user.id}', tag: 'AUTH');
      
      return Result.success(user);
    } catch (e, st) {
      Logger.e('Sign up failed', error: e, stackTrace: st, tag: 'AUTH');
      return Result.failure(AppException.auth('Sign up failed: ${e.toString()}', cause: e, stackTrace: st));
    }
  }

  /// Sign out
  Future<Result<void>> signOut() async {
    try {
      Logger.i('Attempting sign out', tag: 'AUTH');
      await supabase.auth.signOut();
      Logger.i('Sign out successful', tag: 'AUTH');
      return Result.success(null);
    } catch (e, st) {
      Logger.e('Sign out failed', error: e, stackTrace: st, tag: 'AUTH');
      return Result.failure(AppException.auth('Sign out failed: ${e.toString()}', cause: e, stackTrace: st));
    }
  }

  /// Reset password
  Future<Result<void>> resetPassword({required String email}) async {
    try {
      Logger.i('Attempting password reset for: $email', tag: 'AUTH');
      
      await supabase.auth.resetPasswordForEmail(email);
      
      Logger.i('Password reset email sent', tag: 'AUTH');
      return Result.success(null);
    } catch (e, st) {
      Logger.e('Password reset failed', error: e, stackTrace: st, tag: 'AUTH');
      return Result.failure(AppException.auth('Password reset failed: ${e.toString()}', cause: e, stackTrace: st));
    }
  }

  /// Update user profile
  Future<Result<domain.User>> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      Logger.i('Attempting profile update', tag: 'AUTH');

      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await supabase.auth.updateUser(
        UserAttributes(data: updates),
      );

      if (response.user == null) {
        return Result.failure(AppException.auth('Profile update failed: No user returned'));
      }

      final user = domain.User.fromSupabaseUser(response.user!);
      Logger.i('Profile update successful', tag: 'AUTH');
      
      return Result.success(user);
    } catch (e, st) {
      Logger.e('Profile update failed', error: e, stackTrace: st, tag: 'AUTH');
      return Result.failure(AppException.auth('Profile update failed: ${e.toString()}', cause: e, stackTrace: st));
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => supabase.auth.currentUser != null;

  /// Dispose resources
  void dispose() {
    _userController.close();
  }
}
