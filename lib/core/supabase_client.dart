import 'package:supabase_flutter/supabase_flutter.dart';
import '../env.dart';
import '../bootstrap_supabase.dart' as legacy;

final supa = Supabase.instance.client;

Future<void> initSupabase() async {
  // If dart-define values are not provided, fall back to legacy bootstrap.
  final url = Env.supabaseUrl;
  final key = Env.supabaseAnonKey;
  if ((url.isEmpty) || (key.isEmpty)) {
    // Fallback for local/dev runs to avoid empty client and sample data on page 2
    await legacy.bootstrapSupabase();
    return;
  }
  await Supabase.initialize(
    url: url,
    anonKey: key,
    realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 5),
  );
}
