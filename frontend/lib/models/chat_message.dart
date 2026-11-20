class ChatMessage {
  final String id;
  final String consultationId;
  final String senderId;
  final String content;
  final bool isRead;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.consultationId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      consultationId: json['consultation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      content: json['content'] ?? '',
      isRead: json['is_read'] ?? true,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}
