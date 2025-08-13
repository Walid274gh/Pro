import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

enum WorkerStatus {
  pending,      // En attente de vérification
  verified,     // Vérifié et approuvé
  rejected,     // Rejeté
  suspended,    // Suspendu
  blocked       // Bloqué
}

enum SubscriptionStatus {
  free,         // Période gratuite (6 mois)
  active,       // Abonnement actif
  expired,      // Abonnement expiré
  cancelled     // Abonnement annulé
}

class Worker {
  final String id;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? email;
  final String? profileImageUrl;
  
  // Documents d'identité
  final String? identityCardUrl;
  final String? identityCardBackUrl;
  final String? identityCardType; // 'carte_nationale', 'permis', 'passeport'
  final String? identityCardNumber;
  final DateTime? identityCardExpiry;
  
  // Vérification
  final WorkerStatus status;
  final bool isIdentityVerified;
  final bool isFaceVerified;
  final String? verificationNotes;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  
  // Abonnement
  final SubscriptionStatus subscriptionStatus;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final String? subscriptionPlan; // 'monthly', 'yearly'
  final double subscriptionAmount;
  final String? lastPaymentReceiptUrl;
  final DateTime? lastPaymentDate;
  
  // Services et compétences
  final List<String> services;
  final List<String> certifications;
  final int experienceYears;
  final double hourlyRate;
  final String currency;
  final Map<String, dynamic> skills;
  
  // Localisation et disponibilité
  final LatLng? currentLocation;
  final String? currentAddress;
  final bool isOnline;
  final DateTime lastActive;
  final Map<String, dynamic> availability;
  final double maxDistance; // Distance maximale de travail en km
  
  // Évaluations et réputation
  final double rating;
  final int totalReviews;
  final List<WorkerReview> reviews;
  final double initialScore;
  final int completedJobs;
  final int cancelledJobs;
  
  // Communication
  final String? fcmToken;
  final String language;
  final bool notificationsEnabled;
  
  // Métadonnées
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  Worker({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.email,
    this.profileImageUrl,
    this.identityCardUrl,
    this.identityCardBackUrl,
    this.identityCardType,
    this.identityCardNumber,
    this.identityCardExpiry,
    this.status = WorkerStatus.pending,
    this.isIdentityVerified = false,
    this.isFaceVerified = false,
    this.verificationNotes,
    this.verifiedAt,
    this.verifiedBy,
    this.subscriptionStatus = SubscriptionStatus.free,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.subscriptionPlan,
    this.subscriptionAmount = 0.0,
    this.lastPaymentReceiptUrl,
    this.lastPaymentDate,
    this.services = const [],
    this.certifications = const [],
    this.experienceYears = 0,
    this.hourlyRate = 0.0,
    this.currency = 'DZD',
    this.skills = const {},
    this.currentLocation,
    this.currentAddress,
    this.isOnline = false,
    required this.lastActive,
    this.availability = const {},
    this.maxDistance = 50.0,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.reviews = const [],
    this.initialScore = 0.0,
    this.completedJobs = 0,
    this.cancelledJobs = 0,
    this.fcmToken,
    this.language = 'fr',
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  // Factory constructor pour créer un Worker depuis Firestore
  factory Worker.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    LatLng? location;
    if (data['currentLocation'] != null) {
      GeoPoint geoPoint = data['currentLocation'] as GeoPoint;
      location = LatLng(geoPoint.latitude, geoPoint.longitude);
    }

    return Worker(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      profileImageUrl: data['profileImageUrl'],
      identityCardUrl: data['identityCardUrl'],
      identityCardBackUrl: data['identityCardBackUrl'],
      identityCardType: data['identityCardType'],
      identityCardNumber: data['identityCardNumber'],
      identityCardExpiry: data['identityCardExpiry'] != null 
          ? (data['identityCardExpiry'] as Timestamp).toDate() 
          : null,
      status: WorkerStatus.values.firstWhere(
        (e) => e.toString() == 'WorkerStatus.${data['status']}',
        orElse: () => WorkerStatus.pending,
      ),
      isIdentityVerified: data['isIdentityVerified'] ?? false,
      isFaceVerified: data['isFaceVerified'] ?? false,
      verificationNotes: data['verificationNotes'],
      verifiedAt: data['verifiedAt'] != null 
          ? (data['verifiedAt'] as Timestamp).toDate() 
          : null,
      verifiedBy: data['verifiedBy'],
      subscriptionStatus: SubscriptionStatus.values.firstWhere(
        (e) => e.toString() == 'SubscriptionStatus.${data['subscriptionStatus']}',
        orElse: () => SubscriptionStatus.free,
      ),
      subscriptionStartDate: data['subscriptionStartDate'] != null 
          ? (data['subscriptionStartDate'] as Timestamp).toDate() 
          : null,
      subscriptionEndDate: data['subscriptionEndDate'] != null 
          ? (data['subscriptionEndDate'] as Timestamp).toDate() 
          : null,
      subscriptionPlan: data['subscriptionPlan'],
      subscriptionAmount: (data['subscriptionAmount'] ?? 0.0).toDouble(),
      lastPaymentReceiptUrl: data['lastPaymentReceiptUrl'],
      lastPaymentDate: data['lastPaymentDate'] != null 
          ? (data['lastPaymentDate'] as Timestamp).toDate() 
          : null,
      services: List<String>.from(data['services'] ?? []),
      certifications: List<String>.from(data['certifications'] ?? []),
      experienceYears: data['experienceYears'] ?? 0,
      hourlyRate: (data['hourlyRate'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'DZD',
      skills: Map<String, dynamic>.from(data['skills'] ?? {}),
      currentLocation: location,
      currentAddress: data['currentAddress'],
      isOnline: data['isOnline'] ?? false,
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      availability: Map<String, dynamic>.from(data['availability'] ?? {}),
      maxDistance: (data['maxDistance'] ?? 50.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      reviews: (data['reviews'] as List<dynamic>? ?? [])
          .map((review) => WorkerReview.fromMap(review))
          .toList(),
      initialScore: (data['initialScore'] ?? 0.0).toDouble(),
      completedJobs: data['completedJobs'] ?? 0,
      cancelledJobs: data['cancelledJobs'] ?? 0,
      fcmToken: data['fcmToken'],
      language: data['language'] ?? 'fr',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  // Méthode pour convertir Worker en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'identityCardUrl': identityCardUrl,
      'identityCardBackUrl': identityCardBackUrl,
      'identityCardType': identityCardType,
      'identityCardNumber': identityCardNumber,
      'status': status.toString().split('.').last,
      'isIdentityVerified': isIdentityVerified,
      'isFaceVerified': isFaceVerified,
      'verificationNotes': verificationNotes,
      'verifiedBy': verifiedBy,
      'subscriptionStatus': subscriptionStatus.toString().split('.').last,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionAmount': subscriptionAmount,
      'lastPaymentReceiptUrl': lastPaymentReceiptUrl,
      'services': services,
      'certifications': certifications,
      'experienceYears': experienceYears,
      'hourlyRate': hourlyRate,
      'currency': currency,
      'skills': skills,
      'currentAddress': currentAddress,
      'isOnline': isOnline,
      'lastActive': Timestamp.fromDate(lastActive),
      'availability': availability,
      'maxDistance': maxDistance,
      'rating': rating,
      'totalReviews': totalReviews,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'initialScore': initialScore,
      'completedJobs': completedJobs,
      'cancelledJobs': cancelledJobs,
      'fcmToken': fcmToken,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };

    if (currentLocation != null) {
      data['currentLocation'] = GeoPoint(
        currentLocation!.latitude,
        currentLocation!.longitude,
      );
    }

    if (identityCardExpiry != null) {
      data['identityCardExpiry'] = Timestamp.fromDate(identityCardExpiry!);
    }

    if (verifiedAt != null) {
      data['verifiedAt'] = Timestamp.fromDate(verifiedAt!);
    }

    if (subscriptionStartDate != null) {
      data['subscriptionStartDate'] = Timestamp.fromDate(subscriptionStartDate!);
    }

    if (subscriptionEndDate != null) {
      data['subscriptionEndDate'] = Timestamp.fromDate(subscriptionEndDate!);
    }

    if (lastPaymentDate != null) {
      data['lastPaymentDate'] = Timestamp.fromDate(lastPaymentDate!);
    }

    return data;
  }

  // Méthode pour créer une copie modifiée
  Worker copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? profileImageUrl,
    String? identityCardUrl,
    String? identityCardBackUrl,
    String? identityCardType,
    String? identityCardNumber,
    DateTime? identityCardExpiry,
    WorkerStatus? status,
    bool? isIdentityVerified,
    bool? isFaceVerified,
    String? verificationNotes,
    DateTime? verifiedAt,
    String? verifiedBy,
    SubscriptionStatus? subscriptionStatus,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    String? subscriptionPlan,
    double? subscriptionAmount,
    String? lastPaymentReceiptUrl,
    DateTime? lastPaymentDate,
    List<String>? services,
    List<String>? certifications,
    int? experienceYears,
    double? hourlyRate,
    String? currency,
    Map<String, dynamic>? skills,
    LatLng? currentLocation,
    String? currentAddress,
    bool? isOnline,
    DateTime? lastActive,
    Map<String, dynamic>? availability,
    double? maxDistance,
    double? rating,
    int? totalReviews,
    List<WorkerReview>? reviews,
    double? initialScore,
    int? completedJobs,
    int? cancelledJobs,
    String? fcmToken,
    String? language,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Worker(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      identityCardUrl: identityCardUrl ?? this.identityCardUrl,
      identityCardBackUrl: identityCardBackUrl ?? this.identityCardBackUrl,
      identityCardType: identityCardType ?? this.identityCardType,
      identityCardNumber: identityCardNumber ?? this.identityCardNumber,
      identityCardExpiry: identityCardExpiry ?? this.identityCardExpiry,
      status: status ?? this.status,
      isIdentityVerified: isIdentityVerified ?? this.isIdentityVerified,
      isFaceVerified: isFaceVerified ?? this.isFaceVerified,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionAmount: subscriptionAmount ?? this.subscriptionAmount,
      lastPaymentReceiptUrl: lastPaymentReceiptUrl ?? this.lastPaymentReceiptUrl,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      services: services ?? this.services,
      certifications: certifications ?? this.certifications,
      experienceYears: experienceYears ?? this.experienceYears,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      currency: currency ?? this.currency,
      skills: skills ?? this.skills,
      currentLocation: currentLocation ?? this.currentLocation,
      currentAddress: currentAddress ?? this.currentAddress,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      availability: availability ?? this.availability,
      maxDistance: maxDistance ?? this.maxDistance,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      reviews: reviews ?? this.reviews,
      initialScore: initialScore ?? this.initialScore,
      completedJobs: completedJobs ?? this.completedJobs,
      cancelledJobs: cancelledJobs ?? this.cancelledJobs,
      fcmToken: fcmToken ?? this.fcmToken,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Getters utiles
  String get fullName => '$firstName $lastName';
  
  bool get hasCompleteProfile => 
      firstName.isNotEmpty && 
      lastName.isNotEmpty && 
      identityCardUrl != null &&
      identityCardBackUrl != null;
  
  bool get isVerified => status == WorkerStatus.verified;
  
  bool get isActive => isVerified && isOnline;
  
  bool get hasActiveSubscription => 
      subscriptionStatus == SubscriptionStatus.active ||
      (subscriptionStatus == SubscriptionStatus.free && 
       subscriptionEndDate != null && 
       subscriptionEndDate!.isAfter(DateTime.now()));
  
  bool get isSubscriptionExpired => 
      subscriptionEndDate != null && 
      subscriptionEndDate!.isBefore(DateTime.now());
  
  double get finalScore => (initialScore + rating) / 2;
  
  bool get canWork => isVerified && hasActiveSubscription && !isOnline;
  
  int get totalJobs => completedJobs + cancelledJobs;
  
  double get successRate => totalJobs > 0 ? (completedJobs / totalJobs) * 100 : 0.0;

  // Méthodes de gestion du statut
  Worker updateOnlineStatus(bool online) {
    return copyWith(
      isOnline: online,
      lastActive: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Worker updateLocation(LatLng location, String address) {
    return copyWith(
      currentLocation: location,
      currentAddress: address,
      lastActive: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Worker updateVerificationStatus(WorkerStatus newStatus, String? notes, String? verifiedBy) {
    return copyWith(
      status: newStatus,
      verificationNotes: notes,
      verifiedBy: verifiedBy,
      verifiedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Worker updateSubscription(SubscriptionStatus newStatus, DateTime? startDate, DateTime? endDate, String? plan, double amount) {
    return copyWith(
      subscriptionStatus: newStatus,
      subscriptionStartDate: startDate,
      subscriptionEndDate: endDate,
      subscriptionPlan: plan,
      subscriptionAmount: amount,
      updatedAt: DateTime.now(),
    );
  }

  Worker addService(String service) {
    if (!services.contains(service)) {
      return copyWith(
        services: [...services, service],
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }

  Worker removeService(String service) {
    return copyWith(
      services: services.where((s) => s != service).toList(),
      updatedAt: DateTime.now(),
    );
  }

  Worker addCertification(String certification) {
    if (!certifications.contains(certification)) {
      return copyWith(
        certifications: [...certifications, certification],
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }

  Worker updateSkills(Map<String, dynamic> newSkills) {
    return copyWith(
      skills: newSkills,
      updatedAt: DateTime.now(),
    );
  }

  Worker addReview(WorkerReview review) {
    double newRating = ((rating * totalReviews) + review.rating) / (totalReviews + 1);
    return copyWith(
      reviews: [...reviews, review],
      rating: newRating,
      totalReviews: totalReviews + 1,
      updatedAt: DateTime.now(),
    );
  }

  Worker completeJob() {
    return copyWith(
      completedJobs: completedJobs + 1,
      updatedAt: DateTime.now(),
    );
  }

  Worker cancelJob() {
    return copyWith(
      cancelledJobs: cancelledJobs + 1,
      updatedAt: DateTime.now(),
    );
  }

  Worker updateFcmToken(String? token) {
    return copyWith(
      fcmToken: token,
      updatedAt: DateTime.now(),
    );
  }

  Worker updateLanguage(String newLanguage) {
    return copyWith(
      language: newLanguage,
      updatedAt: DateTime.now(),
    );
  }

  // Méthode pour calculer la distance avec un autre point
  double? calculateDistance(LatLng otherLocation) {
    if (currentLocation == null) return null;
    
    const double earthRadius = 6371; // km
    double lat1 = currentLocation!.latitude * (pi / 180);
    double lat2 = otherLocation.latitude * (pi / 180);
    double deltaLat = (otherLocation.latitude - currentLocation!.latitude) * (pi / 180);
    double deltaLon = (otherLocation.longitude - currentLocation!.longitude) * (pi / 180);

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Méthode pour vérifier si le travailleur peut accepter un job à une distance donnée
  bool canAcceptJobAtDistance(LatLng jobLocation) {
    if (currentLocation == null) return false;
    
    double? distance = calculateDistance(jobLocation);
    return distance != null && distance <= maxDistance;
  }

  @override
  String toString() {
    return 'Worker(id: $id, name: $fullName, status: $status, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Worker && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Classe WorkerReview pour les évaluations des travailleurs
class WorkerReview {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? jobId;
  final String? jobTitle;

  WorkerReview({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.jobId,
    this.jobTitle,
  });

  factory WorkerReview.fromMap(Map<String, dynamic> map) {
    return WorkerReview(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImageUrl: map['userImageUrl'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      jobId: map['jobId'],
      jobTitle: map['jobTitle'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'jobId': jobId,
      'jobTitle': jobTitle,
    };
  }

  WorkerReview copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImageUrl,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? jobId,
    String? jobTitle,
  }) {
    return WorkerReview(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
    );
  }
}