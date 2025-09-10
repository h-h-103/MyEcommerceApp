import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    IntroComponent(
      title: "Welcome",
      description: "Discover the app...",
      imagePath: "assets/images/onboard1.jpg",
    ),
    IntroComponent(
      title: "Explore",
      description: "Explore amazing features...",
      imagePath: "assets/images/onboard2.jpg",
    ),
    IntroComponent(
      title: "Get Started",
      description: "Let's dive into the app!",
      imagePath: "assets/images/onboard3.jpg",
    ),
  ];

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  Future<void> _onFinish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (mounted) {
      if (currentUser != null && currentUser.emailVerified) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              children: _pages,
            ),

            // زر تخطي
            Positioned(
              bottom: 40.h,
              left: 20.w,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  "Skip",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16.sp),
                ),
              ),
            ),

            // مؤشر الصفحات
            Positioned(
              left: 0,
              right: 0,
              bottom: 40.h,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: WormEffect(
                    dotHeight: 12.w,
                    dotWidth: 12.w,
                    dotColor: Colors.grey,
                    activeDotColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),

            // زر التالي / إنهاء
            Positioned(
              right: 20.w,
              bottom: 40.h,
              child: TextButton(
                onPressed: _onNext,
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  _currentIndex == _pages.length - 1 ? 'Finish' : 'Next',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IntroComponent extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const IntroComponent({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 350.h, fit: BoxFit.cover),
          SizedBox(height: 30.h),
          Text(
            title,
            style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
