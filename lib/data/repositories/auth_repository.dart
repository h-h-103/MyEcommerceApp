import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> _getFCMToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> _updateUserToken(
    User user, {
    String signInMethod = "email",
  }) async {
    try {
      final fcmToken = await _getFCMToken();
      final userDoc = _firestore.collection('myusers').doc(user.uid);

      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        await userDoc.update({
          'uid': user.uid, // Added UUID field update
          'fcmToken': fcmToken,
          'lastLogin': Timestamp.fromDate(DateTime.now()),
          'isActive': true,
        });
      } else {
        await userDoc.set(
          UserModel(
            uid: user.uid,
            username: user.displayName ?? "User",
            email: user.email ?? "",
            photoURL: user.photoURL,
            fcmToken: fcmToken,
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
            isActive: true,
            signInMethod: signInMethod,
          ).toMap(),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error updating user token: $e');
      rethrow;
    }
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Save user info to Firestore
        await _saveUserInfo(credential.user!, username);

        // Send email verification
        await credential.user!.sendEmailVerification();

        return credential.user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveUserInfo(User user, String username) async {
    try {
      final fcmToken = await _getFCMToken();

      await _firestore
          .collection('myusers')
          .doc(user.uid)
          .set(
            UserModel(
              uid: user.uid,
              username: username,
              email: user.email ?? "",
              photoURL: user.photoURL,
              fcmToken: fcmToken,
              createdAt: DateTime.now(),
              lastLogin: DateTime.now(),
              isActive: true,
              signInMethod: "email",
            ).toMap(),
          );
    } catch (e) {
      // ignore: avoid_print
      print('Error saving user info: $e');
      rethrow;
    }
  }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        if (credential.user!.emailVerified) {
          await _updateUserToken(credential.user!);
          return credential.user;
        } else {
          await credential.user!.sendEmailVerification();
          throw FirebaseAuthException(
            code: "email-not-verified",
            message: "Please verify your email before logging in.",
          );
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _updateUserToken(userCredential.user!, signInMethod: "google");
        return userCredential.user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // Update user status in Firestore
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('myusers').doc(currentUser.uid).update({
          'uid': currentUser.uid, // Added UUID field update
          'isActive': false,
          'lastLogin': Timestamp.fromDate(DateTime.now()),
        });
      }

      await GoogleSignIn().signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
