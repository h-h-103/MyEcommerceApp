import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myecommerceapp/core/theme/app_theme.dart';
import 'package:myecommerceapp/data/models/user_model.dart';
import 'package:myecommerceapp/providers/auth_providers.dart';
import 'package:myecommerceapp/providers/profile_providers.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final authState = ref.watch(authStateProvider);
    final isUpdatingImage = ref.watch(profileActionsProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return Center(
            child: Text('Please login', style: textTheme.titleMedium),
          );
        }

        final profileAsync = ref.watch(userProfileProvider(user.uid));

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 35.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // Profile Picture Section
                          profileAsync.when(
                            data: (userModel) =>
                                _buildProfilePicture(userModel, user, context),
                            loading: () => _buildLoadingAvatar(context),
                            error: (_, __) =>
                                _buildDefaultAvatar(user, context),
                          ),
                          SizedBox(height: 16.h),

                          // User Info
                          profileAsync.when(
                            data: (userModel) => _buildUserInfo(
                              userModel,
                              user,
                              textTheme,
                              colorScheme,
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => Text(
                              user.email ?? 'Unknown User',
                              style: textTheme.bodyMedium,
                            ),
                          ),
                          SizedBox(height: 30.h),

                          // Menu Section Header
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Text(
                              'Account Settings',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),

                  // Menu Items
                  _buildMenuItems(context, user, colorScheme, textTheme),
                ],
              ),

              // Loading overlay for image update
              if (isUpdatingImage)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text(
          'Error loading profile',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildUserInfo(
    UserModel? userModel,
    User user,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Text(
          userModel?.username ?? user.email?.split('@').first ?? 'User',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          userModel?.email ?? user.email ?? '',
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePicture(
    UserModel? userModel,
    User user,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            radius: 50.r,
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: colorScheme.onSurface,
            backgroundImage: userModel?.photoURL != null
                ? NetworkImage(userModel!.photoURL!)
                : null,
            child: userModel?.photoURL == null
                ? Text(
                    ref
                        .read(profileActionsProvider.notifier)
                        .getInitials(userModel?.username ?? user.email ?? 'U'),
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 35.w,
            height: 35.h,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showImagePickerDialog(context, user.uid),
              icon: Icon(Icons.camera_alt, color: Colors.white, size: 18.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingAvatar(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: 50.r,
      backgroundColor: theme.colorScheme.surfaceVariant,
      child: SizedBox(
        width: 30.w,
        height: 30.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(User user, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CircleAvatar(
        radius: 50.r,
        backgroundColor: theme.scaffoldBackgroundColor,
        child: Text(
          ref
              .read(profileActionsProvider.notifier)
              .getInitials(user.email ?? 'U'),
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems(
    BuildContext context,
    User user,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // _buildMenuItem(
        //   context: context,
        //   icon: Icons.person,
        //   title: 'Edit Profile',
        //   onTap: () {},
        // ),
        _buildMenuItem(
          context: context,
          icon: Icons.shopping_bag,
          title: 'My Orders',
          onTap: () {
            Navigator.pushNamed(context, '/orders');
          },
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.location_on,
          title: 'Addresses',
          onTap: () {
            Navigator.pushNamed(context, '/address');
          },
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.language,
          title: 'Language',
          onTap: () => _showLanguageDialog(context),
        ),
        _buildThemeToggle(context, colorScheme, textTheme),
        _buildMenuItem(
          context: context,
          icon: Icons.logout,
          title: 'Logout',
          onTap: () => _showLogoutDialog(context),
          textColor: colorScheme.error,
        ),
        SizedBox(height: 20.h),
      ]),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actualColor = textColor ?? colorScheme.onSurface;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        leading: Container(
          width: 45.w,
          height: 45.h,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: actualColor, size: 22.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: actualColor,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 24.sp,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context, String uid) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetHandle(colorScheme),
            SizedBox(height: 20.h),
            _buildBottomSheetOption(
              context: context,
              icon: Icons.camera_alt,
              text: "Take Photo",
              onTap: () {
                Navigator.pop(context);
                _updateImage(uid, ImageSource.camera);
              },
            ),
            SizedBox(height: 12.h),
            _buildBottomSheetOption(
              context: context,
              icon: Icons.photo_library,
              text: "Choose from Gallery",
              onTap: () {
                Navigator.pop(context);
                _updateImage(uid, ImageSource.gallery);
              },
            ),
            SizedBox(height: 12.h),
            _buildBottomSheetOption(
              context: context,
              icon: Icons.delete,
              text: "Remove Photo",
              textColor: colorScheme.error,
              onTap: () {
                Navigator.pop(context);
                _removeImage(uid);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetHandle(ColorScheme colorScheme) {
    return Container(
      width: 50.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actualColor = textColor ?? colorScheme.onSurface;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: actualColor, size: 20.sp),
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: actualColor,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _updateImage(String uid, ImageSource source) async {
    final result = await ref
        .read(profileActionsProvider.notifier)
        .updateProfileImage(uid, source);

    if (mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Theme.of(context).colorScheme.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeImage(String uid) async {
    final result = await ref
        .read(profileActionsProvider.notifier)
        .removeProfileImage(uid);

    if (mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Theme.of(context).colorScheme.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
        decoration: BoxDecoration(color: colorScheme.surface),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetHandle(colorScheme),
            SizedBox(height: 20.h),
            _buildLanguageOption(context, "English", true),
            _buildLanguageOption(context, "العربية", false),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String language,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        title: Text(
          language,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check, color: colorScheme.primary, size: 20.sp)
            : null,
        onTap: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildThemeToggle(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isDark = ref.watch(isDarkModeProvider);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        secondary: Container(
          width: 45.w,
          height: 45.h,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.brightness_6,
            color: colorScheme.primary,
            size: 22.sp,
          ),
        ),
        title: Text(
          'Dark Mode',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        value: isDark,
        onChanged: (value) {
          ref.read(themeProvider.notifier).toggleTheme();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        activeColor: colorScheme.primary,
        activeTrackColor: colorScheme.primary.withOpacity(0.3),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(profileActionsProvider.notifier).signOutUser();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
