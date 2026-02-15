import 'package:texty/data/datasources/firebase_user_datasource.dart';
import 'package:texty/models/user_model.dart';

class UserRepository {
  final FirebaseUserDatasource datasource;

  UserRepository(this.datasource);

  Stream<List<UserModel>> searchUsers(String query) {
    return datasource.searchUsers(query);
  }
}
