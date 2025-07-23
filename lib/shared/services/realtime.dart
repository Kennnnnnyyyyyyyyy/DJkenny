import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';

final explore = <Song>[];
final library = <Song>[];

void initRealtime() {
  final supa = Supabase.instance.client;
  final user = supa.auth.currentUser;

  supa.channel('tracks-feed')
    // Listen for new tracks being inserted
    ..onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'tracks',
      callback: (payload) {
        final row = Song.fromMap(payload.newRecord);
        explore.insert(0, row);
        if (user != null && row.userId == user.id) library.insert(0, row);
        print('🎵 Realtime: New track inserted - ${row.title}');
      },
    )
    // Listen for tracks being updated (e.g., when public_url is added)
    ..onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'tracks',
      callback: (payload) {
        final updatedRow = Song.fromMap(payload.newRecord);
        
        // Update in explore list
        final exploreIndex = explore.indexWhere((song) => song.id == updatedRow.id);
        if (exploreIndex != -1) {
          explore[exploreIndex] = updatedRow;
        }
        
        // Update in library list if it's the current user's song
        if (user != null && updatedRow.userId == user.id) {
          final libraryIndex = library.indexWhere((song) => song.id == updatedRow.id);
          if (libraryIndex != -1) {
            library[libraryIndex] = updatedRow;
            print('🎵 Realtime: Track updated in library - ${updatedRow.title}, URL: ${updatedRow.publicUrl.isNotEmpty ? "Available" : "Not ready"}');
          }
        }
      },
    )
    ..subscribe();
}
