import '../../../data/models/onboarding_track.dart';

/// Domain model for a music track
class Track {
  final String id;
  final String title;
  final String audioUrl;
  final String? coverUrl;
  final String? mood;
  final String? genre;
  final String? subject;
  final int? listIndex;

  const Track({
    required this.id,
    required this.title,
    required this.audioUrl,
    this.coverUrl,
    this.mood,
    this.genre,
    this.subject,
    this.listIndex,
  });

  /// Create Track from OnboardingTrackModel
  factory Track.fromOnboardingTrack(OnboardingTrackModel model) {
    return Track(
      id: model.id,
      title: model.title,
      audioUrl: model.publicUrl,
      coverUrl: model.coverUrl,
      mood: model.mood,
      genre: model.genre,
      subject: model.topic,
      listIndex: model.listIndex,
    );
  }

  /// Create Track from JSON
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      audioUrl: json['audio_url']?.toString() ?? json['public_url']?.toString() ?? '',
      coverUrl: json['cover_url']?.toString(),
      mood: json['mood']?.toString(),
      genre: json['genre']?.toString(),
      subject: json['subject']?.toString() ?? json['topic']?.toString(),
      listIndex: json['list_index'] != null ? (json['list_index'] as num).toInt() : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'audio_url': audioUrl,
      'cover_url': coverUrl,
      'mood': mood,
      'genre': genre,
      'subject': subject,
      'list_index': listIndex,
    };
  }

  /// Create a copy with updated values
  Track copyWith({
    String? id,
    String? title,
    String? audioUrl,
    String? coverUrl,
    String? mood,
    String? genre,
    String? subject,
    int? listIndex,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      mood: mood ?? this.mood,
      genre: genre ?? this.genre,
      subject: subject ?? this.subject,
      listIndex: listIndex ?? this.listIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          audioUrl == other.audioUrl;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ audioUrl.hashCode;

  @override
  String toString() {
    return 'Track(id: $id, title: $title, audioUrl: $audioUrl, mood: $mood, genre: $genre, subject: $subject)';
  }
}
