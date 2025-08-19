import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logging/logger.dart';
import '../../../domain/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/di.dart';

/// State for authentication
class AuthState {
  final AsyncValue<User?> user;
  final bool isLoading;
  final String? error;

  const AuthState({
    required this.user,
    required this.isLoading,
    this.error,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState(
        user: AsyncValue.loading(),
        isLoading: false,
        error: null,
      );

  /// Create a copy with updated values
  AuthState copyWith({
    AsyncValue<User?>? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Clear error
  AuthState clearError() => copyWith(error: null);

  /// Check if user is authenticated
  bool get isAuthenticated => user.value != null;

  /// Check if authentication is loading
  bool get isAuthLoading => user.isLoading || isLoading;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => user.hashCode ^ isLoading.hashCode ^ error.hashCode;

  @override
  String toString() {
    return 'AuthState(user: ${user.value?.email ?? 'null'}, isLoading: $isLoading, error: $error)';
  }
}

/// ViewModel for authentication functionality
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthViewModel(this._authRepository) : super(AuthState.initial()) {
    _initializeAuthListener();
    _checkCurrentUser();
  }

  void _initializeAuthListener() {
    Logger.d('Initializing auth state listener', tag: 'AUTH_VM');
    
    _authSubscription = _authRepository.onAuthStateChanged.listen(
      (user) {
        Logger.state('Auth state changed: ${user?.email ?? 'signed out'}', tag: 'AUTH_VM');
        state = state.copyWith(user: AsyncValue.data(user));
      },
      onError: (error, stackTrace) {
        Logger.e('Auth state stream error', error: error, stackTrace: stackTrace, tag: 'AUTH_VM');
        state = state.copyWith(user: AsyncValue.error(error, stackTrace));
      },
    );
  }

  void _checkCurrentUser() {
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      Logger.i('Found existing user session: ${currentUser.email}', tag: 'AUTH_VM');
      state = state.copyWith(user: AsyncValue.data(currentUser));
    } else {
      Logger.i('No existing user session', tag: 'AUTH_VM');
      state = state.copyWith(user: const AsyncValue.data(null));
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Logger.i('Attempting sign in', tag: 'AUTH_VM');
      state = state.copyWith(isLoading: true, error: null);

      final result = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      result.fold(
        (error) {
          Logger.e('Sign in failed', error: error, tag: 'AUTH_VM');
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
        },
        (user) {
          Logger.i('Sign in successful: ${user.email}', tag: 'AUTH_VM');
          state = state.copyWith(
            isLoading: false,
            user: AsyncValue.data(user),
          );
        },
      );
    } catch (e, st) {
      Logger.e('Unexpected error during sign in', error: e, stackTrace: st, tag: 'AUTH_VM');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      Logger.i('Attempting sign up', tag: 'AUTH_VM');
      state = state.copyWith(isLoading: true, error: null);

      final result = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      result.fold(
        (error) {
          Logger.e('Sign up failed', error: error, tag: 'AUTH_VM');
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
        },
        (user) {
          Logger.i('Sign up successful: ${user.email}', tag: 'AUTH_VM');
          state = state.copyWith(
            isLoading: false,
            user: AsyncValue.data(user),
          );
        },
      );
    } catch (e, st) {
      Logger.e('Unexpected error during sign up', error: e, stackTrace: st, tag: 'AUTH_VM');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      Logger.i('Attempting sign out', tag: 'AUTH_VM');
      state = state.copyWith(isLoading: true, error: null);

      final result = await _authRepository.signOut();

      result.fold(
        (error) {
          Logger.e('Sign out failed', error: error, tag: 'AUTH_VM');
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
        },
        (_) {
          Logger.i('Sign out successful', tag: 'AUTH_VM');
          state = state.copyWith(
            isLoading: false,
            user: const AsyncValue.data(null),
          );
        },
      );
    } catch (e, st) {
      Logger.e('Unexpected error during sign out', error: e, stackTrace: st, tag: 'AUTH_VM');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      Logger.i('Attempting password reset', tag: 'AUTH_VM');
      state = state.copyWith(isLoading: true, error: null);

      final result = await _authRepository.resetPassword(email: email);

      result.fold(
        (error) {
          Logger.e('Password reset failed', error: error, tag: 'AUTH_VM');
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
        },
        (_) {
          Logger.i('Password reset email sent', tag: 'AUTH_VM');
          state = state.copyWith(isLoading: false);
        },
      );
    } catch (e, st) {
      Logger.e('Unexpected error during password reset', error: e, stackTrace: st, tag: 'AUTH_VM');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      Logger.i('Attempting profile update', tag: 'AUTH_VM');
      state = state.copyWith(isLoading: true, error: null);

      final result = await _authRepository.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );

      result.fold(
        (error) {
          Logger.e('Profile update failed', error: error, tag: 'AUTH_VM');
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
        },
        (user) {
          Logger.i('Profile update successful', tag: 'AUTH_VM');
          state = state.copyWith(
            isLoading: false,
            user: AsyncValue.data(user),
          );
        },
      );
    } catch (e, st) {
      Logger.e('Unexpected error during profile update', error: e, stackTrace: st, tag: 'AUTH_VM');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.clearError();
  }

  @override
  void dispose() {
    Logger.d('Disposing AuthViewModel', tag: 'AUTH_VM');
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for AuthViewModel
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});
