// Constants spécifiques à l'application Khidmeti Users
class UserConstants {
  // Navigation
  static const String homeRoute = '/home';
  static const String authRoute = '/auth';
  static const String searchRoute = '/search';
  static const String profileRoute = '/profile';
  static const String chatRoute = '/chat';
  static const String requestsRoute = '/requests';
  
  // Collections Firestore
  static const String usersCollection = 'users';
  static const String requestsCollection = 'requests';
  static const String chatsCollection = 'chats';
  static const String notificationsCollection = 'notifications';
  
  // Assets
  static const List<String> userAvatars = [
    'assets/avatars/users/avatar_user_1.svg',
    'assets/avatars/users/avatar_user_2.svg',
    'assets/avatars/users/avatar_user_3.svg',
    'assets/avatars/users/avatar_user_4.svg',
    'assets/avatars/users/avatar_user_5.svg',
    'assets/avatars/users/avatar_user_6.svg',
    'assets/avatars/users/avatar_user_7.svg',
    'assets/avatars/users/avatar_user_8.svg',
    'assets/avatars/users/avatar_user_9.svg',
    'assets/avatars/users/avatar_user_10.svg',
  ];
  
  // Animations
  static const String splashAnimation = 'assets/animations/splash_animation.json';
  static const String loginAnimation = 'assets/animations/login_animation.json';
  static const String loadingAnimation = 'assets/animations/loading_spinner.json';
  static const String successAnimation = 'assets/animations/success_animation.json';
  static const String errorAnimation = 'assets/animations/error_animation.json';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  
  // Timeouts
  static const Duration authTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 10);
}