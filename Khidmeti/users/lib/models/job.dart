import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de données pour une demande de travail dans l'application KHIDMETI Users
/// Cette classe respecte le principe de responsabilité unique (SRP) du SOLID
class Job {
  final String id;
  final String userId;
  final String userFirstName;
  final String userLastName;
  final String title;
  final String description;
  final String category;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime? deadline;
  final JobStatus status;
  final double budget;
  final String budgetType; // 'fixed', 'hourly', 'negotiable'
  final List<String> images;
  final List<String> videos;
  final Map<String, dynamic> requirements;
  final List<String> appliedWorkers;
  final String? assignedWorkerId;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final double? finalPrice;
  final String? userReview;
  final double? userRating;
  final bool isUrgent;
  final bool isPremium;
  final String language;
  final Map<String, dynamic> metadata;

  const Job({
    required this.id,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.deadline,
    this.status = JobStatus.open,
    required this.budget,
    required this.budgetType,
    this.images = const [],
    this.videos = const [],
    this.requirements = const {},
    this.appliedWorkers = const [],
    this.assignedWorkerId,
    this.assignedAt,
    this.completedAt,
    this.finalPrice,
    this.userReview,
    this.userRating,
    this.isUrgent = false,
    this.isPremium = false,
    this.language = 'fr',
    this.metadata = const {},
  });

  /// Création d'un job à partir des données Firestore
  factory Job.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      userId: data['userId'] ?? '',
      userFirstName: data['userFirstName'] ?? '',
      userLastName: data['userLastName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deadline: data['deadline'] != null ? (data['deadline'] as Timestamp).toDate() : null,
      status: JobStatus.values.firstWhere(
        (e) => e.toString() == 'JobStatus.${data['status'] ?? 'open'}',
        orElse: () => JobStatus.open,
      ),
      budget: (data['budget'] ?? 0.0).toDouble(),
      budgetType: data['budgetType'] ?? 'fixed',
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      requirements: Map<String, dynamic>.from(data['requirements'] ?? {}),
      appliedWorkers: List<String>.from(data['appliedWorkers'] ?? []),
      assignedWorkerId: data['assignedWorkerId'],
      assignedAt: data['assignedAt'] != null ? (data['assignedAt'] as Timestamp).toDate() : null,
      completedAt: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
      finalPrice: data['finalPrice'] != null ? (data['finalPrice'] ?? 0.0).toDouble() : null,
      userReview: data['userReview'],
      userRating: data['userRating'] != null ? (data['userRating'] ?? 0.0).toDouble() : null,
      isUrgent: data['isUrgent'] ?? false,
      isPremium: data['isPremium'] ?? false,
      language: data['language'] ?? 'fr',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'status': status.toString().split('.').last,
      'budget': budget,
      'budgetType': budgetType,
      'images': images,
      'videos': videos,
      'requirements': requirements,
      'appliedWorkers': appliedWorkers,
      'assignedWorkerId': assignedWorkerId,
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'finalPrice': finalPrice,
      'userReview': userReview,
      'userRating': userRating,
      'isUrgent': isUrgent,
      'isPremium': isPremium,
      'language': language,
      'metadata': metadata,
    };
  }

  /// Création d'une copie avec modifications
  Job copyWith({
    String? id,
    String? userId,
    String? userFirstName,
    String? userLastName,
    String? title,
    String? description,
    String? category,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? deadline,
    JobStatus? status,
    double? budget,
    String? budgetType,
    List<String>? images,
    List<String>? videos,
    Map<String, dynamic>? requirements,
    List<String>? appliedWorkers,
    String? assignedWorkerId,
    DateTime? assignedAt,
    DateTime? completedAt,
    double? finalPrice,
    String? userReview,
    double? userRating,
    bool? isUrgent,
    bool? isPremium,
    String? language,
    Map<String, dynamic>? metadata,
  }) {
    return Job(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userFirstName: userFirstName ?? this.userFirstName,
      userLastName: userLastName ?? this.userLastName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      budgetType: budgetType ?? this.budgetType,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      requirements: requirements ?? this.requirements,
      appliedWorkers: appliedWorkers ?? this.appliedWorkers,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      finalPrice: finalPrice ?? this.finalPrice,
      userReview: userReview ?? this.userReview,
      userRating: userRating ?? this.userRating,
      isUrgent: isUrgent ?? this.isUrgent,
      isPremium: isPremium ?? this.isPremium,
      language: language ?? this.language,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Nom complet de l'utilisateur qui a publié le job
  String get userName => '$userFirstName $userLastName';

  /// Vérification si le job a des médias
  bool get hasMedia => images.isNotEmpty || videos.isNotEmpty;

  /// Vérification si le job a des exigences
  bool get hasRequirements => requirements.isNotEmpty;

  /// Vérification si le job a des candidats
  bool get hasApplicants => appliedWorkers.isNotEmpty;

  /// Vérification si le job est assigné
  bool get isAssigned => assignedWorkerId != null;

  /// Vérification si le job est terminé
  bool get isCompleted => status == JobStatus.completed;

  /// Vérification si le job est en cours
  bool get isInProgress => status == JobStatus.inProgress;

  /// Vérification si le job est ouvert
  bool get isOpen => status == JobStatus.open;

  /// Vérification si le job est urgent
  bool get isUrgentJob => isUrgent || (deadline != null && DateTime.now().isAfter(deadline!));

  /// Vérification si le job a un délai
  bool get hasDeadline => deadline != null;

  /// Délai restant formaté
  String get deadlineDisplay {
    if (deadline == null) return 'Aucun délai';
    final now = DateTime.now();
    final difference = deadline!.difference(now);
    if (difference.isNegative) return 'En retard';
    if (difference.inDays > 0) return '${difference.inDays} jour(s) restant(s)';
    if (difference.inHours > 0) return '${difference.inHours} heure(s) restante(s)';
    return '${difference.inMinutes} minute(s) restante(s)';
  }

  /// Budget formaté
  String get budgetDisplay {
    if (budgetType == 'hourly') return '${budget.toStringAsFixed(0)} DZD/h';
    if (budgetType == 'negotiable') return 'Négociable';
    return '${budget.toStringAsFixed(0)} DZD';
  }

  /// Statut formaté pour l'affichage
  String get statusDisplay {
    switch (status) {
      case JobStatus.open:
        return 'Ouvert';
      case JobStatus.inProgress:
        return 'En cours';
      case JobStatus.completed:
        return 'Terminé';
      case JobStatus.cancelled:
        return 'Annulé';
      case JobStatus.expired:
        return 'Expiré';
    }
  }

  /// Catégorie formatée
  String get categoryDisplay {
    final categories = {
      'plomberie': 'Plomberie',
      'electricite': 'Électricité',
      'nettoyage': 'Nettoyage',
      'livraison': 'Livraison',
      'peinture': 'Peinture',
      'reparation_electromenager': 'Réparation Électroménager',
      'maconnerie': 'Maçonnerie',
      'climatisation': 'Climatisation',
      'babysitting': 'Baby-sitting',
      'cours_particuliers': 'Cours Particuliers',
    };
    return categories[category] ?? category;
  }

  @override
  String toString() {
    return 'Job(id: $id, title: $title, category: $category, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Job && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Énumération des statuts possibles d'un job
enum JobStatus {
  open,        // Ouvert aux candidatures
  inProgress,  // En cours d'exécution
  completed,   // Terminé
  cancelled,   // Annulé
  expired,     // Expiré
}

/// Extension pour les méthodes utilitaires sur JobStatus
extension JobStatusExtension on JobStatus {
  /// Couleur associée au statut
  String get color {
    switch (this) {
      case JobStatus.open:
        return '#10B981'; // Vert
      case JobStatus.inProgress:
        return '#F59E0B'; // Orange
      case JobStatus.completed:
        return '#3B82F6'; // Bleu
      case JobStatus.cancelled:
        return '#EF4444'; // Rouge
      case JobStatus.expired:
        return '#6B7280'; // Gris
    }
  }

  /// Icône associée au statut
  String get icon {
    switch (this) {
      case JobStatus.open:
        return '📋';
      case JobStatus.inProgress:
        return '🔄';
      case JobStatus.completed:
        return '✅';
      case JobStatus.cancelled:
        return '❌';
      case JobStatus.expired:
        return '⏰';
    }
  }
}