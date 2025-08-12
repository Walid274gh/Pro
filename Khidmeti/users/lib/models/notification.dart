import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de données pour les notifications dans l'application KHIDMETI Users
/// Cette classe respecte le principe de responsabilité unique (SRP) du SOLID
class Notification {
  final String id;
  final String recipientId;
  final String recipientType; // 'user' ou 'worker'
  final String senderId;
  final String senderType; // 'user' ou 'worker'
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? clickedAt;
  final bool isRead;
  final bool isClicked;
  final String? imageUrl;
  final String? actionUrl;
  final String language;
  final Map<String, dynamic> metadata;

  const Notification({
    required this.id,
    required this.recipientId,
    required this.recipientType,
    required this.senderId,
    required this.senderType,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.data = const {},
    required this.createdAt,
    this.readAt,
    this.clickedAt,
    this.isRead = false,
    this.isClicked = false,
    this.imageUrl,
    this.actionUrl,
    this.language = 'fr',
    this.metadata = const {},
  });

  /// Création d'une notification à partir des données Firestore
  factory Notification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Notification(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      recipientType: data['recipientType'] ?? 'user',
      senderId: data['senderId'] ?? '',
      senderType: data['senderType'] ?? 'user',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type'] ?? 'general'}',
        orElse: () => NotificationType.general,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == 'NotificationPriority.${data['priority'] ?? 'normal'}',
        orElse: () => NotificationPriority.normal,
      ),
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      readAt: data['readAt'] != null ? (data['readAt'] as Timestamp).toDate() : null,
      clickedAt: data['clickedAt'] != null ? (data['clickedAt'] as Timestamp).toDate() : null,
      isRead: data['isRead'] ?? false,
      isClicked: data['isClicked'] ?? false,
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
      language: data['language'] ?? 'fr',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'recipientType': recipientType,
      'senderId': senderId,
      'senderType': senderType,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'clickedAt': clickedAt != null ? Timestamp.fromDate(clickedAt!) : null,
      'isRead': isRead,
      'isClicked': isClicked,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'language': language,
      'metadata': metadata,
    };
  }

  /// Création d'une copie avec modifications
  Notification copyWith({
    String? id,
    String? recipientId,
    String? recipientType,
    String? senderId,
    String? senderType,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? clickedAt,
    bool? isRead,
    bool? isClicked,
    String? imageUrl,
    String? actionUrl,
    String? language,
    Map<String, dynamic>? metadata,
  }) {
    return Notification(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      recipientType: recipientType ?? this.recipientType,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      clickedAt: clickedAt ?? this.clickedAt,
      isRead: isRead ?? this.isRead,
      isClicked: isClicked ?? this.isClicked,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      language: language ?? this.language,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Vérification si la notification est récente (< 1 heure)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 1;
  }

  /// Vérification si la notification est ancienne (> 24 heures)
  bool get isOld {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours > 24;
  }

  /// Vérification si la notification a une action
  bool get hasAction => actionUrl != null;

  /// Vérification si la notification a une image
  bool get hasImage => imageUrl != null;

  /// Vérification si la notification a des données supplémentaires
  bool get hasData => data.isNotEmpty;

  /// Temps écoulé depuis la création formaté
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} jour(s)';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure(s)';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s)';
    } else {
      return 'À l\'instant';
    }
  }

  /// Statut formaté pour l'affichage
  String get statusDisplay {
    if (isClicked) return 'Cliquée';
    if (isRead) return 'Lue';
    return 'Non lue';
  }

  /// Type formaté pour l'affichage
  String get typeDisplay {
    switch (type) {
      case NotificationType.jobRequest:
        return 'Demande de travail';
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
      case NotificationType.subscriptionExpiring:
        return 'Abonnement expirant';
      case NotificationType.workerOnline:
        return 'Travailleur en ligne';
      case NotificationType.workerOffline:
        return 'Travailleur hors ligne';
      case NotificationType.general:
        return 'Notification générale';
    }
  }

  /// Priorité formatée pour l'affichage
  String get priorityDisplay {
    switch (priority) {
      case NotificationPriority.low:
        return 'Basse';
      case NotificationPriority.normal:
        return 'Normale';
      case NotificationPriority.high:
        return 'Élevée';
      case NotificationPriority.urgent:
        return 'Urgente';
    }
  }

  /// Marquer comme lue
  Notification markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// Marquer comme cliquée
  Notification markAsClicked() {
    return copyWith(
      isClicked: true,
      clickedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Notification(id: $id, type: $type, title: $title, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Énumération des types de notifications
enum NotificationType {
  jobRequest,           // Nouvelle demande de travail
  jobAccepted,          // Travail accepté par un travailleur
  jobCompleted,         // Travail terminé
  jobCancelled,         // Travail annulé
  newMessage,           // Nouveau message
  paymentReceived,      // Paiement reçu
  subscriptionExpiring, // Abonnement expirant
  workerOnline,         // Travailleur en ligne
  workerOffline,        // Travailleur hors ligne
  general,              // Notification générale
}

/// Énumération des priorités de notifications
enum NotificationPriority {
  low,      // Priorité basse
  normal,   // Priorité normale
  high,     // Priorité élevée
  urgent,   // Priorité urgente
}

/// Extension pour les méthodes utilitaires sur NotificationType
extension NotificationTypeExtension on NotificationType {
  /// Icône associée au type de notification
  String get icon {
    switch (this) {
      case NotificationType.jobRequest:
        return '📋';
      case NotificationType.jobAccepted:
        return '✅';
      case NotificationType.jobCompleted:
        return '🎉';
      case NotificationType.jobCancelled:
        return '❌';
      case NotificationType.newMessage:
        return '💬';
      case NotificationType.paymentReceived:
        return '💰';
      case NotificationType.subscriptionExpiring:
        return '⏰';
      case NotificationType.workerOnline:
        return '🟢';
      case NotificationType.workerOffline:
        return '🔴';
      case NotificationType.general:
        return '🔔';
    }
  }

  /// Couleur associée au type de notification
  String get color {
    switch (this) {
      case NotificationType.jobRequest:
        return '#3B82F6'; // Bleu
      case NotificationType.jobAccepted:
        return '#10B981'; // Vert
      case NotificationType.jobCompleted:
        return '#8B5CF6'; // Violet
      case NotificationType.jobCancelled:
        return '#EF4444'; // Rouge
      case NotificationType.newMessage:
        return '#F59E0B'; // Orange
      case NotificationType.paymentReceived:
        return '#10B981'; // Vert
      case NotificationType.subscriptionExpiring:
        return '#F59E0B'; // Orange
      case NotificationType.workerOnline:
        return '#10B981'; // Vert
      case NotificationType.workerOffline:
        return '#6B7280'; // Gris
      case NotificationType.general:
        return '#6B7280'; // Gris
    }
  }

  /// Son associé au type de notification
  String get sound {
    switch (this) {
      case NotificationType.jobRequest:
        return 'job_request.mp3';
      case NotificationType.jobAccepted:
        return 'job_accepted.mp3';
      case NotificationType.jobCompleted:
        return 'job_completed.mp3';
      case NotificationType.jobCancelled:
        return 'job_cancelled.mp3';
      case NotificationType.newMessage:
        return 'new_message.mp3';
      case NotificationType.paymentReceived:
        return 'payment_received.mp3';
      case NotificationType.subscriptionExpiring:
        return 'subscription_expiring.mp3';
      case NotificationType.workerOnline:
        return 'worker_online.mp3';
      case NotificationType.workerOffline:
        return 'worker_offline.mp3';
      case NotificationType.general:
        return 'general.mp3';
    }
  }
}

/// Extension pour les méthodes utilitaires sur NotificationPriority
extension NotificationPriorityExtension on NotificationPriority {
  /// Couleur associée à la priorité
  String get color {
    switch (this) {
      case NotificationPriority.low:
        return '#6B7280'; // Gris
      case NotificationPriority.normal:
        return '#3B82F6'; // Bleu
      case NotificationPriority.high:
        return '#F59E0B'; // Orange
      case NotificationPriority.urgent:
        return '#EF4444'; // Rouge
    }
  }

  /// Délai d'affichage en secondes
  int get displayDelay {
    switch (this) {
      case NotificationPriority.low:
        return 5;
      case NotificationPriority.normal:
        return 3;
      case NotificationPriority.high:
        return 2;
      case NotificationPriority.urgent:
        return 1;
    }
  }
}