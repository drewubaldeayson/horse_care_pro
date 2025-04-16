import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel> fetchUserProfile(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.id)
          .update(userModel.toFirestore());
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      // Get current user
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!, password: currentPassword);

      await currentUser.reauthenticateWithCredential(credential);

      // Change password
      await currentUser.updatePassword(newPassword);
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }
}
