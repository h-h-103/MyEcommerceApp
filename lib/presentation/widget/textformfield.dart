import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myecommerceapp/core/theme/app_theme.dart';

class CustomTextForm extends ConsumerWidget {
  final String hinttext;
  final TextEditingController mycontroller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const CustomTextForm({
    super.key,
    required this.hinttext,
    required this.mycontroller,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return TextFormField(
      controller: mycontroller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      onTap: onTap,
      onChanged: onChanged,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hinttext,
        hintStyle: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.grey[400] : Colors.blueGrey,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.grey[100],
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: isDarkMode
                ? const Color(0xFF2F2F2F)
                : const Color.fromARGB(255, 184, 184, 184),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: isDarkMode ? const Color(0xFF2F2F2F) : Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: isDarkMode ? const Color(0xFF6366F1) : Colors.orange,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}

// Enhanced Theme Toggle Widget
class ThemeToggleSwitch extends ConsumerWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Switch.adaptive(
      value: isDarkMode,
      onChanged: (value) {
        themeNotifier.toggleTheme();
      },
      activeColor: const Color(0xFF6366F1),
    );
  }
}

// Theme Selection Widget
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.light_mode),
          title: const Text('Light Theme'),
          trailing: Radio<bool>(
            value: false,
            groupValue: isDarkMode,
            onChanged: (value) {
              themeNotifier.setLightTheme();
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('Dark Theme'),
          trailing: Radio<bool>(
            value: true,
            groupValue: isDarkMode,
            onChanged: (value) {
              themeNotifier.setDarkTheme();
            },
          ),
        ),
      ],
    );
  }
}

// Optional: Common validators for reuse (unchanged)
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
