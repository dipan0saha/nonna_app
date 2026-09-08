// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
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
  String get error_network =>
      'Network connection error. Please check your internet connection.';

  @override
  String get error_timeout => 'Request timed out. Please try again.';

  @override
  String get error_server => 'Server error. Please try again later.';

  @override
  String get error_unauthorized =>
      'You are not authorized to perform this action.';

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
  String get empty_state_recipes_message =>
      'Start building your recipe collection';

  @override
  String get empty_state_recipes_action => 'Add Recipe';

  @override
  String get empty_state_favorites_title => 'No Favorites';

  @override
  String get empty_state_favorites_message =>
      'Recipes you favorite will appear here';

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
  String get auth_dont_have_account => 'Don\'t have an account?';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String plurals_recipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
      zero: 'No recipes',
    );
    return '$_temp0';
  }

  @override
  String plurals_minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String plurals_hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
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
  String get confirm_delete_message =>
      'Are you sure you want to delete this item? This action cannot be undone.';

  @override
  String get confirm_logout_title => 'Log Out';

  @override
  String get confirm_logout_message => 'Are you sure you want to log out?';

  @override
  String get gallery_photoDetailTitle => 'Photo Detail';

  @override
  String get gallery_captionLabel => 'Caption:';

  @override
  String get gallery_captionHint => 'Enter caption...';

  @override
  String get gallery_noCaption => 'No caption';

  @override
  String get gallery_tagsLabel => 'Tags:';

  @override
  String gallery_uploadedDate(String date) {
    return 'Uploaded: $date';
  }

  @override
  String get gallery_commentsTitle => 'Comments';

  @override
  String get gallery_noCommentsYet =>
      'No comments yet. Be the first to comment!';

  @override
  String get gallery_editCommentHint => 'Edit comment...';

  @override
  String get gallery_addCommentHint => 'Add a comment...';

  @override
  String get gallery_loginToComment => 'Please log in to comment.';

  @override
  String get gallery_deleteCommentTitle => 'Delete Comment';

  @override
  String get gallery_deleteCommentMessage =>
      'Are you sure you want to delete this comment?';

  @override
  String get gallery_captionUpdatedSuccess => 'Caption updated successfully!';

  @override
  String get gender_male => 'Male';

  @override
  String get gender_female => 'Female';

  @override
  String get gender_neutral => 'Neutral';

  @override
  String get tile_welcome_title => 'Welcome, Little One!';

  @override
  String get tile_welcome_born_today => '🎉 Born today!';

  @override
  String tile_welcome_days_old(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🎉 $count days old',
      one: '🎉 1 day old',
    );
    return '$_temp0';
  }

  @override
  String get tile_predictions_title => 'Prediction Votes';

  @override
  String get tile_predictions_help_text =>
      'When do you think the baby will arrive?';

  @override
  String get tile_predictions_gender_title => 'Gender Prediction';

  @override
  String tile_predictions_gender_your_vote(String gender) {
    return 'Your vote: $gender';
  }

  @override
  String get tile_predictions_gender_boy => 'Boy';

  @override
  String get tile_predictions_gender_girl => 'Girl';

  @override
  String get tile_predictions_birthdate_title => 'Birthdate Prediction';

  @override
  String tile_predictions_birthdate_your_vote(String date) {
    return 'Your vote: $date';
  }

  @override
  String get tile_predictions_birthdate_change => 'Change your prediction';

  @override
  String get tile_predictions_birthdate_pick => 'Pick a date';

  @override
  String tile_predictions_summary(int genderCount, int birthdateCount) {
    String _temp0 = intl.Intl.pluralLogic(
      genderCount,
      locale: localeName,
      other: '$genderCount gender votes',
      one: '1 gender vote',
    );
    String _temp1 = intl.Intl.pluralLogic(
      birthdateCount,
      locale: localeName,
      other: '$birthdateCount birthdate votes',
      one: '1 birthdate vote',
    );
    return 'Total: $_temp0, $_temp1';
  }

  @override
  String get tile_activity_title => 'Engagement Recap';

  @override
  String tile_activity_period(int count) {
    return '${count}d';
  }

  @override
  String get tile_activity_squishes => 'Squishes';

  @override
  String get tile_activity_comments => 'Comments';

  @override
  String get tile_activity_rsvps => 'RSVPs';

  @override
  String get tile_activity_total => 'Total';

  @override
  String get tile_activity_empty => 'No engagement data yet';

  @override
  String get onboarding_owner_carousel_slide1_title =>
      'Your baby\'s story, in one private place';

  @override
  String get onboarding_owner_carousel_slide1_body =>
      'Photos, updates, and everything in between, visible only to the people you invite.';

  @override
  String get onboarding_owner_carousel_slide2_title =>
      'Everyone gets to feel close';

  @override
  String get onboarding_owner_carousel_slide2_body =>
      'Grandparents, aunts, uncles, and friends can follow along, no matter how far away they live.';

  @override
  String get onboarding_owner_carousel_slide3_title =>
      'Celebrate every milestone together';

  @override
  String get onboarding_owner_carousel_slide3_body =>
      'Calendar events, a shared registry, and fun ways to mark the big days.';

  @override
  String get onboarding_owner_carousel_slide4_title => 'Never lose a moment';

  @override
  String get onboarding_owner_carousel_slide4_body =>
      'Every photo and comment, saved in one safe place, for good.';

  @override
  String get onboarding_carousel_next => 'Next';

  @override
  String get onboarding_carousel_get_started => 'Get Started';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get onboarding_signup_title => 'Create your account';

  @override
  String get onboarding_signup_email_label => 'Email';

  @override
  String get onboarding_signup_password_label => 'Password';

  @override
  String get onboarding_signup_create_account => 'Create Account';

  @override
  String get onboarding_signup_login_prompt => 'Already have an account? ';

  @override
  String get onboarding_signup_login_action => 'Log in';

  @override
  String get onboarding_oauth_google => 'Continue with Google';

  @override
  String get onboarding_oauth_facebook => 'Continue with Facebook';

  @override
  String get onboarding_batch_invite_title => 'Invite family & friends';

  @override
  String get onboarding_batch_invite_send => 'Send Invites';

  @override
  String get onboarding_batch_invite_skip => 'Skip for now';

  @override
  String get onboarding_follower_accept => 'Accept Invitation';

  @override
  String get onboarding_coowner_accept => 'Accept & Join as Owner';

  @override
  String get onboarding_wrong_email_title =>
      'This invite isn\'t for your account';

  @override
  String get onboarding_wrong_email_switch => 'Sign out & switch account';
}
