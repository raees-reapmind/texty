import 'package:equatable/equatable.dart';

abstract class RecentChatsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecentChatsLoading extends RecentChatsState {}

class RecentChatsLoaded extends RecentChatsState {
  final List<Map<String, dynamic>> chats;
  RecentChatsLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class RecentChatsError extends RecentChatsState {
  final String message;
  RecentChatsError(this.message);
}
