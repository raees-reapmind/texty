import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:texty/core/theme/app_colors.dart';
import 'package:texty/views/widgets/chat_list_item.dart';
import 'package:texty/views/widgets/common_background.dart';

import 'package:texty/views/widgets/story_avatar.dart';

class RecentChatScreen extends StatelessWidget {
  const RecentChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return CommonBackground(
      child: Column(
        children: [
          // Header & Stories Section
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good morning",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          "Alex bender", // Placeholder for current user name
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD1DC), // Light pinkish
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search,
                                color: Colors.white), // Or specific color
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
                            icon: const Icon(Icons.add, color: Colors.white),
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
                      StoryAvatar(name: "Colleen", image: ""), // Placeholder
                      StoryAvatar(name: "Soham", image: ""),
                      StoryAvatar(name: "Darren", image: ""),
                      StoryAvatar(name: "Alice", image: ""),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Chat List Sheet
          Expanded(
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
                          .collection('chat_rooms')
                          .where('participants', arrayContains: uid)
                          .orderBy('lastTimestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!.docs;

                        if (docs.isEmpty) {
                          return const Center(
                              child: Text("No meaningful chats yet."));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final chat = docs[index];
                            final chatId = chat.id;
                            // TODO: Fetch other user's name/avatar dynamically roughly
                            final lastMessage = chat['lastMessage'] ?? '';

                            // Mocking time for now, real app would parse timestamp
                            final lastTime = "Today, 12:25";

                            return ChatListItem(
                              name: "User", // Would need to fetch
                              message: lastMessage,
                              time: lastTime,
                              avatarUrl: "",
                              unreadCount: 0, // Mock
                              onTap: () {
                                context.go('/chat/$chatId');
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
    );
  }
}
