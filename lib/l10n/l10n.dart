import 'package:flutter/material.dart';

/// Supported locales for the application.
/// 
/// This class contains the list of locales that the application supports
/// and provides helper methods for locale management.
class L10n {
  /// Private constructor to prevent instantiation
  L10n._();

  /// List of all supported locales
  static const List<Locale> all = [
    Locale('en'), // English
    Locale('es'), // Spanish
  ];

  /// Default fallback locale when user's locale is not supported
  static const Locale fallback = Locale('en');

  /// Get the locale name for display purposes
  static String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode;
    }
  }

  /// Get the native locale name for display
  static String getNativeLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode;
    }
  }

  /// Check if a locale is supported
  static bool isSupported(Locale locale) {
    return all.any((l) => l.languageCode == locale.languageCode);
  }

  /// Get the best matching locale from the supported locales
  /// based on the user's preferred locales
  static Locale? localeResolutionCallback(
    List<Locale>? locales,
    Iterable<Locale> supportedLocales,
  ) {
    if (locales == null || locales.isEmpty) {
      return fallback;
    }

    // Try to find an exact match
    for (final locale in locales) {
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode &&
            supportedLocale.countryCode == locale.countryCode) {
          return supportedLocale;
        }
      }
    }

    // Try to find a language match (ignoring country)
    for (final locale in locales) {
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return supportedLocale;
        }
      }
    }

    // Return fallback locale if no match found
    return fallback;
  }

  /// Get locale from language code string
  static Locale? fromLanguageCode(String? code) {
    if (code == null) return null;
    
    try {
      return all.firstWhere(
        (locale) => locale.languageCode == code,
        orElse: () => fallback,
      );
    } catch (e) {
      return fallback;
    }
  }
}
