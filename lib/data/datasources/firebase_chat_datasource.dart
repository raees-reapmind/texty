import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:texty/models/message_model.dart';

class FirebaseChatDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots()
          .map((snapshot){
            return snapshot.docs
                  .map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList();
          });
  }

  Future<void> sendMessage(String chatId, MessageModel message) async{
    await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());
  }
}