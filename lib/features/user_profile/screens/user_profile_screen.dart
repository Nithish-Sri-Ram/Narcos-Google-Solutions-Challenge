import 'package:drug_discovery/core/common/error_text.dart';
import 'package:drug_discovery/core/common/loader.dart';
import 'package:drug_discovery/features/auth/controller/auth_controller.dart';
import 'package:drug_discovery/features/community/controller/community_controller.dart';
import 'package:drug_discovery/features/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
          data: (user) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 250.0,
                    floating: false,
                    pinned: true,
                    // snap: true,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            user.banner,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding:
                              const EdgeInsets.all(20).copyWith(bottom: 70),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(user.profilePic),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(20),
                          child: OutlinedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                            ),
                            child: const Text('Edit Profile'),
                          ),
                        )
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // Align(
                          //   alignment: Alignment.topLeft,
                          //   child:
                          //   CircleAvatar(
                          //     radius: 35,
                          //     backgroundColor: Colors.white,
                          //     backgroundImage:
                          //         NetworkImage(user.profilePic),
                          //   ),
                          // ),
                          // const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              '${user.karma} karma',
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(thickness: 2),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: Text('Displaying Posts')),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => Loader()),
    );
  }
}
