import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? photoURL;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String signInMethod;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.photoURL,
    this.fcmToken,
    this.createdAt,
    this.lastLogin,
    this.isActive = false,
    this.signInMethod = "email",
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      fcmToken: data['fcmToken'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? false,
      signInMethod: data['signInMethod'] ?? "email",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'photoURL': photoURL,
      'fcmToken': fcmToken,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
      'signInMethod': signInMethod,
    };
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? photoURL,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    String? signInMethod,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      signInMethod: signInMethod ?? this.signInMethod,
    );
  }
}
