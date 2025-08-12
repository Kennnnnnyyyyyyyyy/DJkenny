class OnboardingTrackModel {
  final String id;
  final String title;
  final String publicUrl;
  final String? coverUrl;
  final String pageTag;
  final String? mood;
  final String? genre;
  final String? topic;
  final int listIndex;
  OnboardingTrackModel({
    required this.id,
    required this.title,
    required this.publicUrl,
    this.coverUrl,
    required this.pageTag,
    required this.listIndex,
    this.mood,
    this.genre,
    this.topic,
  });

  factory OnboardingTrackModel.fromJson(Map<String, dynamic> j) => OnboardingTrackModel(
        id: j['id'] as String,
        title: j['title'] as String,
        publicUrl: j['public_url'] as String,
        coverUrl: j['cover_url'] as String?,
        pageTag: j['page_tag'] as String,
        listIndex: (j['list_index'] as num).toInt(),
        mood: j['mood'] as String?,
        genre: j['genre'] as String?,
        topic: j['topic'] as String?,
      );
}
