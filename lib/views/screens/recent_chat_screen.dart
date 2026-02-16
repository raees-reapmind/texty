import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:texty/blocs/auth/auth_bloc.dart';
import 'package:texty/blocs/auth/auth_states.dart';
import 'package:texty/blocs/recent_chats/recent_chats_bloc.dart';
import 'package:texty/blocs/recent_chats/recent_chats_event.dart';
import 'package:texty/blocs/recent_chats/recent_chats_states.dart';
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
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    debugPrint("Initializing RecentChatScreen for user $uid");
    context.read<RecentChatsBloc>().add(LoadRecentChats(uid));
    super.initState();
  }

  Future<void> _refreshData() async {
    // Firestore streams auto-refresh, add delay for UX
    context.read<RecentChatsBloc>().add(LoadRecentChats(uid));
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
                            BlocBuilder<AuthBloc, AuthStates>(
                              builder: (context, state) {
                                String name = "User";
                                if (state is AuthAuthenticated) {
                                  // Again, use userModel here
                                  name = state.userModel.name;
                                  print(
                                      "RecentChatScreen: Authenticated user name: $name");
                                }
                                return Expanded(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage: state
                                                    is AuthAuthenticated &&
                                                state.userModel
                                                        .profilePictureUrl !=
                                                    null
                                            ? MemoryImage(base64Decode(state
                                                .userModel.profilePictureUrl!))
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Good morning",
                                                style: TextStyle(
                                                    color: AppColors
                                                        .textSecondary)),
                                            Text(name,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.pinkFFFF6B6B,
                                      shape: BoxShape.circle),
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
                                    color: AppColors.primaryBlue,
                                    shape: BoxShape.circle,
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
                        SizedBox(
                          height: 120, // Explicit height for horizontal list
                          child: BlocBuilder<RecentChatsBloc, RecentChatsState>(
                            builder: (context, recentState) {
                              return ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  // YOUR AVATAR (First Item)
                                  BlocBuilder<AuthBloc, AuthStates>(
                                    builder: (context, authState) {
                                      String? myImage;
                                      if (authState is AuthAuthenticated) {
                                        myImage = authState
                                            .userModel.profilePictureUrl;
                                      }
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: StoryAvatar(
                                          name: "Add Story",
                                          isAddStory: true,
                                          profilePictureUrl: myImage,
                                        ),
                                      );
                                    },
                                  ),

                                  // CHATTED USERS (Subsequent Items)
                                  if (recentState is RecentChatsLoaded)
                                    ...recentState.chats.map((chat) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: StoryAvatar(
                                          name: chat['otherUserName'] ?? 'User',
                                          profilePictureUrl:
                                              chat['otherUserPhoto'],
                                          isAddStory: false,
                                        ),
                                      );
                                    }).toList(),
                                ],
                              );
                            },
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

                    Expanded(
                      child: BlocBuilder<RecentChatsBloc, RecentChatsState>(
                        builder: (context, state) {
                          if (state is RecentChatsLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (state is RecentChatsError) {
                            return Center(
                                child: Text("Error: ${state.message}"));
                          }

                          if (state is RecentChatsLoaded) {
                            if (state.chats.isEmpty) {
                              return const Center(
                                child:
                                    Text("No chats yet. Start a conversation!"),
                              );
                            }

                            return ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: state.chats.length,
                              itemBuilder: (context, index) {
                                final chat = state.chats[index];
                                debugPrint(
                                    "Building chat item for chat: $chat");
                                return _buildChatItem(chat);
                              },
                            );
                          }

                          return const SizedBox.shrink();
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

  Widget _buildChatItem(Map<String, dynamic> chat) {
    // These fields are populated by your BLoC's UpdateRecentChats logic
    final String name = chat['otherUserName'] ?? 'User';
    final String message = chat['lastMessage'] ?? '';
    final String avatar = chat['otherUserPhoto'] ?? '';
    final String chatId = chat['chatId'] ?? '';
    final int unreadCount = chat['unreadCount'] ?? 0;

    // Time formatting
    String displayTime = "";
    if (chat['timestamp'] != null) {
      final date = (chat['timestamp'] as Timestamp).toDate();
      displayTime = DateFormat('hh:mm a').format(date);
    }

    return ChatListItem(
      name: name,
      message: message,
      time: displayTime,
      avatarUrl: avatar,
      unreadCount: unreadCount,
      onTap: () async {
        await context.push('/chat/$chatId');
        // Refresh unread counts when returning from chat
        if (context.mounted) {
          context.read<RecentChatsBloc>().add(LoadRecentChats(uid));
        }
      },
    );
  }
}
