import 'package:supabase_flutter/supabase_flutter.dart';
import 'realtime.dart';
import '../models/song.dart';

Future<void> bootstrapLists() async {
  final supa = Supabase.instance.client;
  final user = supa.auth.currentUser;
  
  // Load public songs for explore
  explore
    ..clear()
    ..addAll(await supa.from('songs')
        .select()
        .eq('status', 'ready')
        .order('created_at', ascending: false)
        .limit(50)
        .withConverter(Song.listFromJson));

  // Load user's songs for library (only if authenticated)
  if (user != null) {
    library
      ..clear()
      ..addAll(await supa.from('songs')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .withConverter(Song.listFromJson));
  }
}
