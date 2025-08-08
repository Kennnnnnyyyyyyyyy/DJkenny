/// Immutable model representing an onboarding track from Supabase
class OnboardingTrack {
  final String id;
  final String pageTag;
  final int listIndex;
  final String title;
  final String publicUrl;
  final String mood;
  final String genre;
  final String topic;

  const OnboardingTrack({
    required this.id,
    required this.pageTag,
    required this.listIndex,
    required this.title,
    required this.publicUrl,
    required this.mood,
    required this.genre,
    required this.topic,
  });

  /// Creates an OnboardingTrack from a Supabase row map
  factory OnboardingTrack.fromMap(Map<String, dynamic> map) {
    return OnboardingTrack(
      id: map['id'] as String,
      pageTag: map['page_tag'] as String,
      listIndex: map['list_index'] as int,
      title: map['title'] as String,
      publicUrl: map['public_url'] as String,
      mood: map['mood'] as String,
      genre: map['genre'] as String,
      topic: map['topic'] as String,
    );
  }

  @override
  String toString() {
    return 'OnboardingTrack(id: $id, pageTag: $pageTag, listIndex: $listIndex, '
        'title: $title, publicUrl: $publicUrl, mood: $mood, genre: $genre, topic: $topic)';
  }
}
