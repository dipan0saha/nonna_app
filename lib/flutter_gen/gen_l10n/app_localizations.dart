import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Nonna'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Welcome back message for returning users
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// General greeting
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Personalized greeting with user name
  ///
  /// In en, this message translates to:
  /// **'Hello, {userName}!'**
  String helloUser(String userName);

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// Add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// Remove button label
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get common_remove;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// Continue button label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// Yes button label
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No button label
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// Refresh button label
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get common_refresh;

  /// Loading indicator message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// Filter button label
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get common_filter;

  /// Sort button label
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get common_sort;

  /// Share button label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get common_share;

  /// Submit button label
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get common_submit;

  /// Default error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error_title;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get error_generic;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network connection error. Please check your internet connection.'**
  String get error_network;

  /// Timeout error message
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get error_timeout;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get error_server;

  /// Unauthorized error message
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to perform this action.'**
  String get error_unauthorized;

  /// Not found error message
  ///
  /// In en, this message translates to:
  /// **'The requested resource was not found.'**
  String get error_notFound;

  /// Validation error message
  ///
  /// In en, this message translates to:
  /// **'Please check your input and try again.'**
  String get error_validation;

  /// Required field validation error
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get error_required_field;

  /// Invalid email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get error_invalid_email;

  /// Invalid password validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get error_invalid_password;

  /// Password mismatch validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get error_passwords_dont_match;

  /// Default empty state message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get empty_state_no_data;

  /// Empty state for search results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get empty_state_no_results;

  /// Empty state for empty lists
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get empty_state_no_items;

  /// Empty state call to action
  ///
  /// In en, this message translates to:
  /// **'Start by creating your first item'**
  String get empty_state_start_creating;

  /// Empty state title for recipes
  ///
  /// In en, this message translates to:
  /// **'No Recipes Yet'**
  String get empty_state_recipes_title;

  /// Empty state message for recipes
  ///
  /// In en, this message translates to:
  /// **'Start building your recipe collection'**
  String get empty_state_recipes_message;

  /// Empty state action button for recipes
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get empty_state_recipes_action;

  /// Empty state title for favorites
  ///
  /// In en, this message translates to:
  /// **'No Favorites'**
  String get empty_state_favorites_title;

  /// Empty state message for favorites
  ///
  /// In en, this message translates to:
  /// **'Recipes you favorite will appear here'**
  String get empty_state_favorites_message;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// Recipes navigation label
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get nav_recipes;

  /// Favorites navigation label
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get nav_favorites;

  /// Profile navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// Settings navigation label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get auth_login;

  /// Logout button label
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get auth_logout;

  /// Sign up button label
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get auth_signup;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirm_password;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgot_password;

  /// Reset password button label
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get auth_reset_password;

  /// Create account button label
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get auth_create_account;

  /// Already have account message
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get auth_already_have_account;

  /// Don't have account message
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_dont_have_account;

  /// Social login separator text
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get auth_or_continue_with;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// Theme settings label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// Notifications settings label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// Privacy settings label
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settings_privacy;

  /// About settings label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// Help and support settings label
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settings_help;

  /// Terms of service label
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settings_terms;

  /// Privacy policy label
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy_policy;

  /// Recipe screen title
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipe_title;

  /// Recipe ingredients section
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipe_ingredients;

  /// Recipe instructions section
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get recipe_instructions;

  /// Recipe preparation time label
  ///
  /// In en, this message translates to:
  /// **'Prep Time'**
  String get recipe_prep_time;

  /// Recipe cooking time label
  ///
  /// In en, this message translates to:
  /// **'Cook Time'**
  String get recipe_cook_time;

  /// Recipe servings label
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get recipe_servings;

  /// Recipe difficulty label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get recipe_difficulty;

  /// Easy difficulty level
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get recipe_difficulty_easy;

  /// Medium difficulty level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get recipe_difficulty_medium;

  /// Hard difficulty level
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get recipe_difficulty_hard;

  /// Add recipe to favorites button
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get recipe_add_to_favorites;

  /// Remove recipe from favorites button
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get recipe_remove_from_favorites;

  /// Plural form for items count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String plurals_items(int count);

  /// Plural form for recipes count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No recipes} =1{1 recipe} other{{count} recipes}}'**
  String plurals_recipes(int count);

  /// Plural form for minutes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String plurals_minutes(int count);

  /// Plural form for hours
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String plurals_hours(int count);

  /// Today date label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get date_today;

  /// Yesterday date label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get date_yesterday;

  /// Tomorrow date label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get date_tomorrow;

  /// Success message for save action
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get success_saved;

  /// Success message for delete action
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get success_deleted;

  /// Success message for update action
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get success_updated;

  /// Success message for add action
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get success_added;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get confirm_delete_title;

  /// Delete confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item? This action cannot be undone.'**
  String get confirm_delete_message;

  /// Logout confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get confirm_logout_title;

  /// Logout confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirm_logout_message;

  /// Photo detail screen app bar title
  ///
  /// In en, this message translates to:
  /// **'Photo Detail'**
  String get gallery_photoDetailTitle;

  /// Caption section label on photo detail screen
  ///
  /// In en, this message translates to:
  /// **'Caption:'**
  String get gallery_captionLabel;

  /// Hint text for caption input on photo detail screen
  ///
  /// In en, this message translates to:
  /// **'Enter caption...'**
  String get gallery_captionHint;

  /// Fallback text when photo has no caption
  ///
  /// In en, this message translates to:
  /// **'No caption'**
  String get gallery_noCaption;

  /// Tags section label on photo detail screen
  ///
  /// In en, this message translates to:
  /// **'Tags:'**
  String get gallery_tagsLabel;

  /// Uploaded date label on photo detail screen
  ///
  /// In en, this message translates to:
  /// **'Uploaded: {date}'**
  String gallery_uploadedDate(String date);

  /// Comments section title on photo detail screen
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get gallery_commentsTitle;

  /// Empty state message when a photo has no comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first to comment!'**
  String get gallery_noCommentsYet;

  /// Hint text when editing an existing comment
  ///
  /// In en, this message translates to:
  /// **'Edit comment...'**
  String get gallery_editCommentHint;

  /// Hint text for adding a new comment
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get gallery_addCommentHint;

  /// Prompt shown when unauthenticated user tries to comment
  ///
  /// In en, this message translates to:
  /// **'Please log in to comment.'**
  String get gallery_loginToComment;

  /// Delete comment confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get gallery_deleteCommentTitle;

  /// Delete comment confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get gallery_deleteCommentMessage;

  /// Success message shown after caption update
  ///
  /// In en, this message translates to:
  /// **'Caption updated successfully!'**
  String get gallery_captionUpdatedSuccess;

  /// Male gender display name
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get gender_male;

  /// Female gender display name
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get gender_female;

  /// Neutral/unknown gender display name
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get gender_neutral;

  /// Title of the new baby welcome tile
  ///
  /// In en, this message translates to:
  /// **'Welcome, Little One!'**
  String get tile_welcome_title;

  /// Label when the baby is born today
  ///
  /// In en, this message translates to:
  /// **'🎉 Born today!'**
  String get tile_welcome_born_today;

  /// Label displaying how many days old the baby is
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{🎉 1 day old} other{🎉 {count} days old}}'**
  String tile_welcome_days_old(int count);

  /// Title of the prediction votes tile
  ///
  /// In en, this message translates to:
  /// **'Prediction Votes'**
  String get tile_predictions_title;

  /// Help text inside birthdate prediction date picker dialog
  ///
  /// In en, this message translates to:
  /// **'When do you think the baby will arrive?'**
  String get tile_predictions_help_text;

  /// Subheading for gender prediction section
  ///
  /// In en, this message translates to:
  /// **'Gender Prediction'**
  String get tile_predictions_gender_title;

  /// Displays the user's gender prediction vote
  ///
  /// In en, this message translates to:
  /// **'Your vote: {gender}'**
  String tile_predictions_gender_your_vote(String gender);

  /// Label for Boy gender option
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get tile_predictions_gender_boy;

  /// Label for Girl gender option
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get tile_predictions_gender_girl;

  /// Subheading for birthdate prediction section
  ///
  /// In en, this message translates to:
  /// **'Birthdate Prediction'**
  String get tile_predictions_birthdate_title;

  /// Displays the user's birthdate prediction vote
  ///
  /// In en, this message translates to:
  /// **'Your vote: {date}'**
  String tile_predictions_birthdate_your_vote(String date);

  /// Button label to change birthdate prediction
  ///
  /// In en, this message translates to:
  /// **'Change your prediction'**
  String get tile_predictions_birthdate_change;

  /// Button label to pick a birthdate prediction
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get tile_predictions_birthdate_pick;

  /// Summary string of total votes cast
  ///
  /// In en, this message translates to:
  /// **'Total: {genderCount, plural, =1{1 gender vote} other{{genderCount} gender votes}}, {birthdateCount, plural, =1{1 birthdate vote} other{{birthdateCount} birthdate votes}}'**
  String tile_predictions_summary(int genderCount, int birthdateCount);

  /// Title of the activity list/engagement recap tile
  ///
  /// In en, this message translates to:
  /// **'Engagement Recap'**
  String get tile_activity_title;

  /// Displays lookback period options (e.g. 7d, 30d, 90d)
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String tile_activity_period(int count);

  /// Label for photo squish reactions metric
  ///
  /// In en, this message translates to:
  /// **'Squishes'**
  String get tile_activity_squishes;

  /// Label for comments metric
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get tile_activity_comments;

  /// Label for event RSVPs metric
  ///
  /// In en, this message translates to:
  /// **'RSVPs'**
  String get tile_activity_rsvps;

  /// Label for total engagement metrics
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get tile_activity_total;

  /// Empty state label when no activity exists
  ///
  /// In en, this message translates to:
  /// **'No engagement data yet'**
  String get tile_activity_empty;

  /// Owner carousel slide 1 headline
  ///
  /// In en, this message translates to:
  /// **'Your baby\'s story, in one private place'**
  String get onboarding_owner_carousel_slide1_title;

  /// No description provided for @onboarding_owner_carousel_slide1_body.
  ///
  /// In en, this message translates to:
  /// **'Photos, updates, and everything in between, visible only to the people you invite.'**
  String get onboarding_owner_carousel_slide1_body;

  /// No description provided for @onboarding_owner_carousel_slide2_title.
  ///
  /// In en, this message translates to:
  /// **'Everyone gets to feel close'**
  String get onboarding_owner_carousel_slide2_title;

  /// No description provided for @onboarding_owner_carousel_slide2_body.
  ///
  /// In en, this message translates to:
  /// **'Grandparents, aunts, uncles, and friends can follow along, no matter how far away they live.'**
  String get onboarding_owner_carousel_slide2_body;

  /// No description provided for @onboarding_owner_carousel_slide3_title.
  ///
  /// In en, this message translates to:
  /// **'Celebrate every milestone together'**
  String get onboarding_owner_carousel_slide3_title;

  /// No description provided for @onboarding_owner_carousel_slide3_body.
  ///
  /// In en, this message translates to:
  /// **'Calendar events, a shared registry, and fun ways to mark the big days.'**
  String get onboarding_owner_carousel_slide3_body;

  /// No description provided for @onboarding_owner_carousel_slide4_title.
  ///
  /// In en, this message translates to:
  /// **'Never lose a moment'**
  String get onboarding_owner_carousel_slide4_title;

  /// No description provided for @onboarding_owner_carousel_slide4_body.
  ///
  /// In en, this message translates to:
  /// **'Every photo and comment, saved in one safe place, for good.'**
  String get onboarding_owner_carousel_slide4_body;

  /// No description provided for @onboarding_carousel_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_carousel_next;

  /// No description provided for @onboarding_carousel_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_carousel_get_started;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_signup_title.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get onboarding_signup_title;

  /// No description provided for @onboarding_signup_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get onboarding_signup_email_label;

  /// No description provided for @onboarding_signup_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get onboarding_signup_password_label;

  /// No description provided for @onboarding_signup_create_account.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get onboarding_signup_create_account;

  /// No description provided for @onboarding_signup_login_prompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get onboarding_signup_login_prompt;

  /// No description provided for @onboarding_signup_login_action.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get onboarding_signup_login_action;

  /// No description provided for @onboarding_oauth_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get onboarding_oauth_google;

  /// No description provided for @onboarding_oauth_facebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get onboarding_oauth_facebook;

  /// No description provided for @onboarding_batch_invite_title.
  ///
  /// In en, this message translates to:
  /// **'Invite family & friends'**
  String get onboarding_batch_invite_title;

  /// No description provided for @onboarding_batch_invite_send.
  ///
  /// In en, this message translates to:
  /// **'Send Invites'**
  String get onboarding_batch_invite_send;

  /// No description provided for @onboarding_batch_invite_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboarding_batch_invite_skip;

  /// No description provided for @onboarding_follower_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept Invitation'**
  String get onboarding_follower_accept;

  /// No description provided for @onboarding_coowner_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept & Join as Owner'**
  String get onboarding_coowner_accept;

  /// No description provided for @onboarding_wrong_email_title.
  ///
  /// In en, this message translates to:
  /// **'This invite isn\'t for your account'**
  String get onboarding_wrong_email_title;

  /// No description provided for @onboarding_wrong_email_switch.
  ///
  /// In en, this message translates to:
  /// **'Sign out & switch account'**
  String get onboarding_wrong_email_switch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
