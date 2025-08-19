import 'package:audio_session/audio_session.dart';

Future<void> ensurePlaybackSession() async {
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  await session.setActive(true);
}
