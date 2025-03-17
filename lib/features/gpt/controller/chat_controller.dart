import 'package:drug_discovery/config.dart';
import 'package:drug_discovery/features/auth/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final chatControllerProvider =
    StateNotifierProvider<ChatController, bool>((ref) {
  return ChatController();
});

class ChatController extends StateNotifier<bool> {
  ChatController() : super(false);

  Future<void> createNewChat(NewChatModel newChat) async {
    const String url = '$v1/chats';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": newChat.userName,
          "title": newChat.title,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = true;
      } else {
        throw Exception('Failed to create chat: ${response.body}');
      }
    } catch (e) {
      print('Error creating chat: $e');
      state = false;
    }
  }

  Future<List<ChatModel>> getUserChats() async {
    final username = userProvider.name;
    final String url = '$v1/users/$username/chats';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<ChatModel> chats = (data['chats'] as List)
            .map((chat) => ChatModel.fromJson(chat))
            .toList();
        return chats;
      } else {
        throw Exception('Failed to fetch chats: ${response.body}');
      }
    } catch (e) {
      print('Error fetching chats: $e');
      return [];
    }
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    final String url = '$v1/chats/$chatId/messages';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<MessageModel> messages = (data['messages'] as List)
            .map((msg) => MessageModel.fromJson(msg))
            .toList();
        return messages;
      } else {
        throw Exception('Failed to fetch messages: ${response.body}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }
}

class NewChatModel {
  final String userName;
  final String title;

  NewChatModel({
    required this.userName,
    required this.title,
  });
}

class ChatModel {
  final String chatId;
  final String title;
  final String username;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String lastMessagePreview;

  ChatModel({
    required this.chatId,
    required this.title,
    required this.username,
    required this.createdAt,
    required this.lastMessageAt,
    required this.lastMessagePreview,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chat_id'],
      title: json['title'],
      username: json['username'],
      createdAt: DateTime.parse(json['created_at']),
      lastMessageAt: DateTime.parse(json['last_message_at']),
      lastMessagePreview: json['last_message_preview'],
    );
  }
}

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
