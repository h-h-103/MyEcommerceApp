import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError("Should be overridden in main()");
});

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

// Dark mode state provider - this now properly reads from the current theme
final isDarkModeProvider = Provider<bool>((ref) {
  final theme = ref.watch(themeProvider);
  return theme.brightness == Brightness.dark;
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  final SharedPreferences _prefs;
  static const String _darkModeKey = 'is_dark_mode';

  ThemeNotifier(this._prefs) : super(_getInitialTheme(_prefs));

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    scaffoldBackgroundColor: const Color(0xFF0F0F0F),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F1F1F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2F2F2F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: GoogleFonts.poppins(color: Colors.grey[400]),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // Get initial theme from SharedPreferences
  static ThemeData _getInitialTheme(SharedPreferences prefs) {
    final isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    return isDarkMode ? _darkTheme : _lightTheme;
  }

  // Get current dark mode state
  bool get isDarkMode => state.brightness == Brightness.dark;

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newIsDarkMode = !isDarkMode;
    state = newIsDarkMode ? _darkTheme : _lightTheme;
    await _saveDarkModePreference(newIsDarkMode);
  }

  // Set light theme
  Future<void> setLightTheme() async {
    state = _lightTheme;
    await _saveDarkModePreference(false);
  }

  // Set dark theme
  Future<void> setDarkTheme() async {
    state = _darkTheme;
    await _saveDarkModePreference(true);
  }

  // Helper method to save dark mode preference
  Future<void> _saveDarkModePreference(bool isDarkMode) async {
    try {
      await _prefs.setBool(_darkModeKey, isDarkMode);
      // ignore: avoid_print
      print('Dark mode preference saved: $isDarkMode'); // Debug log
    } catch (e) {
      // ignore: avoid_print
      print('Error saving dark mode preference: $e'); // Error handling
    }
  }

  // Method to get saved dark mode preference (useful for debugging)
  bool getSavedDarkModePreference() {
    return _prefs.getBool(_darkModeKey) ?? false;
  }
}

// Optional: You can also create a separate provider for just the boolean state
final darkModeStateProvider = StateNotifierProvider<DarkModeNotifier, bool>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DarkModeNotifier(prefs);
});

class DarkModeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const String _darkModeKey = 'is_dark_mode';

  DarkModeNotifier(this._prefs) : super(_prefs.getBool(_darkModeKey) ?? false);

  Future<void> toggle() async {
    state = !state;
    await _prefs.setBool(_darkModeKey, state);
  }

  Future<void> setDarkMode(bool isDark) async {
    state = isDark;
    await _prefs.setBool(_darkModeKey, isDark);
  }
}
