class AppConstants {
  static const String appName = 'UAS PSM BI';
  static const String appVersion = '1.0.0';

  /// Optional URL to download the APK (or Play Store link).
  /// Set it at build time:
  /// `flutter build apk --release --dart-define=APP_DOWNLOAD_URL=https://example.com/app.apk`
  static String get appDownloadUrl => const String.fromEnvironment('APP_DOWNLOAD_URL');
  
  // Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Categories
  static const List<String> productCategories = [
    'Furniture',
    'Office Supplies',
    'Technology',
  ];
  
  // Customer Segments
  static const List<String> customerSegments = [
    'Consumer',
    'Corporate',
    'Home Office',
  ];
  
  // Regions
  static const List<String> regionNames = [
    'West',
    'East',
    'Central',
    'South',
  ];
  
  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserRole = 'user_role';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserName = 'user_name';
}
