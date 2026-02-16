import 'package:equatable/equatable.dart';
import 'package:texty/models/message_model.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  ChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}
