import 'package:drug_discovery/core/common/loader.dart';
import 'package:drug_discovery/features/gpt/widgets/chats_list_drawer.dart';
import 'package:drug_discovery/features/gpt/widgets/check_box_button.dart';
import 'package:drug_discovery/features/gpt/widgets/search_bar_button.dart';
import 'package:drug_discovery/features/home/drawers/profile_drawer.dart';
import 'package:drug_discovery/features/auth/repository/auth_repository.dart';
import 'package:drug_discovery/models/chat_model.dart';
import 'package:drug_discovery/models/message_model.dart';
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drug_discovery/features/gpt/controller/chat_controller.dart';
import 'package:routemaster/routemaster.dart';

class GptScreen extends ConsumerStatefulWidget {
  const GptScreen({super.key, this.chatId});
  final String? chatId;

  @override
  _GptScreenState createState() => _GptScreenState();
}

class _GptScreenState extends ConsumerState<GptScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> messages = [];
  final List<String> responses = [];
  String? chatId;
  bool isADMETSelected = false;
  bool isBASelected = false;
  bool _isLoading = false;
  bool _isLoadingHistory = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setUpChatList();
    if (widget.chatId != null) {
      _loadChatHistory(widget.chatId!);
    }
  }

  Future<void> _loadChatHistory(String chatId) async {
    final chatController = ref.read(chatControllerProvider.notifier);
    setState(() {
      _isLoading = true;
    });

    try {
      final chatMessages = await chatController.getChatMessages(chatId);
      setState(() {
        messages.clear();
        responses.clear();
        for (var msg in chatMessages) {
          if (msg.role == "user") {
            messages.add(msg.content);
          } else if (msg.role == "assistant") {
            responses.add(msg.content);
          }
        }
        this.chatId = chatId;
      });
    } catch (e) {
      print('Error loading chat history: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add this method to scroll to bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _setUpChatList() async {
    final chatController = ref.read(chatControllerProvider.notifier);
    final email = ref.read(authRepositoryProvider).getCurrentUserEmail();
    chatController.getUserChats(email!);
    return;
  }

  Future<bool> initializeChat(String title) async {
    final chatController = ref.read(chatControllerProvider.notifier);
    final email = ref.read(authRepositoryProvider).getCurrentUserEmail();

    if (email == null) {
      print('Email not available');
      return false;
    }

    String truncatedTitle =
        title.length > 16 ? title.substring(0, 16) + '...' : title;

    final newChat = ChatModel(
      useremail: email,
      title: truncatedTitle,
      createdAt: DateTime.now(),
    );

    String result = await chatController.createNewChat(newChat);
    setState(() {
      chatId = result;
    });
    if (result == '') return false;

    return true;
  }

  void sendMessage() async {
    final chatController = ref.read(chatControllerProvider.notifier);
    var message = _messageController.text;

    if (message.isEmpty) return;

    if (isADMETSelected) {
      message += " @admet_prediction";
    }

    if (isBASelected) {
      message += " @binding_affinity";
    }

    // Initialize chat if needed
    if (chatId == null) {
      if (await initializeChat(message) == false) return;
    }
    // Add user message to UI
    setState(() {
      _isLoading = true;
      messages.add(_messageController.text);
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

    // Create message model
    MessageModel messageModel = MessageModel(
      id: DateTime.now().toString(), // Temporary ID
      chatId: chatId!,
      role: "user",
      content: message,
      createdAt: DateTime.now(),
      mlActivated: false,
      parameters: {
        if (isADMETSelected) 'admet': true,
        if (isBASelected) 'ba': true,
      },
    );

    // Send message and get response
    try {
      String response = await chatController.sendChatMessage(messageModel);

      // Update UI with response
      setState(() {
        _isLoading = false;
        responses.add(response);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      });
    } catch (e) {
      // Handle error
      setState(() {
        responses.add("Error: Failed to get response");
      });
      print('Error getting response: $e');
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
        title: const Text(
          'Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => Scaffold.of(context).openEndDrawer(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? Colors.white24 : Colors.black12,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.profilePic),
                    radius: 18,
                  ),
                ),
              ),
            );
          })
        ],
      ),
      drawer: const ChatListDrawer(),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      backgroundColor: isDarkMode ? Pallete.blackColor : Pallete.whiteColor,
      body: _isLoadingHistory
          ? const Center(child: Loader())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length + responses.length,
                    itemBuilder: (context, index) {
                      // Determine if this is a user message or AI response
                      if (index % 2 == 0 && index ~/ 2 < messages.length) {
                        // User message (even indices)
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.only(
                                bottom: 8, left: 50, right: 12),
                            decoration: BoxDecoration(
                              color: Pallete.blueColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              messages[index ~/ 2],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      } else if (index % 2 == 1 &&
                          (index ~/ 2) < responses.length) {
                        // AI response (odd indices)
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.only(
                                bottom: 8, right: 50, left: 12),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Pallete.greyColor
                                  : Colors.grey[200],
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                                topLeft: Radius.circular(16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              responses[index ~/ 2],
                              style: TextStyle(
                                color: isDarkMode
                                    ? Pallete.whiteColor
                                    : Pallete.blackColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                if (_isLoading)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin:
                          const EdgeInsets.only(left: 12, bottom: 8, right: 50),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode ? Pallete.greyColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDarkMode ? Colors.white70 : Pallete.redColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Thinking...',
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
