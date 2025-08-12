import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final List<String> skills;
  final double rating;
  final int completedJobs;
  final double hourlyRate;
  final bool isAvailable;
  final GeoPoint location;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.skills,
    required this.rating,
    required this.completedJobs,
    required this.hourlyRate,
    required this.isAvailable,
    required this.location,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'skills': skills,
      'rating': rating,
      'completedJobs': completedJobs,
      'hourlyRate': hourlyRate,
      'isAvailable': isAvailable,
      'location': location,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    return WorkerModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      completedJobs: map['completedJobs'] ?? 0,
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      isAvailable: map['isAvailable'] ?? false,
      location: map['location'] ?? const GeoPoint(0, 0),
      address: map['address'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  WorkerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    List<String>? skills,
    double? rating,
    int? completedJobs,
    double? hourlyRate,
    bool? isAvailable,
    GeoPoint? location,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      skills: skills ?? this.skills,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isAvailable: isAvailable ?? this.isAvailable,
      location: location ?? this.location,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkerModel(id: $id, name: $name, email: $email, phone: $phone, avatarUrl: $avatarUrl, skills: $skills, rating: $rating, completedJobs: $completedJobs, hourlyRate: $hourlyRate, isAvailable: $isAvailable, location: $location, address: $address, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkerModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.avatarUrl == avatarUrl &&
        other.skills == skills &&
        other.rating == rating &&
        other.completedJobs == completedJobs &&
        other.hourlyRate == hourlyRate &&
        other.isAvailable == isAvailable &&
        other.location == location &&
        other.address == address &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        avatarUrl.hashCode ^
        skills.hashCode ^
        rating.hashCode ^
        completedJobs.hashCode ^
        hourlyRate.hashCode ^
        isAvailable.hashCode ^
        location.hashCode ^
        address.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}