import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de données pour les messages dans l'application KHIDMETI Users
/// Cette classe respecte le principe de responsabilité unique (SRP) du SOLID
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderType; // 'user' ou 'worker'
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final bool isDelivered;
  final bool isRead;
  final bool isEdited;
  final DateTime? editedAt;
  final String? replyToMessageId;
  final Message? replyToMessage;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final String language;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.type,
    required this.createdAt,
    this.deliveredAt,
    this.readAt,
    this.isDelivered = false,
    this.isRead = false,
    this.isEdited = false,
    this.editedAt,
    this.replyToMessageId,
    this.replyToMessage,
    this.attachments = const [],
    this.metadata = const {},
    this.language = 'fr',
  });

  /// Création d'un message à partir des données Firestore
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderType: data['senderType'] ?? 'user',
      senderName: data['senderName'] ?? '',
      senderAvatar: data['senderAvatar'],
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type'] ?? 'text'}',
        orElse: () => MessageType.text,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deliveredAt: data['deliveredAt'] != null ? (data['deliveredAt'] as Timestamp).toDate() : null,
      readAt: data['readAt'] != null ? (data['readAt'] as Timestamp).toDate() : null,
      isDelivered: data['isDelivered'] ?? false,
      isRead: data['isRead'] ?? false,
      isEdited: data['isEdited'] ?? false,
      editedAt: data['editedAt'] != null ? (data['editedAt'] as Timestamp).toDate() : null,
      replyToMessageId: data['replyToMessageId'],
      replyToMessage: null, // Sera rempli séparément si nécessaire
      attachments: List<String>.from(data['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      language: data['language'] ?? 'fr',
    );
  }

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderType': senderType,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'isDelivered': isDelivered,
      'isRead': isRead,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'replyToMessageId': replyToMessageId,
      'attachments': attachments,
      'metadata': metadata,
      'language': language,
    };
  }

  /// Création d'une copie avec modifications
  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderType,
    String? senderName,
    String? senderAvatar,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool? isDelivered,
    bool? isRead,
    bool? isEdited,
    DateTime? editedAt,
    String? replyToMessageId,
    Message? replyToMessage,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    String? language,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      isDelivered: isDelivered ?? this.isDelivered,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      language: language ?? this.language,
    );
  }

  /// Vérification si le message est récent (< 1 minute)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inMinutes < 1;
  }

  /// Vérification si le message est ancien (> 24 heures)
  bool get isOld {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours > 24;
  }

  /// Vérification si le message a des pièces jointes
  bool get hasAttachments => attachments.isNotEmpty;

  /// Vérification si le message est une réponse
  bool get isReply => replyToMessageId != null;

  /// Vérification si le message peut être modifié (< 5 minutes)
  bool get canBeEdited {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inMinutes < 5;
  }

  /// Vérification si le message peut être supprimé (< 1 heure)
  bool get canBeDeleted {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 1;
  }

  /// Temps écoulé depuis la création formaté
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'À l\'instant';
    }
  }

  /// Temps formaté pour l'affichage
  String get timeDisplay {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Date formatée pour l'affichage
  String get dateDisplay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    
    if (messageDate == today) {
      return 'Aujourd\'hui';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Statut formaté pour l'affichage
  String get statusDisplay {
    if (isRead) return 'Lu';
    if (isDelivered) return 'Livré';
    return 'Envoyé';
  }

  /// Type formaté pour l'affichage
  String get typeDisplay {
    switch (type) {
      case MessageType.text:
        return 'Texte';
      case MessageType.image:
        return 'Image';
      case MessageType.video:
        return 'Vidéo';
      case MessageType.audio:
        return 'Audio';
      case MessageType.file:
        return 'Fichier';
      case MessageType.location:
        return 'Localisation';
      case MessageType.contact:
        return 'Contact';
      case MessageType.system:
        return 'Système';
    }
  }

  /// Marquer comme livré
  Message markAsDelivered() {
    return copyWith(
      isDelivered: true,
      deliveredAt: DateTime.now(),
    );
  }

  /// Marquer comme lu
  Message markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// Marquer comme modifié
  Message markAsEdited(String newContent) {
    return copyWith(
      content: newContent,
      isEdited: true,
      editedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, content: $content, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Énumération des types de messages
enum MessageType {
  text,       // Message texte
  image,      // Image
  video,      // Vidéo
  audio,      // Audio
  file,       // Fichier
  location,   // Localisation
  contact,    // Contact
  system,     // Message système
}

/// Extension pour les méthodes utilitaires sur MessageType
extension MessageTypeExtension on MessageType {
  /// Icône associée au type de message
  String get icon {
    switch (this) {
      case MessageType.text:
        return '💬';
      case MessageType.image:
        return '🖼️';
      case MessageType.video:
        return '🎥';
      case MessageType.audio:
        return '🎵';
      case MessageType.file:
        return '📎';
      case MessageType.location:
        return '📍';
      case MessageType.contact:
        return '👤';
      case MessageType.system:
        return '⚙️';
    }
  }

  /// Couleur associée au type de message
  String get color {
    switch (this) {
      case MessageType.text:
        return '#3B82F6'; // Bleu
      case MessageType.image:
        return '#8B5CF6'; // Violet
      case MessageType.video:
        return '#EF4444'; // Rouge
      case MessageType.audio:
        return '#F59E0B'; // Orange
      case MessageType.file:
        return '#10B981'; // Vert
      case MessageType.location:
        return '#06B6D4'; // Cyan
      case MessageType.contact:
        return '#8B5CF6'; // Violet
      case MessageType.system:
        return '#6B7280'; // Gris
    }
  }

  /// Extension de fichier par défaut
  String get defaultExtension {
    switch (this) {
      case MessageType.text:
        return '.txt';
      case MessageType.image:
        return '.jpg';
      case MessageType.video:
        return '.mp4';
      case MessageType.audio:
        return '.mp3';
      case MessageType.file:
        return '.pdf';
      case MessageType.location:
        return '.json';
      case MessageType.contact:
        return '.vcf';
      case MessageType.system:
        return '.json';
    }
  }

  /// Taille maximale en bytes
  int get maxSize {
    switch (this) {
      case MessageType.text:
        return 1000; // 1KB
      case MessageType.image:
        return 10 * 1024 * 1024; // 10MB
      case MessageType.video:
        return 100 * 1024 * 1024; // 100MB
      case MessageType.audio:
        return 25 * 1024 * 1024; // 25MB
      case MessageType.file:
        return 50 * 1024 * 1024; // 50MB
      case MessageType.location:
        return 1000; // 1KB
      case MessageType.contact:
        return 1000; // 1KB
      case MessageType.system:
        return 1000; // 1KB
    }
  }

  /// MIME type associé
  String get mimeType {
    switch (this) {
      case MessageType.text:
        return 'text/plain';
      case MessageType.image:
        return 'image/*';
      case MessageType.video:
        return 'video/*';
      case MessageType.audio:
        return 'audio/*';
      case MessageType.file:
        return 'application/*';
      case MessageType.location:
        return 'application/json';
      case MessageType.contact:
        return 'text/vcard';
      case MessageType.system:
        return 'application/json';
    }
  }
}