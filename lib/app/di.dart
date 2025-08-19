import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/logger.dart';
import '../services/audio_service.dart';
import '../data/repositories/music_repository.dart';
import '../data/repositories/auth_repository.dart';

/// Core infrastructure providers

final loggerProvider = Provider<Logger>((ref) => Logger());

final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

/// Service providers

final audioServiceProvider = Provider<AudioService>((ref) {
  Logger.d('Creating AudioService instance', tag: 'DI');
  return AudioService();
});

/// Repository providers

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  Logger.d('Creating MusicRepository instance', tag: 'DI');
  return MusicRepository(supabase: supabase);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  Logger.d('Creating AuthRepository instance', tag: 'DI');
  return AuthRepository(supabase: supabase);
});

/// Cleanup providers when they're disposed
final class DIObserver extends ProviderObserver {
  @override
  void didDisposeProvider(ProviderBase<Object?> provider, ProviderContainer container) {
    super.didDisposeProvider(provider, container);
    
    Logger.d('Disposed provider: ${provider.runtimeType}', tag: 'DI');
  }
}
