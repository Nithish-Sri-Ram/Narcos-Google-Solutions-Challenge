import 'package:drug_discovery/features/gpt/widgets/chats_list_drawer.dart';
import 'package:drug_discovery/features/gpt/widgets/check_box_button.dart';
import 'package:drug_discovery/features/gpt/widgets/search_bar_button.dart';
import 'package:drug_discovery/features/home/drawers/profile_drawer.dart';
import 'package:drug_discovery/features/auth/repository/auth_repository.dart';
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drug_discovery/features/gpt/controller/chat_controller.dart';

class GptScreen extends ConsumerStatefulWidget {
  const GptScreen({super.key});

  @override
  _GptScreenState createState() => _GptScreenState();
}

class _GptScreenState extends ConsumerState<GptScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> messages = [];
  String? chatId;
  bool isADMETSelected = false;
  bool isBASelected = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final chatController = ref.read(chatControllerProvider.notifier);
    final user = ref.read(userProvider);
    final existingChats = await chatController.getUserChats();

    if (existingChats.isEmpty) {
      final newChat = NewChatModel(userName: user!.name, title: "New Chat");
      await chatController.createNewChat(newChat);
      final updatedChats = await chatController.getUserChats();
      if (updatedChats.isNotEmpty) {
        setState(() {
          chatId = updatedChats.first.chatId;
        });
      }
    } else {
      setState(() {
        chatId = existingChats.first.chatId;
      });
    }
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty && chatId != null) {
      setState(() {
        messages.add(_messageController.text);
        _messageController.clear();
      });
      // Here, you'd send the message to the backend using chatController
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    final isDarkMode = currentTheme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
        backgroundColor: isDarkMode ? Pallete.drawerColor : Pallete.whiteColor,
        elevation: 0,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
        actions: [
          Builder(builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            );
          })
        ],
      ),
      drawer: const ChatListDrawer(),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      backgroundColor: isDarkMode ? Pallete.blackColor : Pallete.whiteColor,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Pallete.blueColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      messages[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Pallete.greyColor : Pallete.whiteColor,
              border: Border(
                top: BorderSide(
                    color: isDarkMode ? Colors.white30 : Colors.black26),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(
                            color: isDarkMode
                                ? Pallete.whiteColor
                                : Pallete.blackColor),
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Pallete.whiteColor.withOpacity(0.6)
                                  : Pallete.blackColor.withOpacity(0.6)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Pallete.redColor),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CheckboxButton(
                      icon: Icons.settings_input_composite_sharp,
                      title: 'ADMET',
                      isSelected: isADMETSelected,
                      onTap: (value) {
                        setState(() {
                          isADMETSelected = value;
                        });
                      },
                    ),
                    CheckboxButton(
                      icon: Icons.hub,
                      title: 'BA',
                      isSelected: isBASelected,
                      onTap: (value) {
                        setState(() {
                          isBASelected = value;
                        });
                      },
                    ),
                    Spacer(),
                    SearchBarButton(
                      icon: Icons.add_circle_outline_outlined,
                      text: 'Attach',
                      onTap: () {
                        // Handle Attach Button action
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
