import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Worker {
  final String id;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? identityCardUrl;
  final String? identityCardBackUrl;
  final String? professionalCertificateUrl;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isOnline;
  final bool isVerified;
  final bool isSubscribed;
  final DateTime? subscriptionExpiry;
  final List<String> services;
  final LatLng? currentLocation;
  final String? currentAddress;
  final double rating;
  final int totalReviews;
  final List<Review> reviews;
  final Map<String, dynamic> availability;
  final double hourlyRate;
  final String currency;
  final String language;
  final String? fcmToken;
  final int experienceYears;
  final double initialScore;
  final bool isBlocked;
  final String? blockReason;

  Worker({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    this.identityCardUrl,
    this.identityCardBackUrl,
    this.professionalCertificateUrl,
    required this.createdAt,
    required this.lastActive,
    this.isOnline = false,
    this.isVerified = false,
    this.isSubscribed = false,
    this.subscriptionExpiry,
    this.services = const [],
    this.currentLocation,
    this.currentAddress,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.reviews = const [],
    this.availability = const {},
    this.hourlyRate = 0.0,
    this.currency = 'DZD',
    this.language = 'fr',
    this.fcmToken,
    this.experienceYears = 0,
    this.initialScore = 0.0,
    this.isBlocked = false,
    this.blockReason,
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
      profileImageUrl: data['profileImageUrl'],
      identityCardUrl: data['identityCardUrl'],
      identityCardBackUrl: data['identityCardBackUrl'],
      professionalCertificateUrl: data['professionalCertificateUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      isOnline: data['isOnline'] ?? false,
      isVerified: data['isVerified'] ?? false,
      isSubscribed: data['isSubscribed'] ?? false,
      subscriptionExpiry: data['subscriptionExpiry'] != null 
          ? (data['subscriptionExpiry'] as Timestamp).toDate() 
          : null,
      services: List<String>.from(data['services'] ?? []),
      currentLocation: location,
      currentAddress: data['currentAddress'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      reviews: (data['reviews'] as List<dynamic>? ?? [])
          .map((review) => Review.fromMap(review))
          .toList(),
      availability: Map<String, dynamic>.from(data['availability'] ?? {}),
      hourlyRate: (data['hourlyRate'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'DZD',
      language: data['language'] ?? 'fr',
      fcmToken: data['fcmToken'],
      experienceYears: data['experienceYears'] ?? 0,
      initialScore: (data['initialScore'] ?? 0.0).toDouble(),
      isBlocked: data['isBlocked'] ?? false,
      blockReason: data['blockReason'],
    );
  }

  // Méthode pour convertir Worker en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'identityCardUrl': identityCardUrl,
      'identityCardBackUrl': identityCardBackUrl,
      'professionalCertificateUrl': professionalCertificateUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'isOnline': isOnline,
      'isVerified': isVerified,
      'isSubscribed': isSubscribed,
      'services': services,
      'currentAddress': currentAddress,
      'rating': rating,
      'totalReviews': totalReviews,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'availability': availability,
      'hourlyRate': hourlyRate,
      'currency': currency,
      'language': language,
      'fcmToken': fcmToken,
      'experienceYears': experienceYears,
      'initialScore': initialScore,
      'isBlocked': isBlocked,
      'blockReason': blockReason,
    };

    if (currentLocation != null) {
      data['currentLocation'] = GeoPoint(
        currentLocation!.latitude,
        currentLocation!.longitude,
      );
    }

    if (subscriptionExpiry != null) {
      data['subscriptionExpiry'] = Timestamp.fromDate(subscriptionExpiry!);
    }

    return data;
  }

  // Méthode pour créer une copie modifiée
  Worker copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    String? identityCardUrl,
    String? identityCardBackUrl,
    String? professionalCertificateUrl,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isOnline,
    bool? isVerified,
    bool? isSubscribed,
    DateTime? subscriptionExpiry,
    List<String>? services,
    LatLng? currentLocation,
    String? currentAddress,
    double? rating,
    int? totalReviews,
    List<Review>? reviews,
    Map<String, dynamic>? availability,
    double? hourlyRate,
    String? currency,
    String? language,
    String? fcmToken,
    int? experienceYears,
    double? initialScore,
    bool? isBlocked,
    String? blockReason,
  }) {
    return Worker(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      identityCardUrl: identityCardUrl ?? this.identityCardUrl,
      identityCardBackUrl: identityCardBackUrl ?? this.identityCardBackUrl,
      professionalCertificateUrl: professionalCertificateUrl ?? this.professionalCertificateUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      services: services ?? this.services,
      currentLocation: currentLocation ?? this.currentLocation,
      currentAddress: currentAddress ?? this.currentAddress,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      reviews: reviews ?? this.reviews,
      availability: availability ?? this.availability,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      fcmToken: fcmToken ?? this.fcmToken,
      experienceYears: experienceYears ?? this.experienceYears,
      initialScore: initialScore ?? this.initialScore,
      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
    );
  }

  // Getters utiles
  String get fullName => '$firstName $lastName';
  
  bool get hasCompleteProfile => 
      firstName.isNotEmpty && 
      lastName.isNotEmpty && 
      identityCardUrl != null &&
      identityCardBackUrl != null;

  bool get isSubscriptionActive => 
      isSubscribed && 
      subscriptionExpiry != null && 
      subscriptionExpiry!.isAfter(DateTime.now());

  bool get isAvailable => isOnline && isVerified && !isBlocked && isSubscriptionActive;

  double get finalScore => (initialScore + rating) / 2;

  // Méthodes de gestion du statut
  Worker updateOnlineStatus(bool online) {
    return copyWith(
      isOnline: online,
      lastActive: DateTime.now(),
    );
  }

  Worker updateLocation(LatLng location, String address) {
    return copyWith(
      currentLocation: location,
      currentAddress: address,
      lastActive: DateTime.now(),
    );
  }

  Worker addReview(Review review) {
    double newRating = ((rating * totalReviews) + review.rating) / (totalReviews + 1);
    return copyWith(
      reviews: [...reviews, review],
      rating: newRating,
      totalReviews: totalReviews + 1,
    );
  }

  Worker addService(String service) {
    if (!services.contains(service)) {
      return copyWith(services: [...services, service]);
    }
    return this;
  }

  Worker removeService(String service) {
    return copyWith(
      services: services.where((s) => s != service).toList(),
    );
  }

  Worker updateSubscription(bool subscribed, DateTime? expiry) {
    return copyWith(
      isSubscribed: subscribed,
      subscriptionExpiry: expiry,
    );
  }

  Worker updateVerificationStatus(bool verified) {
    return copyWith(isVerified: verified);
  }

  Worker updateFcmToken(String? token) {
    return copyWith(fcmToken: token);
  }

  Worker updateLastActive() {
    return copyWith(lastActive: DateTime.now());
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

  @override
  String toString() {
    return 'Worker(id: $id, name: $fullName, isOnline: $isOnline, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Worker && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Classe Review pour les évaluations
class Review {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? userImageUrl;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userImageUrl,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      userImageUrl: map['userImageUrl'],
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
      'userImageUrl': userImageUrl,
    };
  }

  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? userImageUrl,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      userImageUrl: userImageUrl ?? this.userImageUrl,
    );
  }
}