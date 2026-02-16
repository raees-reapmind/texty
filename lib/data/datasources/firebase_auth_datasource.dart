import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:texty/models/user_model.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserModel> signUp(String name, String email, String password,
      {File? profilePicture}) async {
    print("DataSource: Starting signUp for $email");
    final credentials = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    String? base64Image;
    if (profilePicture != null) {
      // Read bytes from file
      List<int> imageBytes = await profilePicture.readAsBytes();
      // Convert to Base64 string
      base64Image = base64Encode(imageBytes);
    }
    print("DataSource: User created with UID: ${credentials.user!.uid}");
    final user = UserModel(
      uid: credentials.user!.uid,
      name: name,
      email: email,
      searchName: name.toLowerCase(),
      // profilePictureUrl: profilePicture != null
      //     ? await uploadProfilePicture(credentials.user!.uid, profilePicture)
      //     : null,
      profilePictureUrl: base64Image, // Store Base64 string in Firestore
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

  Future<String> uploadProfilePicture(String uid, File imageFile) async {
    final ref = _storage.ref().child('user_profiles').child('$uid.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
