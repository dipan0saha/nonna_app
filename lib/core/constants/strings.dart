/// App-wide string constants
///
/// Centralizes string literals to prevent typos and improve maintainability.
/// Includes error messages, validation messages, and default values.
class AppStrings {
  // Prevent instantiation
  AppStrings._();

  // ============================================================
  // App Information
  // ============================================================

  static const String appName = 'Nonna';
  static const String appTagline = 'Share your baby journey';

  // ============================================================
  // Error Messages
  // ============================================================

  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorUnauthorized =
      'You are not authorized to perform this action.';
  static const String errorNotFound = 'The requested resource was not found.';
  static const String errorServerError =
      'Server error. Please try again later.';
  static const String errorInvalidInput =
      'Invalid input. Please check your data.';
  static const String errorDataCorrupted =
      'Data is corrupted. Please try again.';

  // Authentication errors
  static const String errorInvalidEmail = 'Invalid email address.';
  static const String errorInvalidPassword = 'Invalid password.';
  static const String errorWeakPassword = 'Password is too weak.';
  static const String errorEmailInUse = 'Email is already in use.';
  static const String errorUserNotFound = 'User not found.';
  static const String errorWrongPassword = 'Incorrect password.';
  static const String errorSessionExpired =
      'Your session has expired. Please log in again.';

  // File upload errors
  static const String errorFileTooLarge = 'File is too large.';
  static const String errorInvalidFileType = 'Invalid file type.';
  static const String errorUploadFailed = 'Upload failed. Please try again.';

  // Permission errors
  static const String errorPermissionDenied = 'Permission denied.';
  static const String errorCameraPermission = 'Camera permission is required.';
  static const String errorStoragePermission =
      'Storage permission is required.';
  static const String errorNotificationPermission =
      'Notification permission is required.';

  // ============================================================
  // Validation Messages
  // ============================================================

  static const String validationRequired = 'This field is required.';
  static const String validationEmailInvalid =
      'Please enter a valid email address.';
  static const String validationPasswordTooShort =
      'Password must be at least 8 characters.';
  static const String validationPasswordsMismatch = 'Passwords do not match.';
  static const String validationUrlInvalid = 'Please enter a valid URL.';
  static const String validationPhoneInvalid =
      'Please enter a valid phone number.';
  static const String validationMinLength = 'Must be at least %d characters.';
  static const String validationMaxLength = 'Must be at most %d characters.';
  static const String validationMinValue = 'Must be at least %d.';
  static const String validationMaxValue = 'Must be at most %d.';

  // ============================================================
  // Success Messages
  // ============================================================

  static const String successSaved = 'Saved successfully.';
  static const String successDeleted = 'Deleted successfully.';
  static const String successUpdated = 'Updated successfully.';
  static const String successUploaded = 'Uploaded successfully.';
  static const String successShared = 'Shared successfully.';
  static const String successInvited = 'Invitation sent successfully.';

  // ============================================================
  // Confirmation Messages
  // ============================================================

  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String confirmDeletePermanent =
      'This action cannot be undone. Are you sure?';
  static const String confirmLeave = 'Are you sure you want to leave?';
  static const String confirmCancel = 'Are you sure you want to cancel?';

  // ============================================================
  // Empty State Messages
  // ============================================================

  static const String emptyEvents = 'No events yet.';
  static const String emptyPhotos = 'No photos yet.';
  static const String emptyRegistry = 'No registry items yet.';
  static const String emptyNotifications = 'No notifications.';
  static const String emptyFollowers = 'No followers yet.';
  static const String emptyComments = 'No comments yet.';
  static const String emptySearchResults = 'No results found.';

  // ============================================================
  // Loading Messages
  // ============================================================

  static const String loadingGeneric = 'Loading...';
  static const String loadingData = 'Loading data...';
  static const String loadingImage = 'Loading image...';
  static const String uploading = 'Uploading...';
  static const String processing = 'Processing...';
  static const String savingChanges = 'Saving changes...';

  // ============================================================
  // Button Labels
  // ============================================================

  static const String buttonOk = 'OK';
  static const String buttonCancel = 'Cancel';
  static const String buttonSave = 'Save';
  static const String buttonDelete = 'Delete';
  static const String buttonEdit = 'Edit';
  static const String buttonShare = 'Share';
  static const String buttonInvite = 'Invite';
  static const String buttonRetry = 'Retry';
  static const String buttonContinue = 'Continue';
  static const String buttonBack = 'Back';
  static const String buttonNext = 'Next';
  static const String buttonDone = 'Done';
  static const String buttonSkip = 'Skip';
  static const String buttonLogout = 'Logout';
  static const String buttonLogin = 'Login';
  static const String buttonSignup = 'Sign Up';

  // ============================================================
  // Default Values
  // ============================================================

  static const String defaultUsername = 'Guest';
  static const String defaultBabyName = 'Baby';
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  static const String defaultBabyImage = 'assets/images/default_baby.png';

  // ============================================================
  // Date/Time Formats
  // ============================================================

  static const String dateFormatShort = 'MM/dd/yyyy';
  static const String dateFormatLong = 'MMMM d, yyyy';
  static const String dateFormatFull = 'EEEE, MMMM d, yyyy';
  static const String timeFormat12Hour = 'h:mm a';
  static const String timeFormat24Hour = 'HH:mm';
  static const String dateTimeFormat = 'MM/dd/yyyy h:mm a';

  // ============================================================
  // Role Names
  // ============================================================

  static const String roleOwner = 'Owner';
  static const String roleFollower = 'Follower';

  // ============================================================
  // Feature Names
  // ============================================================

  static const String featureCalendar = 'Calendar';
  static const String featureGallery = 'Gallery';
  static const String featureRegistry = 'Registry';
  static const String featureFun = 'Fun';
  static const String featureProfile = 'Profile';
}
