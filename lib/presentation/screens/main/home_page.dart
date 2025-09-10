import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myecommerceapp/core/theme/app_theme.dart';
import 'package:myecommerceapp/providers/auth_providers.dart';
import 'package:myecommerceapp/presentation/screens/main/tabs/home.dart';
import 'package:myecommerceapp/presentation/screens/main/tabs/favorite.dart';
import 'package:myecommerceapp/presentation/screens/main/tabs/cart.dart';
import 'package:myecommerceapp/presentation/screens/main/tabs/profile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const FavoriteTab(),
    const CartTab(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = ref.watch(themeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Redirect to login if user is null
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: SizedBox(
                width: 50.w,
                height: 50.w,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDarkMode
                ? theme.colorScheme.surface
                : Colors.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: isDarkMode
                ? theme.colorScheme.primary
                : Colors.orange[700],
            unselectedItemColor: isDarkMode
                ? theme.colorScheme.onSurface.withOpacity(0.6)
                : Colors.grey,
            onTap: _onItemTapped,
            selectedFontSize: 12.sp,
            unselectedFontSize: 10.sp,
            iconSize: 24.w,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: isDarkMode
                  ? theme.colorScheme.primary
                  : Colors.orange[700],
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 10.sp,
              color: isDarkMode
                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                  : Colors.grey,
            ),
            elevation: isDarkMode ? 0 : 8,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Icon(Icons.home, size: 24.w),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Icon(
                    Icons.home,
                    size: 26.w,
                    color: isDarkMode
                        ? theme.colorScheme.primary
                        : Colors.orange[700],
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Icon(Icons.favorite, size: 24.w),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Icon(
                    Icons.favorite,
                    size: 26.w,
                    color: isDarkMode
                        ? theme.colorScheme.primary
                        : Colors.orange[700],
                  ),
                ),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Icon(Icons.shopping_cart, size: 24.w),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 26.w,
                    color: isDarkMode
                        ? theme.colorScheme.primary
                        : Colors.orange[700],
                  ),
                ),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Icon(Icons.person, size: 24.w),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Icon(
                    Icons.person,
                    size: 26.w,
                    color: isDarkMode
                        ? theme.colorScheme.primary
                        : Colors.orange[700],
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: SizedBox(
            width: 50.w,
            height: 50.w,
            child: CircularProgressIndicator(
              strokeWidth: 3.w,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? theme.colorScheme.primary : Colors.orange[700]!,
              ),
            ),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  size: 64.w,
                  color: isDarkMode ? Colors.red[400] : Colors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Something went wrong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? Colors.red[400] : Colors.red,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Error: ${error.toString()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode
                        ? theme.colorScheme.onSurface.withOpacity(0.7)
                        : Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? theme.colorScheme.primary
                          : Colors.orange[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: isDarkMode ? 0 : 2,
                    ),
                    child: Text(
                      'Go to Login',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
