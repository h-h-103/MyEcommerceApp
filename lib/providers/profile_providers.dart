import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myecommerceapp/data/models/user_model.dart';
import 'package:myecommerceapp/data/repositories/profile_repository.dart';
import 'package:myecommerceapp/providers/auth_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// User Profile Provider
final userProfileProvider = FutureProvider.family<UserModel?, String>((
  ref,
  uid,
) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserProfile(uid);
});

// Profile Actions Provider
final profileActionsProvider =
    StateNotifierProvider<ProfileActionsNotifier, bool>((ref) {
      return ProfileActionsNotifier(ref);
    });

// Profile Actions Notifier
class ProfileActionsNotifier extends StateNotifier<bool> {
  ProfileActionsNotifier(this.ref) : super(false);

  final Ref ref;

  // Update profile image
  Future<String?> updateProfileImage(String uid, ImageSource source) async {
    state = true; // Set loading state

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.updateProfileImage(uid, source);

      // Refresh the profile data
      ref.invalidate(userProfileProvider(uid));

      return 'Profile picture updated successfully';
    } catch (e) {
      return 'Failed to update picture: $e';
    } finally {
      state = false; // Clear loading state
    }
  }

  // Remove profile image
  Future<String?> removeProfileImage(String uid) async {
    state = true; // Set loading state

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.removeProfileImage(uid);

      // Refresh the profile data
      ref.invalidate(userProfileProvider(uid));

      return 'Profile picture removed successfully';
    } catch (e) {
      return 'Failed to remove picture: $e';
    } finally {
      state = false; // Clear loading state
    }
  }

  // Get initials from text
  String getInitials(String text) {
    if (text.isEmpty) return 'U';
    if (text.contains('@')) {
      return text.split('@').first[0].toUpperCase();
    }
    return text[0].toUpperCase();
  }

  // Sign out user
  Future<void> signOutUser() async {
    await ref.read(authNotifierProvider.notifier).signOut();
  }
}
