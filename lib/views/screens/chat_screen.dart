import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texty/blocs/chat/chat_bloc.dart';
import 'package:texty/blocs/chat/chat_event.dart';
import 'package:texty/blocs/chat/chat_state.dart';
import 'package:texty/data/datasources/firebase_chat_datasource.dart';
import 'package:texty/data/repositories/chat_repository.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  ChatScreen({required this.chatId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        ChatRepository(FirebaseChatDatasource())
      )..add(LoadMessages(chatId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Chat'),),

        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if(state is ChatLoaded) {
                    return ListView.builder(
                      itemCount: state.messages.length,
                      itemBuilder: (_, index) {
                        final message = state.messages[index];
                        return ListTile(
                          title: Text(message.message),
                        );
                      },
                    );
                  }
                  return Center(child: const CircularProgressIndicator());
                }
              )
            )
          ],
        ),
      ),
    );
  }
}