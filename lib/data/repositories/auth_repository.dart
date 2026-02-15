import 'package:texty/data/datasources/firebase_auth_datasource.dart';
import 'package:texty/models/user_model.dart';

class AuthRepository {
  final FirebaseAuthDatasource datasource;

  AuthRepository(this.datasource);

  Future<UserModel> signUp(String name, String email, String password){
    return datasource.signUp(name, email, password);
  }

  Future<UserModel> login(String email, String password) {
    return datasource.login(email, password);
  }

  Future<void> logout() {
    return datasource.logout();
  }

  Stream get authStateChanges => datasource.authStateChanges;
}