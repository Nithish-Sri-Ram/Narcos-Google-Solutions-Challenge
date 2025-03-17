import 'package:drug_discovery/features/home/delegates/search_community_delegate.dart';
import 'package:drug_discovery/features/auth/repository/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    
    return AppBar(
      title: Text(title),
      centerTitle: false,
      leading: Builder(builder: (context) {
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => displayDrawer(context),
        );
      }),
      actions: [
        IconButton(
          onPressed: () {
            showSearch(
                context: context, delegate: SearchCommunityDelegate(ref));
          },
          icon: const Icon(Icons.search),
        ),
        if (kIsWeb)
          IconButton(
            onPressed: () {
              Routemaster.of(context).push('/add-post');
            },
            icon: const Icon(Icons.add),
          ),
        Builder(builder: (context) {
          return IconButton(
            icon: CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
            ),
            onPressed: () => displayEndDrawer(context),
          );
        })
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
