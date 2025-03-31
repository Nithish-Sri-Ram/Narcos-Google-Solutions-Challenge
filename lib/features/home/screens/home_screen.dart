import 'package:drug_discovery/features/feed/feed_screen.dart';
import 'package:drug_discovery/features/gpt/screens/gpt_screen.dart';
import 'package:drug_discovery/features/home/drawers/community_list_drawer.dart';
import 'package:drug_discovery/features/home/drawers/profile_drawer.dart';
import 'package:drug_discovery/features/auth/repository/auth_repository.dart';
import 'package:drug_discovery/features/posts/screens/add_post_screen.dart';
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedChatIdProvider = StateProvider<String?>((ref) {
  return null;
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    final selectedChatId = ref.watch(selectedChatIdProvider);

    ref.listen(selectedChatIdProvider, (previous, next) {
      if (next != null && _page != 1) {
        setState(() {
          _page = 1; // Switch to chat tab
        });
      }
    });

    // Create a list of widgets that can be updated
    final List<Widget> tabWidgets = [
      const FeedScreen(),
      GptScreen(chatId: selectedChatId),
      const AddPostScreen(),
    ];

    return Scaffold(
      body: tabWidgets[_page],
      drawer: const CommunityListDrawer(),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      bottomNavigationBar: CupertinoTabBar(
        activeColor: currentTheme.iconTheme.color,
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add)),
        ],
        onTap: onPageChanged,
        currentIndex: _page,
      ),
    );
  }
}
