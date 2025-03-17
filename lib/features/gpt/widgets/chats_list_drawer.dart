import 'package:drug_discovery/core/common/error_text.dart';
import 'package:drug_discovery/core/common/loader.dart';
import 'package:drug_discovery/core/common/sign_in_button.dart';
import 'package:drug_discovery/features/auth/repository/auth_repository.dart';
import 'package:drug_discovery/features/community/controller/community_controller.dart';
import 'package:drug_discovery/features/gpt/controller/chat_controller.dart';
import 'package:drug_discovery/models/community_model.dart';
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'dart:convert';

class ChatsListDrawer extends ConsumerWidget {
  const ChatsListDrawer({super.key});

  Future<void> createNewChat(BuildContext context, WidgetRef ref) async {
    final user = ref.watch(userProvider)!;
    final chatController = ref.read(chatControllerProvider.notifier);

    final newChat = NewChatModel(
      userName: user.name,
      title: "New Chat", // Default title
    );

    await chatController.createNewChat(newChat);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          isGuest
              ? const SignInButton()
              : ListTile(
                  title: const Text('Create a Chat'),
                  leading: const Icon(Icons.add),
                  onTap: () => createNewChat(context, ref),
                ),
          if (!isGuest)
            ref.watch(userCommunitiesProvider).when(
                data: (communities) => Expanded(
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          final community = communities[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Pallete.whiteColor,
                              backgroundImage: NetworkImage(community.avatar),
                            ),
                            title: Text(community.name),
                          );
                        },
                        itemCount: communities.length,
                      ),
                    ),
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader())
        ],
      )),
    );
  }
}

class ChatListDrawer extends ConsumerWidget {
  const ChatListDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    final Map<String, dynamic> decodedJson = jsonDecode('''
      {
        "chats": [
          {
            "chat_id": "8f262122-7432-4b7e-b526-9e08fd723953",
            "title": "Expo?",
            "username": "nithishsriram_tt@srmap.edu.in",
            "created_at": "2025-03-17T00:37:27.983000",
            "last_message_at": "2025-03-17T00:38:38.345000",
            "last_message_preview": "This is a standard LLM response to: Will elon musk..."
          },
          {
            "chat_id": "92af0a22-1f83-4b6a-b252-1a0e2c2f1234",
            "title": "Project Discussion",
            "username": "ramkumar@srmap.edu.in",
            "created_at": "2025-03-16T14:22:10.450000",
            "last_message_at": "2025-03-16T15:00:02.567000",
            "last_message_preview": "Let's finalize the database schema today."
          },
          {
            "chat_id": "45be09cc-7a4f-4c5b-a4b8-b7d2f18e6789",
            "title": "Hackathon Prep",
            "username": "arjunreddy@srmap.edu.in",
            "created_at": "2025-03-15T10:05:30.120000",
            "last_message_at": "2025-03-16T11:15:45.678000",
            "last_message_preview": "I think we should focus on optimizing our ML model."
          }
        ]
      }
    ''');

    final List<Map<String, dynamic>> dummyChats =
        List<Map<String, dynamic>>.from(decodedJson['chats']);

    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          isGuest
              ? const SignInButton()
              : ListTile(
                  title: Text('New Chat'),
                  leading: Icon(Icons.chat),
                  onTap: () {},
                ),
          if (!isGuest)
            Expanded(
              child: ListView.builder(
                itemCount: dummyChats.length,
                itemBuilder: (BuildContext context, int index) {
                  final chat = dummyChats[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Pallete.whiteColor,
                      child: const Icon(Icons.message),
                    ),
                    title: Text(chat['title']),
                    onTap: () {},
                  );
                },
              ),
            )
        ],
      )),
    );
  }
}
