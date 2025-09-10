import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myecommerceapp/core/theme/app_theme.dart';

class CustomButtonAuth extends ConsumerWidget {
  final void Function()? onPressed;
  final String title;
  const CustomButtonAuth({super.key, this.onPressed, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialButton(
      height: 40,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDarkMode ? const Color(0xFF6366F1) : Colors.orange,
      textColor: Colors.white,
      onPressed: onPressed,
      child: Text(
        title,
        style:
            theme.elevatedButtonTheme.style?.textStyle?.resolve({}) ??
            theme.textTheme.labelLarge,
      ),
    );
  }
}
