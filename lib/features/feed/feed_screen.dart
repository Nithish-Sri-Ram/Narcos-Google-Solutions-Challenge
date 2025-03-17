import 'package:drug_discovery/core/common/custom_appbar.dart';
import 'package:drug_discovery/core/common/error_text.dart';
import 'package:drug_discovery/core/common/loader.dart';
import 'package:drug_discovery/core/common/post_card.dart';
import 'package:drug_discovery/features/auth/repository/auth_repository.dart';
import 'package:drug_discovery/features/community/controller/community_controller.dart';
import 'package:drug_discovery/features/home/drawers/community_list_drawer.dart';
import 'package:drug_discovery/features/home/drawers/profile_drawer.dart';
import 'package:drug_discovery/features/posts/controller/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Feed'),
      drawer: const CommunityListDrawer(),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      body: isGuest
          ? ref.watch(userCommunitiesProvider).when(
                data: (communities) => ref.watch(guestPostsProvider).when(
                      data: (data) => ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final post = data[index];
                          return PostCard(post: post);
                        },
                      ),
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader(),
                    ),
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader(),
              )
          : ref.watch(userCommunitiesProvider).when(
                data: (communities) =>
                    ref.watch(userPostsProvider(communities)).when(
                          data: (data) => ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              final post = data[index];
                              return PostCard(post: post);
                            },
                          ),
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => const Loader(),
                        ),
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader(),
              ),
    );
  }
}
