import 'package:flutter/material.dart';

/// Type of chat message
enum MessageType {
  text,
  choices,
  creating,
  songCreated,
  upgrade,
  payment,
}

/// Model for chat messages in onboarding
class ChatMessage {
  final String id;
  final String text;
  final bool isFromUser;
  final MessageType type;
  final List<String>? choices;
  final GlobalKey key;
  final DateTime timestamp;

  ChatMessage({
    String? id,
    required this.text,
    required this.isFromUser,
    required this.type,
    this.choices,
    GlobalKey? key,
    DateTime? timestamp,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        key = key ?? GlobalKey(),
        timestamp = timestamp ?? DateTime.now();

  /// Create a text message from user
  factory ChatMessage.userText(String text) => ChatMessage(
        text: text,
        isFromUser: true,
        type: MessageType.text,
      );

  /// Create a text message from system
  factory ChatMessage.systemText(String text) => ChatMessage(
        text: text,
        isFromUser: false,
        type: MessageType.text,
      );

  /// Create a choices message
  factory ChatMessage.choices(List<String> choices) => ChatMessage(
        text: '',
        isFromUser: false,
        type: MessageType.choices,
        choices: choices,
      );

  /// Create a creating message
  factory ChatMessage.creating() => ChatMessage(
        text: '',
        isFromUser: false,
        type: MessageType.creating,
      );

  /// Create a song created message
  factory ChatMessage.songCreated() => ChatMessage(
        text: '',
        isFromUser: false,
        type: MessageType.songCreated,
      );

  /// Create an upgrade message
  factory ChatMessage.upgrade() => ChatMessage(
        text: '',
        isFromUser: false,
        type: MessageType.upgrade,
      );

  /// Create a payment message
  factory ChatMessage.payment() => ChatMessage(
        text: '',
        isFromUser: false,
        type: MessageType.payment,
      );

  /// Create a copy with updated values
  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isFromUser,
    MessageType? type,
    List<String>? choices,
    GlobalKey? key,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isFromUser: isFromUser ?? this.isFromUser,
      type: type ?? this.type,
      choices: choices ?? this.choices,
      key: key ?? this.key,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          isFromUser == other.isFromUser &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^
      text.hashCode ^
      isFromUser.hashCode ^
      type.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, text: "$text", isFromUser: $isFromUser, type: $type)';
  }
}
