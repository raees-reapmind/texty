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
    final user = UserModel(
      uid: credentials.user!.uid,
      name: name,
      email: email,
      searchName: name.toLowerCase(),
    );
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
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (credential.user == null) {
        throw 'Login failed: User not found.';
      }

      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!doc.exists) {
        throw 'User data not found in database.';
      }

      final data = doc.data();
      if (data == null) {
        throw 'User data is corrupt.';
      }

      return UserModel.fromMap(data);
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}");
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided.';
      } else if (e.code == 'invalid-credential') {
        throw 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        throw 'The email address is badly formatted.';
      }
      throw e.message ?? 'Authentication failed: ${e.code}';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
