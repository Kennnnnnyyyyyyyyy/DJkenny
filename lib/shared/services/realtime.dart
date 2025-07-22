import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';

final explore = <Song>[];
final library = <Song>[];

void initRealtime() {
  final supa = Supabase.instance.client;
  final user = supa.auth.currentUser;

  supa.channel('songs-feed')
    ..onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table:  'songs',
      callback: (payload) {
        final row = Song.fromMap(payload.newRecord);
        explore.insert(0, row);
        if (user != null && row.userId == user.id) library.insert(0, row);
      },
    )
    ..subscribe();
}
