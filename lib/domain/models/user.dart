import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Domain model for a user
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Create User from Supabase User
  factory User.fromSupabaseUser(supabase.User user) {
    return User(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name']?.toString() ?? 
                  user.userMetadata?['full_name']?.toString(),
      avatarUrl: user.userMetadata?['avatar_url']?.toString(),
      emailVerifiedAt: user.emailConfirmedAt != null 
          ? DateTime.tryParse(user.emailConfirmedAt!)
          : null,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      updatedAt: user.updatedAt != null 
          ? DateTime.tryParse(user.updatedAt!) ?? DateTime.now()
          : DateTime.now(),
      metadata: user.userMetadata,
    );
  }

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? json['full_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.tryParse(json['email_verified_at'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated values
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get initials for avatar
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  /// Check if email is verified
  bool get isEmailVerified => emailVerifiedAt != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, verified: $isEmailVerified)';
  }
}
