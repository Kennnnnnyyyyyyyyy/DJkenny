class Song {
  final String id, userId, title, publicUrl;
  final List<String> style;
  final bool instrumental;
  final String model;

  Song.fromMap(Map<String, dynamic> m)
      : id           = m['id'] ?? '',
        userId       = m['user_id'] ?? '',
        title        = (m['title'] ?? 'Untitled').toString(),
        publicUrl    = (m['public_url'] ?? '').toString(),
        style        = ((m['style'] ?? '') as String)
                        .split(',')
                        .where((s) => s.trim().isNotEmpty)
                        .toList(),
        instrumental = m['instrumental'] ?? false,
        model        = (m['model'] ?? 'V3_5').toString();

  static List<Song> listFromJson(List<dynamic> rows) =>
      rows.map((e) => Song.fromMap(e as Map<String, dynamic>)).toList();
}
