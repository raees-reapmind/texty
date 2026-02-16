import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:texty/core/theme/app_colors.dart';
import 'package:texty/views/widgets/chat_list_item.dart';
import 'package:texty/views/widgets/common_background.dart';

import 'package:texty/views/widgets/story_avatar.dart';

class RecentChatScreen extends StatefulWidget {
  const RecentChatScreen({super.key});

  @override
  State<RecentChatScreen> createState() => _RecentChatScreenState();
}

class _RecentChatScreenState extends State<RecentChatScreen> {
  Future<void> _refreshData() async {
    // Firestore streams auto-refresh, add delay for UX
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return CommonBackground(
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Header & Stories Section
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Column(
                      children: [
                        // Top Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                String userName = "User";
                                if (snapshot.hasData &&
                                    snapshot.data?.data() != null) {
                                  final data = snapshot.data!.data()
                                      as Map<String, dynamic>;
                                  userName = data['name'] ?? "User";
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Good morning",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFFFFD1DC), // Light pinkish
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.search,
                                        color:
                                            Colors.white), // Or specific color
                                    onPressed: () => context.go('/chat/search'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue, // Blue
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Stories List
                        SizedBox(
                          height: 90,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: const [
                              StoryAvatar(name: "Add Story", isAddStory: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
            SliverFillRemaining(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle / Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Chats",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Manage",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    // Chat List
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('chats')
                            .where('participants', arrayContains: uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final docs = snapshot.data!.docs;
                          debugPrint(
                              "Fetched ${docs.length} chats for user $uid");

                          if (docs.isEmpty) {
                            return const Center(
                                child: Text(
                                    "No chats yet. Start a conversation!"));
                          }

                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final chat = docs[index];
                              final chatId = chat.id;
                              final participants =
                                  List<String>.from(chat['participants'] ?? []);

                              // Get the other user's ID
                              final otherUserId = participants.firstWhere(
                                (id) => id != uid,
                                orElse: () => '',
                              );

                              return StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(otherUserId)
                                    .snapshots(),
                                builder: (context, userSnapshot) {
                                  String userName = 'User';
                                  if (userSnapshot.hasData &&
                                      userSnapshot.data?.data() != null) {
                                    final userData = userSnapshot.data!.data()
                                        as Map<String, dynamic>;
                                    userName = userData['name'] ?? 'User';
                                  }

                                  // Get last message from subcollection
                                  return StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('chats')
                                        .doc(chatId)
                                        .collection('messages')
                                        .orderBy('timestamp', descending: true)
                                        .limit(1)
                                        .snapshots(),
                                    builder: (context, messageSnapshot) {
                                      String lastMessage = 'No messages yet';
                                      String lastTime = '';

                                      if (messageSnapshot.hasData &&
                                          messageSnapshot
                                              .data!.docs.isNotEmpty) {
                                        final lastMsg =
                                            messageSnapshot.data!.docs.first;
                                        lastMessage = lastMsg['message'] ?? '';

                                        if (lastMsg['timestamp'] != null) {
                                          final timestamp =
                                              (lastMsg['timestamp']
                                                      as Timestamp)
                                                  .toDate();
                                          final now = DateTime.now();
                                          final difference =
                                              now.difference(timestamp);

                                          if (difference.inDays == 0) {
                                            lastTime =
                                                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
                                          } else if (difference.inDays == 1) {
                                            lastTime = 'Yesterday';
                                          } else {
                                            lastTime =
                                                '${timestamp.day}/${timestamp.month}/${timestamp.year}';
                                          }
                                        }
                                      }

                                      return ChatListItem(
                                        name: userName,
                                        message: lastMessage,
                                        time: lastTime,
                                        avatarUrl: "",
                                        unreadCount: 0,
                                        onTap: () {
                                          context.go('/chat/$chatId');
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
