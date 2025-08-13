import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isOnline;
  final List<String> favoriteWorkers;
  final List<String> completedJobs;
  final double rating;
  final int totalReviews;
  final Map<String, dynamic> preferences;
  final String language;
  final String? fcmToken;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastActive,
    this.isOnline = false,
    this.favoriteWorkers = const [],
    this.completedJobs = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    this.preferences = const {},
    this.language = 'fr',
    this.fcmToken,
  });

  // Factory constructor pour créer un User depuis Firestore
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return User(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      isOnline: data['isOnline'] ?? false,
      favoriteWorkers: List<String>.from(data['favoriteWorkers'] ?? []),
      completedJobs: List<String>.from(data['completedJobs'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      language: data['language'] ?? 'fr',
      fcmToken: data['fcmToken'],
    );
  }

  // Méthode pour convertir User en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'isOnline': isOnline,
      'favoriteWorkers': favoriteWorkers,
      'completedJobs': completedJobs,
      'rating': rating,
      'totalReviews': totalReviews,
      'preferences': preferences,
      'language': language,
      'fcmToken': fcmToken,
    };
  }

  // Méthode pour créer une copie modifiée
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isOnline,
    List<String>? favoriteWorkers,
    List<String>? completedJobs,
    double? rating,
    int? totalReviews,
    Map<String, dynamic>? preferences,
    String? language,
    String? fcmToken,
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
      isOnline: isOnline ?? this.isOnline,
      favoriteWorkers: favoriteWorkers ?? this.favoriteWorkers,
      completedJobs: completedJobs ?? this.completedJobs,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      preferences: preferences ?? this.preferences,
      language: language ?? this.language,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  // Getter pour le nom complet
  String get fullName => '$firstName $lastName';

  // Getter pour vérifier si l'utilisateur a un profil complet
  bool get hasCompleteProfile => 
      firstName.isNotEmpty && 
      lastName.isNotEmpty && 
      email.isNotEmpty;

  // Méthode pour ajouter un travailleur aux favoris
  User addFavoriteWorker(String workerId) {
    if (!favoriteWorkers.contains(workerId)) {
      return copyWith(
        favoriteWorkers: [...favoriteWorkers, workerId],
      );
    }
    return this;
  }

  // Méthode pour retirer un travailleur des favoris
  User removeFavoriteWorker(String workerId) {
    return copyWith(
      favoriteWorkers: favoriteWorkers.where((id) => id != workerId).toList(),
    );
  }

  // Méthode pour ajouter un travail terminé
  User addCompletedJob(String jobId) {
    if (!completedJobs.contains(jobId)) {
      return copyWith(
        completedJobs: [...completedJobs, jobId],
      );
    }
    return this;
  }

  // Méthode pour mettre à jour le statut en ligne
  User updateOnlineStatus(bool online) {
    return copyWith(
      isOnline: online,
      lastActive: DateTime.now(),
    );
  }

  // Méthode pour mettre à jour la langue
  User updateLanguage(String newLanguage) {
    return copyWith(language: newLanguage);
  }

  // Méthode pour mettre à jour le token FCM
  User updateFcmToken(String? token) {
    return copyWith(fcmToken: token);
  }

  // Méthode pour mettre à jour la dernière activité
  User updateLastActive() {
    return copyWith(lastActive: DateTime.now());
  }

  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, email: $email, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}