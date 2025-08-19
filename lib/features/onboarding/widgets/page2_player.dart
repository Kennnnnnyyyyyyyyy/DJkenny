import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../audio/audio_session_helper.dart';
import '../data/onboarding_data.dart';

class Page2Player extends ConsumerStatefulWidget {
  const Page2Player({super.key});
  @override
  ConsumerState<Page2Player> createState() => _Page2PlayerState();
}

class _Page2PlayerState extends ConsumerState<Page2Player> {
  final _player = AudioPlayer();
  List<Track> _tracks = [];
  int _curr = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _tracks = await ref.read(page2TracksProvider.future);
    if (_tracks.isNotEmpty) {
      // Ensure proper audio session before loading
      await ensurePlaybackSession();
      await _player.setUrl(_tracks.first.url.toString());
    }
  }

  Future<void> _toggle() async =>
      _player.playing ? _player.pause() : _player.play();

  Future<void> _skip(int dir) async {
    if (_tracks.isEmpty) return;
    _curr = (_curr + dir + _tracks.length) % _tracks.length;
    // Ensure proper audio session before loading
    await ensurePlaybackSession();
    await _player.setUrl(_tracks[_curr].url.toString());
    _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _tracks.isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.skip_previous),
                   onPressed: ready ? () => _skip(-1) : null),
        IconButton(icon: Icon(_player.playing ? Icons.pause : Icons.play_arrow),
                   onPressed: ready ? _toggle : null),
        IconButton(icon: const Icon(Icons.skip_next),
                   onPressed: ready ? () => _skip(1) : null),
      ],
    );
  }
}
