import 'package:drug_discovery/features/gpt/controller/chat_controller.dart';
import 'package:drug_discovery/features/gpt/widgets/search_bar_button.dart';
import 'package:drug_discovery/features/posts/screens/add_post_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublishToCommunityButton extends ConsumerStatefulWidget {
  final String? chatId;
  final List<String> messages;
  final List<String> responses;

  const PublishToCommunityButton({
    super.key,
    required this.chatId,
    required this.messages,
    required this.responses,
  });

  @override
  _PublishToCommunityButtonState createState() =>
      _PublishToCommunityButtonState();
}

class _PublishToCommunityButtonState
    extends ConsumerState<PublishToCommunityButton> {
  bool _isLoading = false;

  Future<void> _handlePublish(WidgetRef ref) async {
    if (widget.chatId != null &&
        widget.messages.isNotEmpty &&
        widget.responses.isNotEmpty) {
      setState(() {
        _isLoading = true; // Show loader
      });

      try {
        // Use ref.read to access the provider
        final chatController = ref.read(chatControllerProvider.notifier);
        final summaryData =
            await chatController.fetchChatSummary(widget.chatId!);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddPostTypeScreen(
              type: 'text',
              initialTitle: summaryData['title'] ?? '',
              initialDescription: summaryData['content'] ?? '',
            ),
          ),
        );
      } catch (e) {
        print('Error publishing to community: $e');
      } finally {
        setState(() {
          _isLoading = false; // Hide loader
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(), // Loader displayed during async operation
      );
    }

    return SearchBarButton(
      icon: Icons.upload,
      text: 'Publish to Community',
      onTap: widget.chatId != null &&
              widget.messages.isNotEmpty &&
              widget.responses.isNotEmpty
          ? () => _handlePublish(ref)
          : null, // Disable button if conditions are not met
    );
  }
}
