import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myecommerceapp/core/theme/app_theme.dart';

class CustomLogoAuth extends ConsumerWidget {
  const CustomLogoAuth({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final theme = ref.watch(themeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Center(
      child: Container(
        alignment: Alignment.center,
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.grey[100],
          borderRadius: BorderRadius.circular(70),
          border: isDarkMode
              ? Border.all(color: const Color(0xFF2F2F2F), width: 1)
              : null,
        ),
        child: Image.asset(
          "assets/images/splash.png",
          height: 40,
          color: isDarkMode ? Colors.white : null,
          // fit: BoxFit.fill,
        ),
      ),
    );
  }
}
