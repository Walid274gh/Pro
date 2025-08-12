import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de données pour un utilisateur de l'application KHIDMETI Users
/// Cette classe respecte le principe de responsabilité unique (SRP) du SOLID
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastActive;
  final List<String> favoriteWorkers;
  final List<String> completedJobs;
  final double rating;
  final int totalReviews;
  final Map<String, dynamic> preferences;
  final bool isVerified;
  final String language;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastActive,
    this.favoriteWorkers = const [],
    this.completedJobs = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    this.preferences = const {},
    this.isVerified = false,
    this.language = 'fr',
  });

  /// Création d'un utilisateur à partir des données Firestore
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      favoriteWorkers: List<String>.from(data['favoriteWorkers'] ?? []),
      completedJobs: List<String>.from(data['completedJobs'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      isVerified: data['isVerified'] ?? false,
      language: data['language'] ?? 'fr',
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
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'favoriteWorkers': favoriteWorkers,
      'completedJobs': completedJobs,
      'rating': rating,
      'totalReviews': totalReviews,
      'preferences': preferences,
      'isVerified': isVerified,
      'language': language,
    };
  }

  /// Création d'une copie avec modifications
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastActive,
    List<String>? favoriteWorkers,
    List<String>? completedJobs,
    double? rating,
    int? totalReviews,
    Map<String, dynamic>? preferences,
    bool? isVerified,
    String? language,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      favoriteWorkers: favoriteWorkers ?? this.favoriteWorkers,
      completedJobs: completedJobs ?? this.completedJobs,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      preferences: preferences ?? this.preferences,
      isVerified: isVerified ?? this.isVerified,
      language: language ?? this.language,
    );
  }

  /// Nom complet de l'utilisateur
  String get fullName => '$firstName $lastName';

  /// Initiales de l'utilisateur
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();

  /// Vérification si l'utilisateur a des préférences
  bool get hasPreferences => preferences.isNotEmpty;

  /// Vérification si l'utilisateur a des travailleurs favoris
  bool get hasFavoriteWorkers => favoriteWorkers.isNotEmpty;

  /// Vérification si l'utilisateur a des travaux terminés
  bool get hasCompletedJobs => completedJobs.isNotEmpty;

  /// Vérification si l'utilisateur est actif (dernière activité < 24h)
  bool get isActive {
    final now = DateTime.now();
    final difference = now.difference(lastActive);
    return difference.inHours < 24;
  }

  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}