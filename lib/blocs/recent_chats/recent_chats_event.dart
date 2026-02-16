import 'package:equatable/equatable.dart';

abstract class RecentChatsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRecentChats extends RecentChatsEvent {
  final String uid;
  LoadRecentChats(this.uid);
}


class UpdateRecentChats extends RecentChatsEvent {
  final List<Map<String, dynamic>> chats;
  final String currentUid; // Add this field

  UpdateRecentChats(this.chats, this.currentUid); // Add it to constructor

  @override
  List<Object?> get props => [chats, currentUid];
}

class RecentChatsErrorEvent extends RecentChatsEvent {
  final String message;
  RecentChatsErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
