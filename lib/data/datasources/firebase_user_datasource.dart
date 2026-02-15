import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:texty/models/user_model.dart';

class FirebaseUserDatasource {
  final _fireStore = FirebaseFirestore.instance;

  Stream<List<UserModel>> searchUsers(String query) {
    return _fireStore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList());
  }
}
