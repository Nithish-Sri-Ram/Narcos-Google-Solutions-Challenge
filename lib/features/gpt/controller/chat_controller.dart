import 'package:drug_discovery/config.dart';
import 'package:drug_discovery/models/chat_model.dart';
import 'package:drug_discovery/models/message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final chatControllerProvider =
    StateNotifierProvider<ChatController, List<ChatModel>>((ref) {
  return ChatController();
});

class ChatController extends StateNotifier<List<ChatModel>> {
  ChatController() : super([]);

  List<ChatModel> cachedChats = [];

  Future<String> createNewChat(ChatModel newChat) async {
    const String url = '$v1/chats';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": newChat.useremail,
          "title": newChat.title,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final String chatId = responseData["chat_id"];

        ChatModel createdChat = ChatModel(
          chatId: chatId,
          title: newChat.title,
          useremail: newChat.useremail,
          createdAt: DateTime.now(),
          lastMessageAt: null,
          lastMessagePreview: null,
        );

        cachedChats.insert(0, createdChat);
        state = List.from(cachedChats);

        return chatId;
      } else {
        throw Exception('Failed to create chat: ${response.body}');
      }
    } catch (e) {
      print('Error creating chat: $e');
      return '';
    }
  }

  Future<List<ChatModel>> getUserChats(String useremail) async {
    if (cachedChats.isNotEmpty) {
      return cachedChats;
    }

    final String url = '$v1/users/$useremail/chats';

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
        cachedChats = chats;
        state = chats;
        return chats;
      } else {
        throw Exception('Failed to fetch chats: ${response.body}');
      }
    } catch (e) {
      print('Error fetching chats: $e');
      return [];
    }
  }

  Future<String> sendChatMessage(MessageModel message) async {
    const String url = '$v1/chat';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "chat_id": message.chatId,
          "message": message.content,
          "ml_activated": message.mlActivated,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData["response"];
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
      return '';
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
