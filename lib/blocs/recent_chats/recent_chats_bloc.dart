import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texty/blocs/recent_chats/recent_chats_event.dart';
import 'package:texty/blocs/recent_chats/recent_chats_states.dart';
import 'package:texty/data/repositories/chat_repository.dart';

class RecentChatsBloc extends Bloc<RecentChatsEvent, RecentChatsState> {
  final ChatRepository chatRepository;
  StreamSubscription? _streamSubscription;

  RecentChatsBloc(this.chatRepository) : super(RecentChatsLoading()) {
    on<LoadRecentChats>((event, emit) {
      emit(RecentChatsLoading());
      _streamSubscription?.cancel();
      debugPrint(
          "RecentChatsBloc: Subscribing to recent chats for uid: ${event.uid}");

      // We pass the uid into the listener so it can be used in the Update event
      _streamSubscription = chatRepository.getRecentChats(event.uid).listen(
        (chats) {
          debugPrint("RecentChatsBloc: Received recent chats update: $chats");
          add(UpdateRecentChats(
              chats, event.uid)); // Now 2 arguments are expected and provided
        },
        onError: (error) => add(RecentChatsErrorEvent(error.toString())),
      );
    });

    on<UpdateRecentChats>((event, emit) async {
      try {
        List<Map<String, dynamic>> enrichedChats = [];

        for (var chat in event.chats) {
          final participants = List<String>.from(chat['participants'] ?? []);

          // Use event.currentUid to find the other person
          final otherUserId = participants.firstWhere(
            (id) => id != event.currentUid,
            orElse: () => '',
          );

          if (otherUserId.isNotEmpty) {
            final userData = await chatRepository.getUserProfile(otherUserId);
            final unreadCount = await chatRepository.getUnreadCount(
                chat['chatId'], event.currentUid);
            log("RecentChatsBloc: Fetched user profile for $otherUserId: $userData, unreadCount: $unreadCount");

            enrichedChats.add({
              ...chat,
              'otherUserName': userData?['name'] ?? 'User',
              'otherUserPhoto': userData?['profilePictureUrl'] ?? '',
              'unreadCount': unreadCount,
            });
          }
        }
        emit(RecentChatsLoaded(enrichedChats));
      } catch (e) {
        emit(RecentChatsError(e.toString()));
      }
    });

    on<RecentChatsErrorEvent>((event, emit) {
      emit(RecentChatsError(event.message));
    });
  }
}
