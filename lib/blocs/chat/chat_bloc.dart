import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:texty/blocs/chat/chat_event.dart';
import 'package:texty/blocs/chat/chat_state.dart';
import 'package:texty/data/repositories/chat_repository.dart';
import 'package:texty/models/message_model.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  ChatBloc(this.repository) : super(ChatInitial()) {
    on<LoadMessages>((event, emit) async {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // Combine messages stream and chat document stream (for typing status)
      final combinedStream = Rx.combineLatest2(
        repository.getMessages(event.chatId),
        repository.getChatStream(event.chatId),
        (messages, chatDoc) {
          Map<String, bool> typingUsers = {};
          if (chatDoc is DocumentSnapshot && chatDoc.exists) {
            final data = chatDoc.data() as Map<String, dynamic>?;
            if (data != null && data['typing'] != null) {
              typingUsers = Map<String, bool>.from(data['typing']);
            }
          }
          return {'messages': messages, 'typing': typingUsers};
        },
      );

      await emit.forEach(
        combinedStream,
        onData: (Map<String, dynamic> data) {
          if (userId != null) {
            repository.markMessagesAsRead(event.chatId, userId);
          }
          final messages = data['messages'] as List<MessageModel>? ?? [];
          final typing = data['typing'] as Map<String, bool>? ?? {};
          return ChatLoaded(messages, typingUsers: typing);
        },
      );
    });

    on<sendMessage>((event, emit) async {
      await repository.sendMessage(event.chatId, event.message);
    });

    on<SetTypingStatus>((event, emit) async {
      await repository.setTypingStatus(event.chatId, event.uid, event.isTyping);
    });
  }
}
