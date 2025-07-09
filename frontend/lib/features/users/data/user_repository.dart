import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../domain/user_model.dart';

class UserRepository {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User> registerNewUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
    bool block = false,
    String? phone,
    String? avatarBase64,
  }) async {
    // 1. Create Auth user
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email, password: password);
    final uid = cred.user!.uid;

    // 3. Build User model and save to Firestore
    final user = User(
      uid: uid,
      fullName: fullName,
      email: email,
      role: role,
      block: block,
      phone: phone,
      avatarBase64: avatarBase64,
    );
    await _db.collection('users').doc(uid).set(user.toMap());
    return user;
  }
}
