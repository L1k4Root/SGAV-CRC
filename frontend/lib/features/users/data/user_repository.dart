import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
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
    Uint8List? avatarBytes,
  }) async {
    // 1. Create Auth user
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email, password: password);
    final uid = cred.user!.uid;

    // 2. Upload avatar if provided
    String? photoURL;
    if (avatarBytes != null) {
      final ref = FirebaseStorage.instance.ref('user_avatars/$uid.jpg');
      await ref.putData(avatarBytes);
      photoURL = await ref.getDownloadURL();
    }

    // 3. Build User model and save to Firestore
    final user = User(
      uid: uid,
      fullName: fullName,
      email: email,
      role: role,
      block: block,
      phone: phone,
      photoURL: photoURL,
    );
    await _db.collection('users').doc(uid).set(user.toMap());
    return user;
  }
}
