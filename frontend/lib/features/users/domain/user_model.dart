import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final bool block;
  final String? phone;
  final String? avatarBase64;
  final Timestamp? createdAt;

  User({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.block = false,
    this.phone,
    this.avatarBase64,
    this.createdAt,
  });

  /// Converts User into a Firestore document map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'block': block,
      if (phone != null) 'phone': phone,
      if (avatarBase64 != null) 'avatarBase64': avatarBase64,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Creates a User instance from Firestore document data.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      block: map['block'] as bool? ?? false,
      phone: map['phone'] as String?,
      avatarBase64: map['avatarBase64'] as String?,
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}