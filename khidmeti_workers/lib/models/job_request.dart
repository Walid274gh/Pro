import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

enum JobRequestStatus {
  pending,      // En attente
  accepted,     // Accepté par ce travailleur
  acceptedByOther, // Accepté par un autre travailleur
  inProgress,   // En cours
  completed,    // Terminé
  cancelled,    // Annulé par l'utilisateur
  expired       // Expiré
}

enum JobRequestPriority {
  low,          // Basse priorité
  medium,       // Priorité moyenne
  high,         // Haute priorité
  urgent        // Urgente
}

class JobRequest {
  final String id;
  final String jobId;
  final String userId;
  final String userFirstName;
  final String userLastName;
  final String? userImageUrl;
  final String? userPhoneNumber;
  final String title;
  final String description;
  final String category;
  final List<String> images;
  final List<String> videos;
  final LatLng location;
  final String address;
  final JobRequestStatus status;
  final JobRequestPriority priority;
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
  final Map<String, dynamic> requirements;
  final bool isUrgent;
  final String language;
  final List<String> tags;
  final int viewCount;
  final int applicationCount;
  final List<String> appliedWorkers;
  final Map<String, dynamic> workerOffers;
  final String? notes;
  final bool isFavorite;

  JobRequest({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    this.userImageUrl,
    this.userPhoneNumber,
    required this.title,
    required this.description,
    required this.category,
    this.images = const [],
    this.videos = const [],
    required this.location,
    required this.address,
    this.status = JobRequestStatus.pending,
    this.priority = JobRequestPriority.medium,
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
    this.requirements = const {},
    this.isUrgent = false,
    this.language = 'fr',
    this.tags = const [],
    this.viewCount = 0,
    this.applicationCount = 0,
    this.appliedWorkers = const [],
    this.workerOffers = const {},
    this.notes,
    this.isFavorite = false,
  });

  // Factory constructor pour créer un JobRequest depuis Firestore
  factory JobRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    GeoPoint geoPoint = data['location'] as GeoPoint;
    LatLng location = LatLng(geoPoint.latitude, geoPoint.longitude);

    return JobRequest(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      userId: data['userId'] ?? '',
      userFirstName: data['userFirstName'] ?? '',
      userLastName: data['userLastName'] ?? '',
      userImageUrl: data['userImageUrl'],
      userPhoneNumber: data['userPhoneNumber'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      location: location,
      address: data['address'] ?? '',
      status: JobRequestStatus.values.firstWhere(
        (e) => e.toString() == 'JobRequestStatus.${data['status']}',
        orElse: () => JobRequestStatus.pending,
      ),
      priority: JobRequestPriority.values.firstWhere(
        (e) => e.toString() == 'JobRequestPriority.${data['priority']}',
        orElse: () => JobRequestPriority.medium,
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
      requirements: Map<String, dynamic>.from(data['requirements'] ?? {}),
      isUrgent: data['isUrgent'] ?? false,
      language: data['language'] ?? 'fr',
      tags: List<String>.from(data['tags'] ?? []),
      viewCount: data['viewCount'] ?? 0,
      applicationCount: data['applicationCount'] ?? 0,
      appliedWorkers: List<String>.from(data['appliedWorkers'] ?? []),
      workerOffers: Map<String, dynamic>.from(data['workerOffers'] ?? {}),
      notes: data['notes'],
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  // Méthode pour convertir JobRequest en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'jobId': jobId,
      'userId': userId,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'userImageUrl': userImageUrl,
      'userPhoneNumber': userPhoneNumber,
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
      'requirements': requirements,
      'isUrgent': isUrgent,
      'language': language,
      'tags': tags,
      'viewCount': viewCount,
      'applicationCount': applicationCount,
      'appliedWorkers': appliedWorkers,
      'workerOffers': workerOffers,
      'notes': notes,
      'isFavorite': isFavorite,
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
  JobRequest copyWith({
    String? id,
    String? jobId,
    String? userId,
    String? userFirstName,
    String? userLastName,
    String? userImageUrl,
    String? userPhoneNumber,
    String? title,
    String? description,
    String? category,
    List<String>? images,
    List<String>? videos,
    LatLng? location,
    String? address,
    JobRequestStatus? status,
    JobRequestPriority? priority,
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
    Map<String, dynamic>? requirements,
    bool? isUrgent,
    String? language,
    List<String>? tags,
    int? viewCount,
    int? applicationCount,
    List<String>? appliedWorkers,
    Map<String, dynamic>? workerOffers,
    String? notes,
    bool? isFavorite,
  }) {
    return JobRequest(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      userFirstName: userFirstName ?? this.userFirstName,
      userLastName: userLastName ?? this.userLastName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      userPhoneNumber: userPhoneNumber ?? this.userPhoneNumber,
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
      requirements: requirements ?? this.requirements,
      isUrgent: isUrgent ?? this.isUrgent,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      applicationCount: applicationCount ?? this.applicationCount,
      appliedWorkers: appliedWorkers ?? this.appliedWorkers,
      workerOffers: workerOffers ?? this.workerOffers,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Getters utiles
  String get userName => '$userFirstName $userLastName';
  
  bool get isActive => status == JobRequestStatus.pending;
  
  bool get isAccepted => status == JobRequestStatus.accepted;
  
  bool get isAcceptedByOther => status == JobRequestStatus.acceptedByOther;
  
  bool get isCompleted => status == JobRequestStatus.completed;
  
  bool get isCancelled => status == JobRequestStatus.cancelled;
  
  bool get isExpired => DateTime.now().isAfter(deadline);
  
  bool get hasWorker => acceptedByWorkerId != null;
  
  bool get canBeAccepted => isActive && !isExpired;
  
  bool get canBeApplied => isActive && !isExpired && !appliedWorkers.contains(userId);
  
  String get statusDisplay {
    switch (status) {
      case JobRequestStatus.pending:
        return 'En attente';
      case JobRequestStatus.accepted:
        return 'Accepté par vous';
      case JobRequestStatus.acceptedByOther:
        return 'Accepté par un autre';
      case JobRequestStatus.inProgress:
        return 'En cours';
      case JobRequestStatus.completed:
        return 'Terminé';
      case JobRequestStatus.cancelled:
        return 'Annulé';
      case JobRequestStatus.expired:
        return 'Expiré';
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case JobRequestPriority.low:
        return 'Basse';
      case JobRequestPriority.medium:
        return 'Moyenne';
      case JobRequestPriority.high:
        return 'Haute';
      case JobRequestPriority.urgent:
        return 'Urgente';
    }
  }

  // Méthodes de gestion du statut
  JobRequest acceptJob(String workerId, String workerName, String? workerImageUrl) {
    return copyWith(
      status: JobRequestStatus.accepted,
      acceptedAt: DateTime.now(),
      acceptedByWorkerId: workerId,
      acceptedByWorkerName: workerName,
      acceptedByWorkerImageUrl: workerImageUrl,
    );
  }

  JobRequest markAsAcceptedByOther() {
    return copyWith(status: JobRequestStatus.acceptedByOther);
  }

  JobRequest startJob() {
    return copyWith(status: JobRequestStatus.inProgress);
  }

  JobRequest completeJob(double finalPrice) {
    return copyWith(
      status: JobRequestStatus.completed,
      completedAt: DateTime.now(),
      finalPrice: finalPrice,
    );
  }

  JobRequest cancelJob() {
    return copyWith(status: JobRequestStatus.cancelled);
  }

  JobRequest expireJob() {
    return copyWith(status: JobRequestStatus.expired);
  }

  JobRequest addWorkerApplication(String workerId) {
    if (!appliedWorkers.contains(workerId)) {
      return copyWith(
        appliedWorkers: [...appliedWorkers, workerId],
        applicationCount: applicationCount + 1,
      );
    }
    return this;
  }

  JobRequest removeWorkerApplication(String workerId) {
    return copyWith(
      appliedWorkers: appliedWorkers.where((id) => id != workerId).toList(),
      applicationCount: applicationCount > 0 ? applicationCount - 1 : 0,
    );
  }

  JobRequest addWorkerOffer(String workerId, Map<String, dynamic> offer) {
    Map<String, dynamic> newOffers = Map.from(workerOffers);
    newOffers[workerId] = offer;
    return copyWith(workerOffers: newOffers);
  }

  JobRequest removeWorkerOffer(String workerId) {
    Map<String, dynamic> newOffers = Map.from(workerOffers);
    newOffers.remove(workerId);
    return copyWith(workerOffers: newOffers);
  }

  JobRequest toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }

  JobRequest incrementViewCount() {
    return copyWith(viewCount: viewCount + 1);
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

  // Méthode pour obtenir l'âge de la demande
  Duration get age => DateTime.now().difference(createdAt);
  
  // Méthode pour vérifier si la demande est récente (moins de 1h)
  bool get isRecent => age.inMinutes < 60;
  
  // Méthode pour vérifier si la demande est ancienne (plus de 24h)
  bool get isOld => age.inHours > 24;

  // Méthode pour vérifier si la demande expire bientôt (moins de 2h)
  bool get expiresSoon {
    Duration timeUntilDeadline = deadline.difference(DateTime.now());
    return timeUntilDeadline.inHours < 2 && timeUntilDeadline.isNegative == false;
  }

  // Méthode pour obtenir le temps restant avant expiration
  Duration get timeUntilExpiry => deadline.difference(DateTime.now());

  @override
  String toString() {
    return 'JobRequest(id: $id, title: $title, status: $status, budget: $budget $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}