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
