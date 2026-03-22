import 'package:flutter/foundation.dart';
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

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isSeen', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isSeen': true});
    }
  }

  Future<int> getUnreadCount(String chatId, String userId) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isSeen', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  Future<void> deleteChat(String chatId) async {
    debugPrint(
        "FirebaseChatDatasource: Deleting chat doc and messages for chatId: $chatId");
    try {
      final chatDocRef = _firestore.collection('chats').doc(chatId);

      // Delete messages subcollection (Firestore doesn't auto-delete subcollections)
      final messages = await chatDocRef.collection('messages').get();
      debugPrint(
          "FirebaseChatDatasource: Found ${messages.docs.length} messages to delete");

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(chatDocRef);
      await batch.commit();
      debugPrint(
          "FirebaseChatDatasource: Successfully committed deletion batch");
    } catch (e) {
      debugPrint("FirebaseChatDatasource: Error in deleteChat: $e");
      rethrow;
    }
  }

  Future<void> setTypingStatus(
      String chatId, String uid, bool isTyping) async {
    await _firestore.collection('chats').doc(chatId).set({
      'typing': {uid: isTyping}
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getChatStream(String chatId) {
    return _firestore.collection('chats').doc(chatId).snapshots();
  }
}
