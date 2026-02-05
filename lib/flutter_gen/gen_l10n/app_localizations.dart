import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  String get appTitle;

  String get welcome;

  String get welcomeBack;

  String get hello;

  String helloUser(String userName);

  String get common_ok;

  String get common_cancel;

  String get common_save;

  String get common_delete;

  String get common_edit;

  String get common_add;

  String get common_remove;

  String get common_close;

  String get common_done;

  String get common_continue;

  String get common_back;

  String get common_next;

  String get common_yes;

  String get common_no;

  String get common_confirm;

  String get common_retry;

  String get common_refresh;

  String get common_loading;

  String get common_search;

  String get common_filter;

  String get common_sort;

  String get common_share;

  String get common_submit;

  String get error_title;

  String get error_generic;

  String get error_network;

  String get error_timeout;

  String get error_server;

  String get error_unauthorized;

  String get error_notFound;

  String get error_validation;

  String get error_required_field;

  String get error_invalid_email;

  String get error_invalid_password;

  String get error_passwords_dont_match;

  String get empty_state_no_data;

  String get empty_state_no_results;

  String get empty_state_no_items;

  String get empty_state_start_creating;

  String get empty_state_recipes_title;

  String get empty_state_recipes_message;

  String get empty_state_recipes_action;

  String get empty_state_favorites_title;

  String get empty_state_favorites_message;

  String get nav_home;

  String get nav_recipes;

  String get nav_favorites;

  String get nav_profile;

  String get nav_settings;

  String get auth_login;

  String get auth_logout;

  String get auth_signup;

  String get auth_email;

  String get auth_password;

  String get auth_confirm_password;

  String get auth_forgot_password;

  String get auth_reset_password;

  String get auth_create_account;

  String get auth_already_have_account;

  String get auth_dont_have_account;

  String get auth_or_continue_with;

  String get settings_language;

  String get settings_theme;

  String get settings_notifications;

  String get settings_privacy;

  String get settings_about;

  String get settings_help;

  String get settings_terms;

  String get settings_privacy_policy;

  String get recipe_title;

  String get recipe_ingredients;

  String get recipe_instructions;

  String get recipe_prep_time;

  String get recipe_cook_time;

  String get recipe_servings;

  String get recipe_difficulty;

  String get recipe_difficulty_easy;

  String get recipe_difficulty_medium;

  String get recipe_difficulty_hard;

  String get recipe_add_to_favorites;

  String get recipe_remove_from_favorites;

  String plurals_items(int count);

  String plurals_recipes(int count);

  String plurals_minutes(int count);

  String plurals_hours(int count);

  String get date_today;

  String get date_yesterday;

  String get date_tomorrow;

  String get success_saved;

  String get success_deleted;

  String get success_updated;

  String get success_added;

  String get confirm_delete_title;

  String get confirm_delete_message;

  String get confirm_logout_title;

  String get confirm_logout_message;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    default:
      throw FlutterError(
        'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
        'an issue with the localizations generation tool. Please file an issue '
        'on GitHub with a reproducible sample app and the gen-l10n configuration '
        'that was used.'
      );
  }
}
