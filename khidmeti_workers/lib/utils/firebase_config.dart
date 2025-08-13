class FirebaseConfig {
  static const String usersCollection = 'users';
  static const String workersCollection = 'workers';
  static const String jobsCollection = 'jobs';
  static const String jobRequestsCollection = 'job_requests';
  static const String serviceCategoriesCollection = 'service_categories';
  static const String notificationsCollection = 'notifications';
  static const String messagesCollection = 'messages';
  static const String chatsCollection = 'chats';
  static const String paymentsCollection = 'payments';
  static const String subscriptionsCollection = 'subscriptions';
  static const String reviewsCollection = 'reviews';

  static const String profileImagesBucket = 'profile_images';
  static const String identityDocumentsBucket = 'identity_documents';
  static const String jobMediaBucket = 'job_media';
  static const String paymentReceiptsBucket = 'payment_receipts';

  static const int freeTrialMonths = 6;
  static const double monthlySubscriptionPrice = 1000.0; // DZD
  static const double yearlySubscriptionPrice = 10000.0; // DZD
  static const double defaultMaxDistance = 50.0; // km

  static const List<String> supportedLanguages = ['fr', 'en', 'ar'];
  static const String defaultLanguage = 'fr';

  static const List<String> supportedIdentityTypes = [
    'carte_nationale',
    'permis_conduire',
    'passeport',
  ];
}