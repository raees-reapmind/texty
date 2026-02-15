import 'package:texty/data/datasources/firebase_chat_datasource.dart';
import 'package:texty/models/message_model.dart';

class ChatRepository {
  final FirebaseChatDatasource dataSource;

  ChatRepository(this.dataSource);

  Stream<List<MessageModel>> getMessages(String chatId){
    return dataSource.getMessages(chatId);
  }

  Future<void> sendMessage(String chatId, MessageModel message){
    return dataSource.sendMessage(chatId, message);
  }
}