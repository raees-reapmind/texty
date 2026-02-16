class RecentChatsModel {
  final String chatId;
  final String otherUserName;
  final String otherUserPhoto;
  final String lastMessage;
  final String displayTime;

  RecentChatsModel({
    required this.chatId, 
    required this.otherUserName, 
    required this.otherUserPhoto, 
    required this.lastMessage, 
    required this.displayTime
  });
}