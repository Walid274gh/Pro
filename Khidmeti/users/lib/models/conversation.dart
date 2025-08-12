import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';

/// Modèle de données pour les conversations dans l'application KHIDMETI Users
/// Cette classe respecte le principe de responsabilité unique (SRP) du SOLID
class Conversation {
  final String id;
  final String participant1Id;
  final String participant1Type; // 'user' ou 'worker'
  final String participant1Name;
  final String? participant1Avatar;
  final String participant2Id;
  final String participant2Type; // 'user' ou 'worker'
  final String participant2Name;
  final String? participant2Avatar;
  final String? lastMessageId;
  final Message? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount1;
  final int unreadCount2;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? jobId;
  final ConversationStatus status;
  final Map<String, dynamic> metadata;
  final String language;

  const Conversation({
    required this.id,
    required this.participant1Id,
    required this.participant1Type,
    required this.participant1Name,
    this.participant1Avatar,
    required this.participant2Id,
    required this.participant2Type,
    required this.participant2Name,
    this.participant2Avatar,
    this.lastMessageId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount1 = 0,
    this.unreadCount2 = 0,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.jobId,
    this.status = ConversationStatus.active,
    this.metadata = const {},
    this.language = 'fr',
  });

  /// Création d'une conversation à partir des données Firestore
  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      participant1Id: data['participant1Id'] ?? '',
      participant1Type: data['participant1Type'] ?? 'user',
      participant1Name: data['participant1Name'] ?? '',
      participant1Avatar: data['participant1Avatar'],
      participant2Id: data['participant2Id'] ?? '',
      participant2Type: data['participant2Type'] ?? 'user',
      participant2Name: data['participant2Name'] ?? '',
      participant2Avatar: data['participant2Avatar'],
      lastMessageId: data['lastMessageId'],
      lastMessage: null, // Sera rempli séparément si nécessaire
      lastMessageAt: data['lastMessageAt'] != null ? (data['lastMessageAt'] as Timestamp).toDate() : null,
      unreadCount1: data['unreadCount1'] ?? 0,
      unreadCount2: data['unreadCount2'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      isActive: data['isActive'] ?? true,
      jobId: data['jobId'],
      status: ConversationStatus.values.firstWhere(
        (e) => e.toString() == 'ConversationStatus.${data['status'] ?? 'active'}',
        orElse: () => ConversationStatus.active,
      ),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      language: data['language'] ?? 'fr',
    );
  }

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'participant1Id': participant1Id,
      'participant1Type': participant1Type,
      'participant1Name': participant1Name,
      'participant1Avatar': participant1Avatar,
      'participant2Id': participant2Id,
      'participant2Type': participant2Type,
      'participant2Name': participant2Name,
      'participant2Avatar': participant2Avatar,
      'lastMessageId': lastMessageId,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'unreadCount1': unreadCount1,
      'unreadCount2': unreadCount2,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'jobId': jobId,
      'status': status.toString().split('.').last,
      'metadata': metadata,
      'language': language,
    };
  }

  /// Création d'une copie avec modifications
  Conversation copyWith({
    String? id,
    String? participant1Id,
    String? participant1Type,
    String? participant1Name,
    String? participant1Avatar,
    String? participant2Id,
    String? participant2Type,
    String? participant2Name,
    String? participant2Avatar,
    String? lastMessageId,
    Message? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount1,
    int? unreadCount2,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? jobId,
    ConversationStatus? status,
    Map<String, dynamic>? metadata,
    String? language,
  }) {
    return Conversation(
      id: id ?? this.id,
      participant1Id: participant1Id ?? this.participant1Id,
      participant1Type: participant1Type ?? this.participant1Type,
      participant1Name: participant1Name ?? this.participant1Name,
      participant1Avatar: participant1Avatar ?? this.participant1Avatar,
      participant2Id: participant2Id ?? this.participant2Id,
      participant2Type: participant2Type ?? this.participant2Type,
      participant2Name: participant2Name ?? this.participant2Name,
      participant2Avatar: participant2Avatar ?? this.participant2Avatar,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount1: unreadCount1 ?? this.unreadCount1,
      unreadCount2: unreadCount2 ?? this.unreadCount2,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      language: language ?? this.language,
    );
  }

  /// Vérification si la conversation a un dernier message
  bool get hasLastMessage => lastMessage != null && lastMessageAt != null;

  /// Vérification si la conversation est récente (< 1 heure)
  bool get isRecent {
    if (lastMessageAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt!);
    return difference.inHours < 1;
  }

  /// Vérification si la conversation est ancienne (> 7 jours)
  bool get isOld {
    if (lastMessageAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt!);
    return difference.inDays > 7;
  }

  /// Vérification si la conversation a des messages non lus
  bool get hasUnreadMessages => unreadCount1 > 0 || unreadCount2 > 0;

  /// Vérification si la conversation est liée à un job
  bool get isJobRelated => jobId != null;

  /// Vérification si la conversation est active
  bool get isConversationActive => isActive && status == ConversationStatus.active;

  /// Temps écoulé depuis le dernier message formaté
  String get lastMessageTimeAgo {
    if (lastMessageAt == null) return 'Aucun message';
    
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt!);
    
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

  /// Date du dernier message formatée
  String get lastMessageDateDisplay {
    if (lastMessageAt == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(lastMessageAt!.year, lastMessageAt!.month, lastMessageAt!.day);
    
    if (messageDate == today) {
      return 'Aujourd\'hui';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else {
      return '${lastMessageAt!.day}/${lastMessageAt!.month}/${lastMessageAt!.year}';
    }
  }

  /// Statut formaté pour l'affichage
  String get statusDisplay {
    switch (status) {
      case ConversationStatus.active:
        return 'Active';
      case ConversationStatus.archived:
        return 'Archivée';
      case ConversationStatus.blocked:
        return 'Bloquée';
      case ConversationStatus.pending:
        return 'En attente';
    }
  }

  /// Type de conversation formaté
  String get conversationTypeDisplay {
    if (participant1Type == 'user' && participant2Type == 'worker') {
      return 'Utilisateur ↔ Travailleur';
    } else if (participant1Type == 'worker' && participant2Type == 'user') {
      return 'Travailleur ↔ Utilisateur';
    } else if (participant1Type == 'user' && participant2Type == 'user') {
      return 'Utilisateur ↔ Utilisateur';
    } else {
      return 'Travailleur ↔ Travailleur';
    }
  }

  /// Obtenir le nom de l'autre participant
  String getOtherParticipantName(String currentUserId) {
    if (participant1Id == currentUserId) {
      return participant2Name;
    } else if (participant2Id == currentUserId) {
      return participant1Name;
    }
    return 'Inconnu';
  }

  /// Obtenir l'avatar de l'autre participant
  String? getOtherParticipantAvatar(String currentUserId) {
    if (participant1Id == currentUserId) {
      return participant2Avatar;
    } else if (participant2Id == currentUserId) {
      return participant1Avatar;
    }
    return null;
  }

  /// Obtenir le type de l'autre participant
  String getOtherParticipantType(String currentUserId) {
    if (participant1Id == currentUserId) {
      return participant2Type;
    } else if (participant2Id == currentUserId) {
      return participant1Type;
    }
    return 'unknown';
  }

  /// Obtenir le nombre de messages non lus pour l'utilisateur actuel
  int getUnreadCountForUser(String currentUserId) {
    if (participant1Id == currentUserId) {
      return unreadCount1;
    } else if (participant2Id == currentUserId) {
      return unreadCount2;
    }
    return 0;
  }

  /// Marquer comme mise à jour
  Conversation markAsUpdated() {
    return copyWith(
      updatedAt: DateTime.now(),
    );
  }

  /// Mettre à jour le dernier message
  Conversation updateLastMessage(Message message) {
    return copyWith(
      lastMessageId: message.id,
      lastMessage: message,
      lastMessageAt: message.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Incrémenter le compteur de messages non lus
  Conversation incrementUnreadCount(String participantId) {
    if (participantId == participant1Id) {
      return copyWith(unreadCount1: unreadCount1 + 1);
    } else if (participantId == participant2Id) {
      return copyWith(unreadCount2: unreadCount2 + 1);
    }
    return this;
  }

  /// Réinitialiser le compteur de messages non lus
  Conversation resetUnreadCount(String participantId) {
    if (participantId == participant1Id) {
      return copyWith(unreadCount1: 0);
    } else if (participantId == participant2Id) {
      return copyWith(unreadCount2: 0);
    }
    return this;
  }

  @override
  String toString() {
    return 'Conversation(id: $id, participants: $participant1Name ↔ $participant2Name, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Énumération des statuts de conversation
enum ConversationStatus {
  active,     // Conversation active
  archived,   // Conversation archivée
  blocked,    // Conversation bloquée
  pending,    // Conversation en attente
}

/// Extension pour les méthodes utilitaires sur ConversationStatus
extension ConversationStatusExtension on ConversationStatus {
  /// Icône associée au statut
  String get icon {
    switch (this) {
      case ConversationStatus.active:
        return '💬';
      case ConversationStatus.archived:
        return '📁';
      case ConversationStatus.blocked:
        return '🚫';
      case ConversationStatus.pending:
        return '⏳';
    }
  }

  /// Couleur associée au statut
  String get color {
    switch (this) {
      case ConversationStatus.active:
        return '#10B981'; // Vert
      case ConversationStatus.archived:
        return '#6B7280'; // Gris
      case ConversationStatus.blocked:
        return '#EF4444'; // Rouge
      case ConversationStatus.pending:
        return '#F59E0B'; // Orange
    }
  }

  /// Description du statut
  String get description {
    switch (this) {
      case ConversationStatus.active:
        return 'Conversation active et accessible';
      case ConversationStatus.archived:
        return 'Conversation archivée et masquée';
      case ConversationStatus.blocked:
        return 'Conversation bloquée par un participant';
      case ConversationStatus.pending:
        return 'Conversation en attente d\'approbation';
    }
  }
}