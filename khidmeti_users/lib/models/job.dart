import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

enum JobStatus {
  pending,      // En attente
  accepted,     // Accepté par un travailleur
  inProgress,   // En cours
  completed,    // Terminé
  cancelled,    // Annulé
  expired       // Expiré
}

enum JobPriority {
  low,          // Basse priorité
  medium,       // Priorité moyenne
  high,         // Haute priorité
  urgent        // Urgent
}

class Job {
  final String id;
  final String userId;
  final String userFirstName;
  final String userLastName;
  final String? userImageUrl;
  final String title;
  final String description;
  final String category;
  final List<String> images;
  final List<String> videos;
  final LatLng location;
  final String address;
  final JobStatus status;
  final JobPriority priority;
  final double budget;
  final String currency;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final String? acceptedByWorkerId;
  final String? acceptedByWorkerName;
  final String? acceptedByWorkerImageUrl;
  final double? finalPrice;
  final DateTime? completedAt;
  final double? userRating;
  final String? userComment;
  final Map<String, dynamic> requirements;
  final bool isUrgent;
  final String language;
  final List<String> tags;
  final int viewCount;
  final int applicationCount;

  Job({
    required this.id,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    this.userImageUrl,
    required this.title,
    required this.description,
    required this.category,
    this.images = const [],
    this.videos = const [],
    required this.location,
    required this.address,
    this.status = JobStatus.pending,
    this.priority = JobPriority.medium,
    required this.budget,
    this.currency = 'DZD',
    required this.deadline,
    required this.createdAt,
    this.acceptedAt,
    this.acceptedByWorkerId,
    this.acceptedByWorkerName,
    this.acceptedByWorkerImageUrl,
    this.finalPrice,
    this.completedAt,
    this.userRating,
    this.userComment,
    this.requirements = const {},
    this.isUrgent = false,
    this.language = 'fr',
    this.tags = const [],
    this.viewCount = 0,
    this.applicationCount = 0,
  });

  // Factory constructor pour créer un Job depuis Firestore
  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    GeoPoint geoPoint = data['location'] as GeoPoint;
    LatLng location = LatLng(geoPoint.latitude, geoPoint.longitude);

    return Job(
      id: doc.id,
      userId: data['userId'] ?? '',
      userFirstName: data['userFirstName'] ?? '',
      userLastName: data['userLastName'] ?? '',
      userImageUrl: data['userImageUrl'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      location: location,
      address: data['address'] ?? '',
      status: JobStatus.values.firstWhere(
        (e) => e.toString() == 'JobStatus.${data['status']}',
        orElse: () => JobStatus.pending,
      ),
      priority: JobPriority.values.firstWhere(
        (e) => e.toString() == 'JobPriority.${data['priority']}',
        orElse: () => JobPriority.medium,
      ),
      budget: (data['budget'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'DZD',
      deadline: (data['deadline'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      acceptedAt: data['acceptedAt'] != null 
          ? (data['acceptedAt'] as Timestamp).toDate() 
          : null,
      acceptedByWorkerId: data['acceptedByWorkerId'],
      acceptedByWorkerName: data['acceptedByWorkerName'],
      acceptedByWorkerImageUrl: data['acceptedByWorkerImageUrl'],
      finalPrice: data['finalPrice'] != null 
          ? (data['finalPrice'] as num).toDouble() 
          : null,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      userRating: data['userRating'] != null 
          ? (data['userRating'] as num).toDouble() 
          : null,
      userComment: data['userComment'],
      requirements: Map<String, dynamic>.from(data['requirements'] ?? {}),
      isUrgent: data['isUrgent'] ?? false,
      language: data['language'] ?? 'fr',
      tags: List<String>.from(data['tags'] ?? []),
      viewCount: data['viewCount'] ?? 0,
      applicationCount: data['applicationCount'] ?? 0,
    );
  }

  // Méthode pour convertir Job en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'userId': userId,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'userImageUrl': userImageUrl,
      'title': title,
      'description': description,
      'category': category,
      'images': images,
      'videos': videos,
      'location': GeoPoint(location.latitude, location.longitude),
      'address': address,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'budget': budget,
      'currency': currency,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedByWorkerId': acceptedByWorkerId,
      'acceptedByWorkerName': acceptedByWorkerName,
      'acceptedByWorkerImageUrl': acceptedByWorkerImageUrl,
      'finalPrice': finalPrice,
      'userRating': userRating,
      'userComment': userComment,
      'requirements': requirements,
      'isUrgent': isUrgent,
      'language': language,
      'tags': tags,
      'viewCount': viewCount,
      'applicationCount': applicationCount,
    };

    if (acceptedAt != null) {
      data['acceptedAt'] = Timestamp.fromDate(acceptedAt!);
    }

    if (completedAt != null) {
      data['completedAt'] = Timestamp.fromDate(completedAt!);
    }

    return data;
  }

  // Méthode pour créer une copie modifiée
  Job copyWith({
    String? id,
    String? userId,
    String? userFirstName,
    String? userLastName,
    String? userImageUrl,
    String? title,
    String? description,
    String? category,
    List<String>? images,
    List<String>? videos,
    LatLng? location,
    String? address,
    JobStatus? status,
    JobPriority? priority,
    double? budget,
    String? currency,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? acceptedAt,
    String? acceptedByWorkerId,
    String? acceptedByWorkerName,
    String? acceptedByWorkerImageUrl,
    double? finalPrice,
    DateTime? completedAt,
    double? userRating,
    String? userComment,
    Map<String, dynamic>? requirements,
    bool? isUrgent,
    String? language,
    List<String>? tags,
    int? viewCount,
    int? applicationCount,
  }) {
    return Job(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userFirstName: userFirstName ?? this.userFirstName,
      userLastName: userLastName ?? this.userLastName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      location: location ?? this.location,
      address: address ?? this.address,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      acceptedByWorkerId: acceptedByWorkerId ?? this.acceptedByWorkerId,
      acceptedByWorkerName: acceptedByWorkerName ?? this.acceptedByWorkerName,
      acceptedByWorkerImageUrl: acceptedByWorkerImageUrl ?? this.acceptedByWorkerImageUrl,
      finalPrice: finalPrice ?? this.finalPrice,
      completedAt: completedAt ?? this.completedAt,
      userRating: userRating ?? this.userRating,
      userComment: userComment ?? this.userComment,
      requirements: requirements ?? this.requirements,
      isUrgent: isUrgent ?? this.isUrgent,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      applicationCount: applicationCount ?? this.applicationCount,
    );
  }

  // Getters utiles
  String get userName => '$userFirstName $userLastName';
  
  bool get isActive => status == JobStatus.pending || status == JobStatus.accepted;
  
  bool get isCompleted => status == JobStatus.completed;
  
  bool get isCancelled => status == JobStatus.cancelled;
  
  bool get isExpired => DateTime.now().isAfter(deadline);
  
  bool get hasWorker => acceptedByWorkerId != null;
  
  bool get canBeRated => isCompleted && userRating == null;
  
  String get statusDisplay {
    switch (status) {
      case JobStatus.pending:
        return 'En attente';
      case JobStatus.accepted:
        return 'Accepté';
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

  String get priorityDisplay {
    switch (priority) {
      case JobPriority.low:
        return 'Basse';
      case JobPriority.medium:
        return 'Moyenne';
      case JobPriority.high:
        return 'Haute';
      case JobPriority.urgent:
        return 'Urgente';
    }
  }

  // Méthodes de gestion du statut
  Job acceptJob(String workerId, String workerName, String? workerImageUrl) {
    return copyWith(
      status: JobStatus.accepted,
      acceptedAt: DateTime.now(),
      acceptedByWorkerId: workerId,
      acceptedByWorkerName: workerName,
      acceptedByWorkerImageUrl: workerImageUrl,
    );
  }

  Job startJob() {
    return copyWith(status: JobStatus.inProgress);
  }

  Job completeJob(double finalPrice) {
    return copyWith(
      status: JobStatus.completed,
      completedAt: DateTime.now(),
      finalPrice: finalPrice,
    );
  }

  Job cancelJob() {
    return copyWith(status: JobStatus.cancelled);
  }

  Job expireJob() {
    return copyWith(status: JobStatus.expired);
  }

  Job addImage(String imageUrl) {
    return copyWith(images: [...images, imageUrl]);
  }

  Job addVideo(String videoUrl) {
    return copyWith(videos: [...videos, videoUrl]);
  }

  Job addTag(String tag) {
    if (!tags.contains(tag)) {
      return copyWith(tags: [...tags, tag]);
    }
    return this;
  }

  Job incrementViewCount() {
    return copyWith(viewCount: viewCount + 1);
  }

  Job incrementApplicationCount() {
    return copyWith(applicationCount: applicationCount + 1);
  }

  Job rateJob(double rating, String comment) {
    return copyWith(
      userRating: rating,
      userComment: comment,
    );
  }

  // Méthode pour calculer la distance avec un autre point
  double calculateDistance(LatLng otherLocation) {
    const double earthRadius = 6371; // km
    double lat1 = location.latitude * (pi / 180);
    double lat2 = otherLocation.latitude * (pi / 180);
    double deltaLat = (otherLocation.latitude - location.latitude) * (pi / 180);
    double deltaLon = (otherLocation.longitude - location.longitude) * (pi / 180);

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Méthode pour vérifier si le job est proche d'une localisation
  bool isNearLocation(LatLng otherLocation, double maxDistanceKm) {
    double distance = calculateDistance(otherLocation);
    return distance <= maxDistanceKm;
  }

  @override
  String toString() {
    return 'Job(id: $id, title: $title, status: $status, budget: $budget $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Job && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}