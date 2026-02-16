import 'package:equatable/equatable.dart';
import 'package:texty/models/message_model.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {
  final String chatId;
  LoadMessages(this.chatId);
}

class sendMessage extends ChatEvent {
  final String chatId;
  final MessageModel message;

  sendMessage(this.chatId, this.message);
}
