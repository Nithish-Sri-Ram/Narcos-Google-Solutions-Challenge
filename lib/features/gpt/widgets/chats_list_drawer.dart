import 'package:drug_discovery/core/common/loader.dart';
import 'package:drug_discovery/core/common/sign_in_button.dart';
import 'package:drug_discovery/features/auth/repository/auth_repository.dart';
import 'package:drug_discovery/features/gpt/controller/chat_controller.dart';
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drug_discovery/models/chat_model.dart';
import 'package:routemaster/routemaster.dart';

final selectedChatIdProvider = StateProvider<String?>((ref) => null);

class ChatListDrawer extends ConsumerWidget {
  const ChatListDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final chatController = ref.watch(chatControllerProvider.notifier);

    final chats = chatController.cachedChats;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            isGuest
                ? const SignInButton()
                : ListTile(
                    title: Text('New Chat'),
                    leading: Icon(Icons.chat),
                    onTap: () async {
                      // Create a new chat
                      final chatController =
                          ref.read(chatControllerProvider.notifier);
                      final email = ref
                          .read(authRepositoryProvider)
                          .getCurrentUserEmail();
                      if (email == null) {
                        print('Email not available');
                        return;
                      }

                      final newChat = ChatModel(
                        useremail: email,
                        title: "New Chat",
                        createdAt: DateTime.now(),
                      );

                      String chatId =
                          await chatController.createNewChat(newChat);
                      if (chatId.isEmpty) return;

                      // Close the drawer
                      Navigator.pop(context);

                      // Invalidate the provider and set it to null for a new chat
                      ref.invalidate(selectedChatIdProvider);
                      ref.read(selectedChatIdProvider.notifier).state = null;

                      // Replace current screen with new GptScreen
                      Routemaster.of(context).push('/chat');
                    },
                  ),
            if (!isGuest)
              Expanded(
                child: chats.isEmpty
                    ? const Loader()
                    : ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (BuildContext context, int index) {
                          final chat = chats[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Pallete.whiteColor,
                              child: const Icon(Icons.message),
                            ),
                            title: Text(chat.title),
                            onTap: () {
                              Navigator.pop(context);

                              // Invalidate the provider and set the new chat ID
                              ref.invalidate(selectedChatIdProvider);
                              ref.read(selectedChatIdProvider.notifier).state =
                                  chat.chatId;

                              // Replace current screen with GptScreen for the selected chat
                              Routemaster.of(context)
                                  .push('/chat?chatId=${chat.chatId}');
                            },
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
