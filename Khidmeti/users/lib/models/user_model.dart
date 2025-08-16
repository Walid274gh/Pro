import 'base_model.dart';

// Modèle utilisateur respectant le principe SRP
class UserModel extends BaseModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final Map<String, dynamic> preferences;
  final GeoPoint? lastKnownLocation;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.preferences = const {},
    this.lastKnownLocation,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
      'preferences': preferences,
      'lastKnownLocation': lastKnownLocation != null 
          ? {'latitude': lastKnownLocation!.latitude, 'longitude': lastKnownLocation!.longitude}
          : null,
    };
  }

  @override
  bool isValid() {
    return id.isNotEmpty && 
           email.isNotEmpty && 
           firstName.isNotEmpty && 
           lastName.isNotEmpty &&
           email.contains('@');
  }

  // Méthodes de factory pour la création
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'],
      avatarUrl: map['avatarUrl'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      isVerified: map['isVerified'] ?? false,
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      lastKnownLocation: map['lastKnownLocation'] != null 
          ? GeoPoint(map['lastKnownLocation']['latitude'], map['lastKnownLocation']['longitude'])
          : null,
    );
  }

  // Méthode pour créer une copie avec modifications
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    Map<String, dynamic>? preferences,
    GeoPoint? lastKnownLocation,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      preferences: preferences ?? this.preferences,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
    );
  }

  // Getter pour le nom complet
  String get fullName => '$firstName $lastName';
}

// Classe GeoPoint pour la localisation
class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint(this.latitude, this.longitude);

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory GeoPoint.fromMap(Map<String, dynamic> map) {
    return GeoPoint(
      map['latitude'] ?? 0.0,
      map['longitude'] ?? 0.0,
    );
  }
}