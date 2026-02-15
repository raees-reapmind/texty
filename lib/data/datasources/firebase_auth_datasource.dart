import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:texty/models/user_model.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> signUp(String name, String email, String password) async {
    print("DataSource: Starting signUp for $email");
    final credentials = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    print("DataSource: User created with UID: ${credentials.user!.uid}");
    final user =
        UserModel(uid: credentials.user!.uid, name: name, email: email);
    print("DataSource: Converting user to map and saving to Firestore...");
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      print("DataSource: User saved to Firestore successfully");
    } catch (e) {
      print("DataSource: Failed to save user to Firestore: $e");
      throw e; // Re-throw to be caught by Bloc
    }
    return user;
  }

  Future<UserModel> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final doc =
        await _firestore.collection('users').doc(credential.user!.uid).get();
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
