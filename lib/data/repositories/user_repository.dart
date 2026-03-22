import 'package:texty/data/datasources/firebase_user_datasource.dart';
import 'package:texty/models/user_model.dart';

class UserRepository {
  final FirebaseUserDatasource datasource;

  UserRepository(this.datasource);

  Stream<List<UserModel>> searchUsers(String query) {
    return datasource.searchUsers(query);
  }

  Stream<UserModel?> getUserStream(String uid) {
    return datasource.getUserStream(uid);
  }

  Future<UserModel?> getUserData(String uid) {
    return datasource.getUserData(uid);
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return datasource.updateUserProfile(uid, data);
  }

  Future<void> updateUserStatus(String uid, bool isOnline) {
    return datasource.updateUserStatus(uid, isOnline);
  }
}
