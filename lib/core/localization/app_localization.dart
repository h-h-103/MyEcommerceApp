import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Locale Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// Localization Provider
final localizationProvider = FutureProvider<AppLocalizations>((ref) async {
  final locale = ref.watch(localeProvider);
  final localizations = AppLocalizations(locale);
  await localizations.load();
  return localizations;
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar')); // Default to Arabic

  void toggleLocale() {
    state = state.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
  }

  void setLocale(String languageCode) {
    state = Locale(languageCode);
  }
}

class AppLocalizations {
  final Locale locale;
  Map<String, String>? _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/lang/${locale.languageCode}.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading localization file: $e');
      // Fallback to English if the file doesn't exist
      if (locale.languageCode != 'en') {
        try {
          String jsonString = await rootBundle.loadString(
            'assets/lang/en.json',
          );
          Map<String, dynamic> jsonMap = json.decode(jsonString);
          _localizedStrings = jsonMap.map((key, value) {
            return MapEntry(key, value.toString());
          });
          return true;
        } catch (e) {
          // ignore: avoid_print
          print('Error loading fallback localization file: $e');
          return false;
        }
      }
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings?[key] ?? key;
  }

  // Helper method for easy access
  String t(String key) => translate(key);
}

// Custom Localization Delegate
class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}

// Extension for easy access to translations
extension LocalizationExtension on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context).translate(this);
  }
}
