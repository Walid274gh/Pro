import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  jobAccepted,      // Travail accepté par un travailleur
  jobCompleted,     // Travail terminé
  jobCancelled,     // Travail annulé
  newMessage,       // Nouveau message
  paymentReceived,  // Paiement reçu
  workerNearby,     // Travailleur à proximité
  systemUpdate,     // Mise à jour système
  reminder,         // Rappel
  promotion,        // Promotion/offre
  security         // Sécurité/authentification
}

enum NotificationPriority {
  low,      // Basse priorité
  normal,   // Priorité normale
  high,     // Haute priorité
  urgent    // Urgente
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String titleEn;
  final String titleAr;
  final String body;
  final String bodyEn;
  final String bodyAr;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final bool isRead;
  final bool isActioned;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? actionedAt;
  final String? actionUrl;
  final String? workerId;
  final String? jobId;
  final String? messageId;
  final Map<String, dynamic> metadata;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    this.priority = NotificationPriority.normal,
    required this.title,
    required this.titleEn,
    required this.body,
    required this.bodyEn,
    this.titleAr = '',
    this.bodyAr = '',
    this.imageUrl,
    this.data = const {},
    this.isRead = false,
    this.isActioned = false,
    required this.createdAt,
    this.readAt,
    this.actionedAt,
    this.actionUrl,
    this.workerId,
    this.jobId,
    this.messageId,
    this.metadata = const {},
  });

  // Factory constructor pour créer un AppNotification depuis Firestore
  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.systemUpdate,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == 'NotificationPriority.${data['priority']}',
        orElse: () => NotificationPriority.normal,
      ),
      title: data['title'] ?? '',
      titleEn: data['titleEn'] ?? '',
      titleAr: data['titleAr'] ?? '',
      body: data['body'] ?? '',
      bodyEn: data['bodyEn'] ?? '',
      bodyAr: data['bodyAr'] ?? '',
      imageUrl: data['imageUrl'],
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isRead: data['isRead'] ?? false,
      isActioned: data['isActioned'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      readAt: data['readAt'] != null 
          ? (data['readAt'] as Timestamp).toDate() 
          : null,
      actionedAt: data['actionedAt'] != null 
          ? (data['actionedAt'] as Timestamp).toDate() 
          : null,
      actionUrl: data['actionUrl'],
      workerId: data['workerId'],
      jobId: data['jobId'],
      messageId: data['messageId'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  // Méthode pour convertir AppNotification en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'userId': userId,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'title': title,
      'titleEn': titleEn,
      'titleAr': titleAr,
      'body': body,
      'bodyEn': bodyEn,
      'bodyAr': bodyAr,
      'imageUrl': imageUrl,
      'data': this.data,
      'isRead': isRead,
      'isActioned': isActioned,
      'createdAt': Timestamp.fromDate(createdAt),
      'actionUrl': actionUrl,
      'workerId': workerId,
      'jobId': jobId,
      'messageId': messageId,
      'metadata': metadata,
    };

    if (readAt != null) {
      data['readAt'] = Timestamp.fromDate(readAt!);
    }

    if (actionedAt != null) {
      data['actionedAt'] = Timestamp.fromDate(actionedAt!);
    }

    return data;
  }

  // Méthode pour créer une copie modifiée
  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? titleEn,
    String? titleAr,
    String? body,
    String? bodyEn,
    String? bodyAr,
    String? imageUrl,
    Map<String, dynamic>? data,
    bool? isRead,
    bool? isActioned,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? actionedAt,
    String? actionUrl,
    String? workerId,
    String? jobId,
    String? messageId,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      body: body ?? this.body,
      bodyEn: bodyEn ?? this.bodyEn,
      bodyAr: bodyAr ?? this.bodyAr,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      isActioned: isActioned ?? this.isActioned,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      actionedAt: actionedAt ?? this.actionedAt,
      actionUrl: actionUrl ?? this.actionUrl,
      workerId: workerId ?? this.workerId,
      jobId: jobId ?? this.jobId,
      messageId: messageId ?? this.messageId,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthode pour obtenir le titre dans une langue spécifique
  String getTitleByLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return titleEn;
      case 'ar':
        return titleAr;
      default:
        return title; // Français par défaut
    }
  }

  // Méthode pour obtenir le corps dans une langue spécifique
  String getBodyByLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return bodyEn;
      case 'ar':
        return bodyAr;
      default:
        return body; // Français par défaut
    }
  }

  // Méthode pour marquer comme lu
  AppNotification markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  // Méthode pour marquer comme actionnée
  AppNotification markAsActioned() {
    return copyWith(
      isActioned: true,
      actionedAt: DateTime.now(),
    );
  }

  // Méthode pour ajouter des métadonnées
  AppNotification addMetadata(String key, dynamic value) {
    Map<String, dynamic> newMetadata = Map.from(metadata);
    newMetadata[key] = value;
    return copyWith(metadata: newMetadata);
  }

  // Méthode pour retirer des métadonnées
  AppNotification removeMetadata(String key) {
    Map<String, dynamic> newMetadata = Map.from(metadata);
    newMetadata.remove(key);
    return copyWith(metadata: newMetadata);
  }

  // Getters utiles
  bool get isUnread => !isRead;
  
  bool get hasAction => actionUrl != null;
  
  bool get isHighPriority => priority == NotificationPriority.high || priority == NotificationPriority.urgent;
  
  bool get isUrgent => priority == NotificationPriority.urgent;
  
  String get typeDisplay {
    switch (type) {
      case NotificationType.jobAccepted:
        return 'Travail accepté';
      case NotificationType.jobCompleted:
        return 'Travail terminé';
      case NotificationType.jobCancelled:
        return 'Travail annulé';
      case NotificationType.newMessage:
        return 'Nouveau message';
      case NotificationType.paymentReceived:
        return 'Paiement reçu';
      case NotificationType.workerNearby:
        return 'Travailleur à proximité';
      case NotificationType.systemUpdate:
        return 'Mise à jour système';
      case NotificationType.reminder:
        return 'Rappel';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.security:
        return 'Sécurité';
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case NotificationPriority.low:
        return 'Basse';
      case NotificationPriority.normal:
        return 'Normale';
      case NotificationPriority.high:
        return 'Haute';
      case NotificationPriority.urgent:
        return 'Urgente';
    }
  }

  // Méthode pour vérifier si la notification est liée à un travail
  bool get isJobRelated => 
      type == NotificationType.jobAccepted ||
      type == NotificationType.jobCompleted ||
      type == NotificationType.jobCancelled;

  // Méthode pour vérifier si la notification est liée à un travailleur
  bool get isWorkerRelated => 
      type == NotificationType.jobAccepted ||
      type == NotificationType.workerNearby;

  // Méthode pour vérifier si la notification est liée à un message
  bool get isMessageRelated => type == NotificationType.newMessage;

  // Méthode pour obtenir l'âge de la notification
  Duration get age => DateTime.now().difference(createdAt);

  // Méthode pour vérifier si la notification est récente (moins de 24h)
  bool get isRecent => age.inHours < 24;

  // Méthode pour vérifier si la notification est ancienne (plus de 7 jours)
  bool get isOld => age.inDays > 7;

  @override
  String toString() {
    return 'AppNotification(id: $id, type: $type, title: $title, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}