class MessageModel {
  final String id;
  final String chatId;
  final String role;
  final String content;
  final DateTime createdAt;
  final bool mlActivated;
  final Map<String, dynamic> parameters;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.role,
    required this.content,
    required this.createdAt,
    required this.mlActivated,
    required this.parameters,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      chatId: json['chat_id'],
      role: json['role'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      mlActivated: json['ml_activated'],
      parameters: json['parameters'] ?? {},
    );
  }
}
