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
}
