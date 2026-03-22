import 'package:texty/data/datasources/firebase_chat_datasource.dart';
import 'package:texty/models/message_model.dart';

class ChatRepository {
  final FirebaseChatDatasource dataSource;

  ChatRepository(this.dataSource);

  Stream<List<MessageModel>> getMessages(String chatId) {
    return dataSource.getMessages(chatId);
  }

  Future<void> sendMessage(String chatId, MessageModel message) {
    return dataSource.sendMessage(chatId, message);
  }

  Stream<List<Map<String, dynamic>>> getRecentChats(String uid) {
    return dataSource.getRecentChats(uid);
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) {
    return dataSource.getUserProfile(uid);
  }

  Future<void> markMessagesAsRead(String chatId, String userId) {
    return dataSource.markMessagesAsRead(chatId, userId);
  }

  Future<int> getUnreadCount(String chatId, String userId) {
    return dataSource.getUnreadCount(chatId, userId);
  }

  Future<void> deleteChat(String chatId) {
    return dataSource.deleteChat(chatId);
  }

  Future<void> setTypingStatus(String chatId, String uid, bool isTyping) {
    return dataSource.setTypingStatus(chatId, uid, isTyping);
  }

  Stream<dynamic> getChatStream(String chatId) {
    return dataSource.getChatStream(chatId);
  }
}
