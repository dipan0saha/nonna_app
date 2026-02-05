import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nonna';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get hello => 'Hello';

  @override
  String helloUser(String userName) {
    return 'Hello, $userName!';
  }

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_add => 'Add';

  @override
  String get common_remove => 'Remove';

  @override
  String get common_close => 'Close';

  @override
  String get common_done => 'Done';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_refresh => 'Refresh';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_search => 'Search';

  @override
  String get common_filter => 'Filter';

  @override
  String get common_sort => 'Sort';

  @override
  String get common_share => 'Share';

  @override
  String get common_submit => 'Submit';

  @override
  String get error_title => 'Error';

  @override
  String get error_generic => 'Something went wrong. Please try again.';

  @override
  String get error_network => 'Network connection error. Please check your internet connection.';

  @override
  String get error_timeout => 'Request timed out. Please try again.';

  @override
  String get error_server => 'Server error. Please try again later.';

  @override
  String get error_unauthorized => 'You are not authorized to perform this action.';

  @override
  String get error_notFound => 'The requested resource was not found.';

  @override
  String get error_validation => 'Please check your input and try again.';

  @override
  String get error_required_field => 'This field is required';

  @override
  String get error_invalid_email => 'Please enter a valid email address';

  @override
  String get error_invalid_password => 'Password must be at least 8 characters';

  @override
  String get error_passwords_dont_match => 'Passwords do not match';

  @override
  String get empty_state_no_data => 'No data available';

  @override
  String get empty_state_no_results => 'No results found';

  @override
  String get empty_state_no_items => 'No items yet';

  @override
  String get empty_state_start_creating => 'Start by creating your first item';

  @override
  String get empty_state_recipes_title => 'No Recipes Yet';

  @override
  String get empty_state_recipes_message => 'Start building your recipe collection';

  @override
  String get empty_state_recipes_action => 'Add Recipe';

  @override
  String get empty_state_favorites_title => 'No Favorites';

  @override
  String get empty_state_favorites_message => 'Recipes you favorite will appear here';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_recipes => 'Recipes';

  @override
  String get nav_favorites => 'Favorites';

  @override
  String get nav_profile => 'Profile';

  @override
  String get nav_settings => 'Settings';

  @override
  String get auth_login => 'Log In';

  @override
  String get auth_logout => 'Log Out';

  @override
  String get auth_signup => 'Sign Up';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_confirm_password => 'Confirm Password';

  @override
  String get auth_forgot_password => 'Forgot Password?';

  @override
  String get auth_reset_password => 'Reset Password';

  @override
  String get auth_create_account => 'Create Account';

  @override
  String get auth_already_have_account => 'Already have an account?';

  @override
  String get auth_dont_have_account => "Don't have an account?";

  @override
  String get auth_or_continue_with => 'Or continue with';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_privacy => 'Privacy';

  @override
  String get settings_about => 'About';

  @override
  String get settings_help => 'Help & Support';

  @override
  String get settings_terms => 'Terms of Service';

  @override
  String get settings_privacy_policy => 'Privacy Policy';

  @override
  String get recipe_title => 'Recipe';

  @override
  String get recipe_ingredients => 'Ingredients';

  @override
  String get recipe_instructions => 'Instructions';

  @override
  String get recipe_prep_time => 'Prep Time';

  @override
  String get recipe_cook_time => 'Cook Time';

  @override
  String get recipe_servings => 'Servings';

  @override
  String get recipe_difficulty => 'Difficulty';

  @override
  String get recipe_difficulty_easy => 'Easy';

  @override
  String get recipe_difficulty_medium => 'Medium';

  @override
  String get recipe_difficulty_hard => 'Hard';

  @override
  String get recipe_add_to_favorites => 'Add to Favorites';

  @override
  String get recipe_remove_from_favorites => 'Remove from Favorites';

  @override
  String plurals_items(int count) {
    return intl.Intl.plural(
      count,
      zero: 'No items',
      one: '1 item',
      other: '$count items',
      name: 'plurals_items',
      desc: 'Plural form for items count',
      args: <Object>[count],
    );
  }

  @override
  String plurals_recipes(int count) {
    return intl.Intl.plural(
      count,
      zero: 'No recipes',
      one: '1 recipe',
      other: '$count recipes',
      name: 'plurals_recipes',
      desc: 'Plural form for recipes count',
      args: <Object>[count],
    );
  }

  @override
  String plurals_minutes(int count) {
    return intl.Intl.plural(
      count,
      one: '1 minute',
      other: '$count minutes',
      name: 'plurals_minutes',
      desc: 'Plural form for minutes',
      args: <Object>[count],
    );
  }

  @override
  String plurals_hours(int count) {
    return intl.Intl.plural(
      count,
      one: '1 hour',
      other: '$count hours',
      name: 'plurals_hours',
      desc: 'Plural form for hours',
      args: <Object>[count],
    );
  }

  @override
  String get date_today => 'Today';

  @override
  String get date_yesterday => 'Yesterday';

  @override
  String get date_tomorrow => 'Tomorrow';

  @override
  String get success_saved => 'Saved successfully';

  @override
  String get success_deleted => 'Deleted successfully';

  @override
  String get success_updated => 'Updated successfully';

  @override
  String get success_added => 'Added successfully';

  @override
  String get confirm_delete_title => 'Delete Item';

  @override
  String get confirm_delete_message => 'Are you sure you want to delete this item? This action cannot be undone.';

  @override
  String get confirm_logout_title => 'Log Out';

  @override
  String get confirm_logout_message => 'Are you sure you want to log out?';
}
