import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myecommerceapp/core/theme/app_theme.dart';
import 'package:myecommerceapp/firebase/firebase_options.dart';
import 'package:myecommerceapp/firebase/messaging_config.dart';
import 'package:myecommerceapp/presentation/screens/auth/login_screen.dart';
import 'package:myecommerceapp/presentation/screens/auth/register_screen.dart';
import 'package:myecommerceapp/presentation/screens/main/profile/address_screen.dart';
import 'package:myecommerceapp/presentation/screens/main/tabs/cart.dart';
import 'package:myecommerceapp/presentation/screens/main/home_page.dart';
import 'package:myecommerceapp/presentation/screens/main/order_confirmation_screen.dart';
import 'package:myecommerceapp/presentation/screens/main/profile/order_screen.dart';
import 'package:myecommerceapp/presentation/screens/start/onboarding_screen.dart';
import 'package:myecommerceapp/presentation/screens/start/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // ignore: avoid_print
    print('Firebase already initialized: $e');
  }

  MessagingConfig.initFirebaseMessaging();
  FirebaseMessaging.onBackgroundMessage(MessagingConfig.messageHandler);

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'E-Commerce App',
          theme: theme,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const Login(),
            '/register': (context) => const SignUp(),
            '/home': (context) => const HomePage(),
            '/cart': (context) => const CartTab(),
            '/address': (context) => const AddressScreen(),
            '/order': (context) => const OrderConfirmationScreen(),
            '/orders': (context) => const OrderScreen(),
          },
        );
      },
    );
  }
}
