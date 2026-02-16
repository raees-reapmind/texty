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
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    // 1. Reference to the main chat document
    final chatDocRef = _firestore.collection('chats').doc(chatId);

    // 2. Add the message to the subcollection
    await chatDocRef.collection('messages').add(message.toMap());

    await chatDocRef.set(
        {
          'participants': [message.senderId, message.receiverId],
          'lastMessage': message.message,
          'timestamp': message.timestamp, // Firestore Timestamp
        },
        SetOptions(
            merge:
                true)); // Use merge: true so you don't overwrite other fields
  }

  Stream<List<Map<String, dynamic>>> getRecentChats(String uid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data();
              data['chatId'] = doc.id; // Include ID for navigation
              return data;
            }).toList());
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
