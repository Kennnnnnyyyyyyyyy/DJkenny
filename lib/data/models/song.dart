class Song {
  final String id;
  final String? title;
  final String? publicUrl;
  final String? coverUrl;
  final String? prompt;
  final String? modelName;
  final int? likes;
  final int? plays;

  Song({
    required this.id,
    this.title,
    this.publicUrl,
    this.coverUrl,
    this.prompt,
    this.modelName,
    this.likes,
    this.plays,
  });

  factory Song.fromJson(Map<String, dynamic> j) => Song(
        id: j['id'] as String,
        title: j['title'] as String?,
        publicUrl: j['public_url'] as String?,
        coverUrl: j['cover_url'] as String?,
        prompt: j['prompt'] as String?,
        modelName: j['model_name'] as String?,
        likes: (j['likes'] as num?)?.toInt(),
        plays: (j['plays'] as num?)?.toInt(),
      );
}
