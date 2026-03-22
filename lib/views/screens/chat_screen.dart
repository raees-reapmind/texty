import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:texty/blocs/chat/chat_bloc.dart';
import 'package:texty/blocs/chat/chat_event.dart';
import 'package:texty/blocs/chat/chat_state.dart';
import 'package:texty/core/theme/app_colors.dart';
import 'package:texty/models/message_model.dart';
import 'package:texty/views/widgets/common_background.dart';
import 'package:texty/views/widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({required this.chatId, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  DateTime? _lastTypingTime;

  @override
  void initState() {
    super.initState();
    // Load messages when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(LoadMessages(widget.chatId));
    });

    _messageController.addListener(_onTypingChanged);
  }

  void _onTypingChanged() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (_messageController.text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      context.read<ChatBloc>().add(SetTypingStatus(widget.chatId, uid, true));
    } else if (_messageController.text.isEmpty && _isTyping) {
      _isTyping = false;
      context.read<ChatBloc>().add(SetTypingStatus(widget.chatId, uid, false));
    }

    _lastTypingTime = DateTime.now();
    
    // Auto reset typing status after 3 seconds of inactivity
    Future.delayed(const Duration(seconds: 3), () {
      if (_lastTypingTime != null &&
          DateTime.now().difference(_lastTypingTime!).inSeconds >= 3 &&
          _isTyping) {
        _isTyping = false;
        context.read<ChatBloc>().add(SetTypingStatus(widget.chatId, uid, false));
      }
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTypingChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context) {
    if (_messageController.text.trim().isEmpty) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final otherUserId = _getOtherUserId();
    final message = MessageModel(
      id: '', // Firestore will generate this
      senderId: userId,
      receiverId: otherUserId,
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    context.read<ChatBloc>().add(sendMessage(widget.chatId, message));
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return CommonBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoaded) {
                    // Scroll to bottom after rebuild
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                    return _buildMessagesList(
                        state.messages, currentUserId, state.typingUsers);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: _buildChatHeader(),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: AppColors.primaryPurple),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.green),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildChatHeader() {
    final otherUserId = _getOtherUserId();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .snapshots(),
      builder: (context, snapshot) {
        String userName = "User";
        bool isOnline = false;
        if (snapshot.hasData && snapshot.data?.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          userName = data['name'] ?? "User";
          isOnline = data['isOnline'] ?? false;
        }

        return Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                  backgroundImage: snapshot.hasData &&
                          snapshot.data?.data() != null &&
                          (snapshot.data!.data() as Map<String, dynamic>)[
                                  'profilePictureUrl'] !=
                              null
                      ? MemoryImage(base64Decode((snapshot.data!.data()
                          as Map<String, dynamic>)['profilePictureUrl']))
                      : null,
                  child: snapshot.hasData &&
                          snapshot.data?.data() != null &&
                          (snapshot.data!.data() as Map<String, dynamic>)[
                                  'profilePictureUrl'] ==
                              null
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoaded &&
                          state.typingUsers[otherUserId] == true) {
                        return const Text(
                          "typing...",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      return Text(
                        isOnline ? "Online" : "Offline",
                        style: TextStyle(
                          fontSize: 11,
                          color: isOnline ? Colors.green : AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessagesList(
      List<MessageModel> messages, String currentUserId, Map<String, bool> typingUsers) {
    final otherUserId = _getOtherUserId();
    final isOtherTyping = typingUsers[otherUserId] ?? false;

    if (messages.isEmpty && !isOtherTyping) {
      return const Center(
        child: Text(
          "No messages yet. Start the conversation!",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (isOtherTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return TypingIndicator(
            showIndicator: isOtherTyping,
            avatar: _buildUserAvatar(otherUserId),
          );
        }

        final message = messages[index];
        final isMe = message.senderId == currentUserId;
        final showDate = _shouldShowDate(messages, index);

        return Column(
          children: [
            if (showDate) _buildDateSeparator(message.timestamp),
            _buildMessageBubble(message, isMe),
          ],
        );
      },
    );
  }

  bool _shouldShowDate(List<MessageModel> messages, int index) {
    if (index == 0) return true;

    final currentDate = messages[index].timestamp;
    final previousDate = messages[index - 1].timestamp;

    return currentDate.day != previousDate.day ||
        currentDate.month != previousDate.month ||
        currentDate.year != previousDate.year;
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        DateFormat('MMMM dd').format(date),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final otherUserId = _getOtherUserId();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            _buildUserAvatar(otherUserId),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe) _buildSenderName(otherUserId),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primaryPurple.withOpacity(0.9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('hh:mm a').format(message.timestamp),
                            style: TextStyle(
                              color: isMe
                                  ? Colors.white.withOpacity(0.7)
                                  : AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: message.isSeen
                                  ? Colors.greenAccent
                                  : Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        String userName = "?";
        if (snapshot.hasData && snapshot.data?.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          userName = (data['name'] ?? '?');
        }

        return CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
          backgroundImage: snapshot.hasData &&
                  snapshot.data?.data() != null &&
                  (snapshot.data!.data()
                          as Map<String, dynamic>)['profilePictureUrl'] !=
                      null
              ? MemoryImage(base64Decode((snapshot.data!.data()
                  as Map<String, dynamic>)['profilePictureUrl']))
              : null,
          child: snapshot.hasData &&
                  snapshot.data?.data() != null &&
                  (snapshot.data!.data()
                          as Map<String, dynamic>)['profilePictureUrl'] ==
                      null
              ? Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSenderName(String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        String userName = "User";
        if (snapshot.hasData && snapshot.data?.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          userName = data['name'] ?? "User";
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 4),
          child: Text(
            userName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined,
                    color: AppColors.primaryPurple),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Type something",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon:
                  const Icon(Icons.attachment, color: AppColors.textSecondary),
              onPressed: () {},
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _sendMessage(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOtherUserId() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userIds = widget.chatId.split('_');
    return userIds[0] == currentUserId ? userIds[1] : userIds[0];
  }
}
