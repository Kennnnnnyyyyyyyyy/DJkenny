# Supabase ⇄ Suno integration – Flutter code guide

Copy‑paste (or let Copilot apply) each block exactly where noted. After this patch your app will generate, store, and stream tracks end‑to‑end.

---

## 1  pubspec.yaml – add required packages

```yaml
dependencies:
  supabase_flutter: ^2.5.3   # Supabase client + realtime + edge functions
  just_audio:       ^0.9.36  # MP3 playback
  flutter_riverpod: ^2.5.1   # light state‑management (optional)
```

Run **flutter pub get**.

---

## 2  Environment variables at build/run

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_ANON=<anon-key>
```

*(SUPABASE\_FUNCTIONS\_URL is only needed inside the edge functions.)*

---

## 3  lib/main.dart – initialise Supabase + bootstrap lists

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'shared/services/realtime.dart';
import 'shared/services/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON'),
  );

  initRealtime();      // opens WebSocket channel
  await bootstrapLists(); // pulls existing rows once

  runApp(const MyApp());
}
```

Remove any older `runApp`‑only main.

---

## 4  NEW file → lib/shared/models/song.dart

```dart
class Song {
  final String id, userId, title, publicUrl;
  final List<String> style;
  final bool instrumental;
  final String model;

  Song.fromMap(Map<String, dynamic> m)
      : id           = m['id'],
        userId       = m['user_id'],
        title        = (m['title'] ?? 'Untitled') as String,
        publicUrl    = m['public_url'] as String,
        style        = (m['style'] ?? '')
                        .split(',')
                        .where((s) => s.trim().isNotEmpty)
                        .toList(),
        instrumental = m['instrumental'] ?? false,
        model        = m['model'] ?? 'V3_5';

  static List<Song> listFromJson(List<dynamic> rows) =>
      rows.map((e) => Song.fromMap(e as Map<String, dynamic>)).toList();
}
```

---

## 5  NEW file → lib/shared/services/suno\_payload.dart

```dart
Map<String, dynamic> buildSunoPayload({
  required String prompt,
  required String modelLabel,        // "Melo 3.5" | "Melo 4" | "Melo 4.5"
  required bool isCustomMode,
  required bool instrumentalToggle,  // switch value (ignored in custom)
  required String styleInput,        // textbox in custom, blank in simple
  String title = '',
  String negativeTags = '',
}) {
  const modelMap = {
    'Melo 3.5': 'V3_5',
    'Melo 4'  : 'V4_0',
    'Melo 4.5': 'V4_5',
  };

  return {
    'prompt'      : prompt,
    'style'       : isCustomMode ? styleInput : prompt,
    'title'       : title,
    'customMode'  : isCustomMode,
    'instrumental': isCustomMode ? false : instrumentalToggle,
    'model'       : modelMap[modelLabel] ?? 'V3_5',
    'negativeTags': negativeTags,
  };
}
```

---

## 6  NEW file → lib/shared/services/realtime.dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';

final explore = <Song>[];
final library = <Song>[];

void initRealtime() {
  final supa = Supabase.instance.client;
  final myUid = supa.auth.currentUser!.id;

  supa.channel('songs-feed')
    ..onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table:  'songs',
      callback: (payload) {
        final row = Song.fromMap(payload.newRecord!);
        explore.insert(0, row);
        if (row.userId == myUid) library.insert(0, row);
      },
    )
    ..subscribe();
}
```

---

## 7  NEW file → lib/shared/services/bootstrap.dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'realtime.dart';
import '../models/song.dart';

Future<void> bootstrapLists() async {
  final supa = Supabase.instance.client;
  final myUid = supa.auth.currentUser!.id;

  explore
    ..clear()
    ..addAll(await supa.from('songs')
        .select()
        .eq('status', 'ready')
        .order('created_at', ascending: false)
        .limit(50)
        .withConverter(Song.listFromJson));

  library
    ..clear()
    ..addAll(await supa.from('songs')
        .select()
        .eq('user_id', myUid)
        .order('created_at', ascending: false)
        .withConverter(Song.listFromJson));
}
```

---

## 8  NEW widget → lib/shared/widgets/track\_card.dart

```dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../shared/models/song.dart';

class TrackCard extends StatelessWidget {
  final Song song;
  const TrackCard(this.song, {super.key});

  @override
  Widget build(BuildContext context) {
    final player = AudioPlayer()..setUrl(song.publicUrl);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(song.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ControlButtons(player),  // from just_audio package
          ],
        ),
      ),
    );
  }
}
```

---

## 9  lib/features/explore/views/explore\_page.dart – swap data source

```diff
- final songs = [...placeholder list...];
+ import 'package:your_app/shared/services/realtime.dart';
+
  @override
  Widget build(BuildContext context) {
-   final song = songs[index];
+   final song = explore[index];
```

Convert to **StatefulWidget** if hot‑reload complains.

---

## 10  lib/features/library/views/library\_page.dart – real data

Similar edit:

```diff
+ import 'package:your_app/shared/services/realtime.dart';
...
- if (/* placeholder condition */)
-   return ...
+ if (library.isEmpty)
+   return Center(child: Text('No songs yet'));
+
+ return GridView.extent(
+   maxCrossAxisExtent: 280,
+   children: library.map(TrackCard.new).toList(),
+ );
```

---

## 11  Create button logic (where prompt & knobs live)

Locate the `onTap` of the **Create / gradient\_cta\_button** parent widget:

```dart
final payload = buildSunoPayload(
  prompt            : promptCtr.text,
  modelLabel        : modelDropdownValue,
  isCustomMode      : currentTab == Tab.custom,
  instrumentalToggle: instrumentalSwitchValue,
  styleInput        : styleTextCtr.text,
  title             : titleCtr.text,
  negativeTags      : negativeTagsCtr.text,
);

await Supabase.instance.client.functions
        .invoke('generate-track', body: payload);

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('🎵  Generating…')),
);
```

*Delete any Postman or HTTP code previously there.*

---

### Done ✔

After these changes:

1. **Create** button calls `generate-track` edge function.
2. Suno generates ➜ `suno-callback` uploads MP3 & inserts row.
3. Realtime pushes the row ➜ new `TrackCard` pops into **Explore** & **Library**.
4. User taps ▶︎ to stream directly from Supabase Storage.

Your Flutter codebase is now fully wired to Supabase + Suno. Happy shipping! 🚀

