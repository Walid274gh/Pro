import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double basePrice;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'basePrice': basePrice,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      images: List<String>.from(map['images'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? basePrice,
    List<String>? images,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ServiceModel(id: $id, name: $name, description: $description, category: $category, basePrice: $basePrice, images: $images, rating: $rating, reviewCount: $reviewCount, isAvailable: $isAvailable, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.category == category &&
        other.basePrice == basePrice &&
        other.images == images &&
        other.rating == rating &&
        other.reviewCount == reviewCount &&
        other.isAvailable == isAvailable &&
        other.tags == tags &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        category.hashCode ^
        basePrice.hashCode ^
        images.hashCode ^
        rating.hashCode ^
        reviewCount.hashCode ^
        isAvailable.hashCode ^
        tags.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}