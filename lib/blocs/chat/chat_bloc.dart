import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texty/blocs/chat/chat_event.dart';
import 'package:texty/blocs/chat/chat_state.dart';
import 'package:texty/data/repositories/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  ChatBloc(this.repository) : super(ChatInitial()) {
    on<LoadMessages>((event, emit){
      repository.getMessages(event.chatId).listen((messages){
        emit(ChatLoaded(messages));
      });
    });

    on<sendMessage>((event, emit) async {
      await repository.sendMessage(event.chatId, event.message);
    });
  }
}