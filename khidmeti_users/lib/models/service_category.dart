import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String nameEn;
  final String nameAr;
  final String description;
  final String descriptionEn;
  final String descriptionAr;
  final String iconPath;
  final String colorHex;
  final List<String> subcategories;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameAr,
    required this.description,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.iconPath,
    required this.colorHex,
    this.subcategories = const [],
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  // Factory constructor pour créer un ServiceCategory depuis Firestore
  factory ServiceCategory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return ServiceCategory(
      id: doc.id,
      name: data['name'] ?? '',
      nameEn: data['nameEn'] ?? '',
      nameAr: data['nameAr'] ?? '',
      description: data['description'] ?? '',
      descriptionEn: data['descriptionEn'] ?? '',
      descriptionAr: data['descriptionAr'] ?? '',
      iconPath: data['iconPath'] ?? '',
      colorHex: data['colorHex'] ?? '#000000',
      subcategories: List<String>.from(data['subcategories'] ?? []),
      isActive: data['isActive'] ?? true,
      sortOrder: data['sortOrder'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  // Méthode pour convertir ServiceCategory en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'description': description,
      'descriptionEn': descriptionEn,
      'descriptionAr': descriptionAr,
      'iconPath': iconPath,
      'colorHex': colorHex,
      'subcategories': subcategories,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  // Méthode pour créer une copie modifiée
  ServiceCategory copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? nameAr,
    String? description,
    String? descriptionEn,
    String? descriptionAr,
    String? iconPath,
    String? colorHex,
    List<String>? subcategories,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      iconPath: iconPath ?? this.iconPath,
      colorHex: colorHex ?? this.colorHex,
      subcategories: subcategories ?? this.subcategories,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthode pour obtenir le nom dans une langue spécifique
  String getNameByLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return nameEn;
      case 'ar':
        return nameAr;
      default:
        return name; // Français par défaut
    }
  }

  // Méthode pour obtenir la description dans une langue spécifique
  String getDescriptionByLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return descriptionEn;
      case 'ar':
        return descriptionAr;
      default:
        return description; // Français par défaut
    }
  }

  // Méthode pour ajouter une sous-catégorie
  ServiceCategory addSubcategory(String subcategory) {
    if (!subcategories.contains(subcategory)) {
      return copyWith(
        subcategories: [...subcategories, subcategory],
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }

  // Méthode pour retirer une sous-catégorie
  ServiceCategory removeSubcategory(String subcategory) {
    return copyWith(
      subcategories: subcategories.where((s) => s != subcategory).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Méthode pour mettre à jour le statut actif
  ServiceCategory updateActiveStatus(bool active) {
    return copyWith(
      isActive: active,
      updatedAt: DateTime.now(),
    );
  }

  // Méthode pour mettre à jour l'ordre de tri
  ServiceCategory updateSortOrder(int order) {
    return copyWith(
      sortOrder: order,
      updatedAt: DateTime.now(),
    );
  }

  // Méthode pour ajouter des métadonnées
  ServiceCategory addMetadata(String key, dynamic value) {
    Map<String, dynamic> newMetadata = Map.from(metadata);
    newMetadata[key] = value;
    return copyWith(
      metadata: newMetadata,
      updatedAt: DateTime.now(),
    );
  }

  // Méthode pour retirer des métadonnées
  ServiceCategory removeMetadata(String key) {
    Map<String, dynamic> newMetadata = Map.from(metadata);
    newMetadata.remove(key);
    return copyWith(
      metadata: newMetadata,
      updatedAt: DateTime.now(),
    );
  }

  // Getter pour vérifier si la catégorie a des sous-catégories
  bool get hasSubcategories => subcategories.isNotEmpty;

  // Getter pour le nombre de sous-catégories
  int get subcategoryCount => subcategories.length;

  @override
  String toString() {
    return 'ServiceCategory(id: $id, name: $name, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Classe pour les sous-catégories de services
class ServiceSubcategory {
  final String id;
  final String categoryId;
  final String name;
  final String nameEn;
  final String nameAr;
  final String description;
  final String descriptionEn;
  final String descriptionAr;
  final bool isActive;
  final int sortOrder;
  final Map<String, dynamic> requirements;
  final double averagePrice;
  final String currency;

  ServiceSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameEn,
    required this.nameAr,
    required this.description,
    required this.descriptionEn,
    required this.descriptionAr,
    this.isActive = true,
    this.sortOrder = 0,
    this.requirements = const {},
    this.averagePrice = 0.0,
    this.currency = 'DZD',
  });

  factory ServiceSubcategory.fromMap(Map<String, dynamic> map) {
    return ServiceSubcategory(
      id: map['id'] ?? '',
      categoryId: map['categoryId'] ?? '',
      name: map['name'] ?? '',
      nameEn: map['nameEn'] ?? '',
      nameAr: map['nameAr'] ?? '',
      description: map['description'] ?? '',
      descriptionEn: map['descriptionEn'] ?? '',
      descriptionAr: map['descriptionAr'] ?? '',
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder'] ?? 0,
      requirements: Map<String, dynamic>.from(map['requirements'] ?? {}),
      averagePrice: (map['averagePrice'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'DZD',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'description': description,
      'descriptionEn': descriptionEn,
      'descriptionAr': descriptionAr,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'requirements': requirements,
      'averagePrice': averagePrice,
      'currency': currency,
    };
  }

  String getNameByLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return nameEn;
      case 'ar':
        return nameAr;
      default:
        return name;
    }
  }

  String getDescriptionByLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return descriptionEn;
      case 'ar':
        return descriptionAr;
      default:
        return description;
    }
  }
}