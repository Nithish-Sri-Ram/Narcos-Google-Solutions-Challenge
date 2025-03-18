class ChatModel {
  final String? chatId;
  final String title;
  final String useremail;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;

  ChatModel({
    this.chatId,
    required this.title,
    required this.useremail,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessagePreview,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chat_id'],
      title: json['title'],
      useremail: json['username'],
      createdAt: DateTime.parse(json['created_at']),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      lastMessagePreview: json['last_message_preview'],
    );
  }
}