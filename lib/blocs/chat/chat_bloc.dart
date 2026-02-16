import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texty/blocs/chat/chat_event.dart';
import 'package:texty/blocs/chat/chat_state.dart';
import 'package:texty/data/repositories/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  ChatBloc(this.repository) : super(ChatInitial()) {
    on<LoadMessages>((event, emit) async {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      await emit.forEach(
        repository.getMessages(event.chatId),
        onData: (messages) {
          if (userId != null) {
            repository.markMessagesAsRead(event.chatId, userId);
          }
          return ChatLoaded(messages);
        },
      );
    });

    on<sendMessage>((event, emit) async {
      await repository.sendMessage(event.chatId, event.message);
    });
  }
}
