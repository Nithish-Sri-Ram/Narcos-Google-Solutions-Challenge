import 'package:any_link_preview/any_link_preview.dart';
import 'package:drug_discovery/core/constants/constants.dart';
import 'package:drug_discovery/features/posts/controller/post_controller.dart';
import 'package:drug_discovery/features/repository/auth_repository.dart';
import 'package:drug_discovery/models/post_model.dart';
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({
    super.key,
    required this.post,
  });

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final user = ref.watch(userProvider)!;

    final currentTheme = ref.watch(themeNotifierProvider);

    return Column(children: [
      Container(
        decoration: BoxDecoration(
          color: currentTheme.drawerTheme.backgroundColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
                child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                          .copyWith(right: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(post.communityProfilePic),
                                radius: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.communityName,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      post.username,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (post.uid == user.uid)
                            IconButton(
                              onPressed: () => deletePost(ref, context),
                              icon: Icon(
                                Icons.delete,
                                color: Pallete.redColor,
                              ),
                            )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isTypeImage)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          child: Image.network(
                            post.link!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (isTypeLink)
                        Container(
                          height: 150,
                          padding: EdgeInsets.symmetric(),
                          width: double.infinity,
                          child: AnyLinkPreview(
                            displayDirection: UIDirection.uiDirectionHorizontal,
                            link: post.link!,
                          ),
                        ),
                      if (isTypeText)
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            post.description!,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Constants.up,
                                size: 30,
                                color: post.upvotes.contains(user.uid)
                                    ? Pallete.redColor
                                    : null,
                              )),
                          Text(
                            '${post.upvotes.length - post.downvotes.length == 0 ? 'vote' : post.upvotes.length - post.downvotes.length}',
                            style: const TextStyle(fontSize: 17),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Constants.down,
                              size: 30,
                              color: post.downvotes.contains(user.uid)
                                  ? Pallete.blueColor
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.comment)),
                          Text(
                            '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                            style: const TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ))
          ],
        ),
      )
    ]);
  }
}
