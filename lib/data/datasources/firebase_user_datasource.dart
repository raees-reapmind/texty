import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:texty/models/user_model.dart';

class FirebaseUserDatasource {
  final _fireStore = FirebaseFirestore.instance;

  Stream<List<UserModel>> searchUsers(String query) {
    if (query.isEmpty) return Stream.value([]);

    final searchLower = query.toLowerCase();

    print("UserDataSource: Searching for '$query' (lower: '$searchLower')");

    return _fireStore
        .collection('users')
        .where('searchName', isGreaterThanOrEqualTo: searchLower)
        .where('searchName', isLessThanOrEqualTo: '$searchLower\uf8ff')
        .snapshots()
        .map((snapshot) {
      print(
          "UserDataSource: Found ${snapshot.docs.length} users for query '$searchLower'");
      return snapshot.docs.map((doc) {
        print("UserDataSource: Found user ${doc.data()}");
        return UserModel.fromMap(doc.data());
      }).toList();
    });
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _fireStore.collection('users').doc(uid).snapshots().map((doc) =>
        doc.exists && doc.data() != null
            ? UserModel.fromMap(doc.data()!)
            : null);
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _fireStore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _fireStore.collection('users').doc(uid).update(data);
  }
}
