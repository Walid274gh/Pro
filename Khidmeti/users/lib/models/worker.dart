import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de données pour un travailleur de l'application KHIDMETI Users
/// Cette classe respecte le principe de responsabilité unique (SRP) du SOLID
class Worker {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final String? identityCardUrl;
  final String? professionalCertificateUrl;
  final List<String> services;
  final String location;
  final double latitude;
  final double longitude;
  final bool isOnline;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime lastActive;
  final DateTime subscriptionExpiry;
  final String subscriptionType; // 'free', 'monthly', 'yearly'
  final double rating;
  final int totalReviews;
  final List<Review> reviews;
  final Map<String, dynamic> certificates;
  final bool isVerified;
  final String language;
  final int experienceYears;
  final double hourlyRate;
  final String? bio;
  final List<String> completedJobs;
  final List<String> activeJobs;

  const Worker({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    this.identityCardUrl,
    this.professionalCertificateUrl,
    required this.services,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.isOnline = false,
    this.isAvailable = true,
    required this.createdAt,
    required this.lastActive,
    required this.subscriptionExpiry,
    required this.subscriptionType,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.reviews = const [],
    this.certificates = const {},
    this.isVerified = false,
    this.language = 'fr',
    this.experienceYears = 0,
    this.hourlyRate = 0.0,
    this.bio,
    this.completedJobs = const [],
    this.activeJobs = const [],
  });

  /// Création d'un travailleur à partir des données Firestore
  factory Worker.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Worker(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      identityCardUrl: data['identityCardUrl'],
      professionalCertificateUrl: data['professionalCertificateUrl'],
      services: List<String>.from(data['services'] ?? []),
      location: data['location'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      isOnline: data['isOnline'] ?? false,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      subscriptionExpiry: (data['subscriptionExpiry'] as Timestamp).toDate(),
      subscriptionType: data['subscriptionType'] ?? 'free',
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      reviews: (data['reviews'] as List<dynamic>? ?? [])
          .map((review) => Review.fromMap(review))
          .toList(),
      certificates: Map<String, dynamic>.from(data['certificates'] ?? {}),
      isVerified: data['isVerified'] ?? false,
      language: data['language'] ?? 'fr',
      experienceYears: data['experienceYears'] ?? 0,
      hourlyRate: (data['hourlyRate'] ?? 0.0).toDouble(),
      bio: data['bio'],
      completedJobs: List<String>.from(data['completedJobs'] ?? []),
      activeJobs: List<String>.from(data['activeJobs'] ?? []),
    );
  }

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'identityCardUrl': identityCardUrl,
      'professionalCertificateUrl': professionalCertificateUrl,
      'services': services,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'isOnline': isOnline,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'subscriptionExpiry': Timestamp.fromDate(subscriptionExpiry),
      'subscriptionType': subscriptionType,
      'rating': rating,
      'totalReviews': totalReviews,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'certificates': certificates,
      'isVerified': isVerified,
      'language': language,
      'experienceYears': experienceYears,
      'hourlyRate': hourlyRate,
      'bio': bio,
      'completedJobs': completedJobs,
      'activeJobs': activeJobs,
    };
  }

  /// Création d'une copie avec modifications
  Worker copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? identityCardUrl,
    String? professionalCertificateUrl,
    List<String>? services,
    String? location,
    double? latitude,
    double? longitude,
    bool? isOnline,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? lastActive,
    DateTime? subscriptionExpiry,
    String? subscriptionType,
    double? rating,
    int? totalReviews,
    List<Review>? reviews,
    Map<String, dynamic>? certificates,
    bool? isVerified,
    String? language,
    int? experienceYears,
    double? hourlyRate,
    String? bio,
    List<String>? completedJobs,
    List<String>? activeJobs,
  }) {
    return Worker(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      identityCardUrl: identityCardUrl ?? this.identityCardUrl,
      professionalCertificateUrl: professionalCertificateUrl ?? this.professionalCertificateUrl,
      services: services ?? this.services,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOnline: isOnline ?? this.isOnline,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      reviews: reviews ?? this.reviews,
      certificates: certificates ?? this.certificates,
      isVerified: isVerified ?? this.isVerified,
      language: language ?? this.language,
      experienceYears: experienceYears ?? this.experienceYears,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      bio: bio ?? this.bio,
      completedJobs: completedJobs ?? this.completedJobs,
      activeJobs: activeJobs ?? this.activeJobs,
    );
  }

  /// Nom complet du travailleur
  String get fullName => '$firstName $lastName';

  /// Initiales du travailleur
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();

  /// Vérification si l'abonnement est actif
  bool get isSubscriptionActive => DateTime.now().isBefore(subscriptionExpiry);

  /// Vérification si le travailleur peut accepter de nouveaux travaux
  bool get canAcceptJobs => isOnline && isAvailable && isSubscriptionActive;

  /// Vérification si le travailleur a des certificats
  bool get hasCertificates => certificates.isNotEmpty;

  /// Vérification si le travailleur a des avis
  bool get hasReviews => reviews.isNotEmpty;

  /// Vérification si le travailleur est expérimenté (>5 ans)
  bool get isExperienced => experienceYears >= 5;

  /// Statut de disponibilité formaté
  String get availabilityStatus {
    if (!isSubscriptionActive) return 'Abonnement expiré';
    if (!isOnline) return 'Hors ligne';
    if (!isAvailable) return 'Occupé';
    return 'Disponible';
  }

  /// Services formatés pour l'affichage
  String get servicesDisplay => services.join(', ');

  @override
  String toString() {
    return 'Worker(id: $id, firstName: $firstName, lastName: $lastName, services: $services)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Worker && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Classe pour représenter les avis des utilisateurs
class Review {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String jobId;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.jobId,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      jobId: map['jobId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'jobId': jobId,
    };
  }

  @override
  String toString() {
    return 'Review(rating: $rating, comment: $comment)';
  }
}