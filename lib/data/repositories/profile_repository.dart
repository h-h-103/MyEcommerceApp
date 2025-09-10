import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myecommerceapp/data/models/user_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('myusers').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Upload and update profile image
  Future<String> updateProfileImage(String uid, ImageSource source) async {
    try {
      // Pick image
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return '';

      final imageFile = File(pickedFile.path);

      // Upload to Firebase Storage
      final ref = _storage.ref().child('profile_pictures').child('$uid.jpg');
      await ref.putFile(imageFile);
      final downloadURL = await ref.getDownloadURL();

      // Update Firestore
      await _firestore.collection('myusers').doc(uid).update({
        'photoURL': downloadURL,
      });

      // Update Firebase Auth
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(downloadURL);
      }

      return downloadURL;
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
  }

  // Remove profile image
  Future<void> removeProfileImage(String uid) async {
    try {
      // Delete from Storage
      final ref = _storage.ref().child('profile_pictures').child('$uid.jpg');
      await ref.delete();

      // Update Firestore
      await _firestore.collection('myusers').doc(uid).update({
        'photoURL': null,
      });

      // Update Firebase Auth
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(null);
      }
    } catch (e) {
      throw Exception('Failed to remove profile image: $e');
    }
  }
}
