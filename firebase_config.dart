// Configuration Firebase pour KHIDMETI
// Ce fichier contient la configuration partagée entre les deux applications

class FirebaseConfig {
  // Configuration Firebase
  static const String projectId = 'khidmeti-app';
  static const String apiKey = 'YOUR_API_KEY';
  static const String appId = 'YOUR_APP_ID';
  static const String messagingSenderId = 'YOUR_SENDER_ID';
  static const String storageBucket = 'khidmeti-app.appspot.com';
  
  // Collections Firestore
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
  
  // Storage buckets
  static const String profileImagesBucket = 'profile_images';
  static const String identityDocumentsBucket = 'identity_documents';
  static const String jobMediaBucket = 'job_media';
  static const String paymentReceiptsBucket = 'payment_receipts';
  
  // Configuration des services
  static const List<String> availableServices = [
    'Plomberie',
    'Électricité',
    'Nettoyage',
    'Livraison',
    'Peinture',
    'Réparation électroménager',
    'Maçonnerie',
    'Climatisation',
    'Baby-sitting',
    'Cours particuliers',
  ];
  
  // Configuration des abonnements
  static const int freeTrialMonths = 6;
  static const double monthlySubscriptionPrice = 1000.0; // DZD
  static const double yearlySubscriptionPrice = 10000.0; // DZD
  
  // Configuration des distances
  static const double defaultMaxDistance = 50.0; // km
  static const double nearbyWorkerDistance = 10.0; // km
  
  // Configuration des notifications
  static const int maxNotificationAge = 30; // jours
  static const int notificationCleanupInterval = 7; // jours
  
  // Configuration de la géolocalisation
  static const double defaultLatitude = 36.7538; // Alger
  static const double defaultLongitude = 3.0588;
  static const double locationUpdateInterval = 300.0; // secondes
  
  // Configuration des langues
  static const List<String> supportedLanguages = ['fr', 'en', 'ar'];
  static const String defaultLanguage = 'fr';
  
  // Configuration des paiements
  static const List<String> supportedPaymentMethods = [
    'barid_mob',
    'carte_bancaire',
    'paiement_poste'
  ];
  
  // Configuration des documents d'identité
  static const List<String> supportedIdentityTypes = [
    'carte_nationale',
    'permis_conduire',
    'passeport'
  ];
  
  // Configuration des scores initiaux
  static const double baseInitialScore = 5.0;
  static const double certificationBonus = 2.0;
  static const double experienceBonus = 0.5; // par année
  
  // Configuration des timeouts
  static const int jobAcceptanceTimeout = 300; // secondes
  static const int workerResponseTimeout = 600; // secondes
  static const int paymentConfirmationTimeout = 1800; // secondes
  
  // Configuration des limites
  static const int maxImagesPerJob = 10;
  static const int maxVideosPerJob = 5;
  static const int maxFileSizeMB = 50;
  static const int maxJobsPerUser = 5;
  static const int maxActiveJobsPerWorker = 3;
  
  // Configuration des métadonnées
  static const Map<String, dynamic> defaultMetadata = {
    'app_version': '1.0.0',
    'platform': 'flutter',
    'created_by': 'khidmeti_system',
  };
  
  // Méthodes utilitaires
  static String getCollectionPath(String collection) {
    return 'projects/$projectId/databases/(default)/documents/$collection';
  }
  
  static String getStoragePath(String bucket, String path) {
    return 'gs://$bucket/$path';
  }
  
  static bool isValidService(String service) {
    return availableServices.contains(service);
  }
  
  static bool isValidLanguage(String language) {
    return supportedLanguages.contains(language);
  }
  
  static bool isValidIdentityType(String type) {
    return supportedIdentityTypes.contains(type);
  }
  
  static bool isValidPaymentMethod(String method) {
    return supportedPaymentMethods.contains(method);
  }
  
  static double calculateInitialScore(int experienceYears, List<String> certifications) {
    double score = baseInitialScore;
    score += experienceYears * experienceBonus;
    score += certifications.length * certificationBonus;
    return score.clamp(0.0, 10.0);
  }
  
  static bool isWithinDistance(double distance, double maxDistance) {
    return distance <= maxDistance;
  }
  
  static String formatCurrency(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'DZD':
        return '${amount.toStringAsFixed(0)} DZD';
      case 'EUR':
        return '${amount.toStringAsFixed(2)} €';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }
  
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceKm.toStringAsFixed(0)} km';
    }
  }
  
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}j ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}min';
    } else {
      return '${duration.inSeconds}s';
    }
  }
  
  // Configuration des règles de sécurité Firestore
  static const Map<String, dynamic> securityRules = {
    'users': {
      'read': 'request.auth != null && (request.auth.uid == resource.data.userId || request.auth.token.role == "admin")',
      'write': 'request.auth != null && request.auth.uid == resource.data.userId',
      'create': 'request.auth != null && request.auth.uid == request.resource.data.userId',
    },
    'workers': {
      'read': 'request.auth != null',
      'write': 'request.auth != null && request.auth.uid == resource.data.id',
      'create': 'request.auth != null && request.auth.uid == request.resource.data.id',
    },
    'jobs': {
      'read': 'request.auth != null',
      'write': 'request.auth != null && request.auth.uid == resource.data.userId',
      'create': 'request.auth != null && request.auth.uid == request.resource.data.userId',
    },
    'job_requests': {
      'read': 'request.auth != null',
      'write': 'request.auth != null && (request.auth.uid == resource.data.userId || request.auth.token.role == "worker")',
      'create': 'request.auth != null && request.auth.uid == request.resource.data.userId',
    },
  };
  
  // Configuration des règles de sécurité Storage
  static const Map<String, dynamic> storageRules = {
    'profile_images': {
      'read': 'request.auth != null',
      'write': 'request.auth != null && request.auth.uid == request.resource.metadata.userId',
    },
    'identity_documents': {
      'read': 'request.auth != null && (request.auth.uid == request.resource.metadata.userId || request.auth.token.role == "admin")',
      'write': 'request.auth != null && request.auth.uid == request.resource.metadata.userId',
    },
    'job_media': {
      'read': 'request.auth != null',
      'write': 'request.auth != null && request.auth.uid == request.resource.metadata.userId',
    },
  };
}