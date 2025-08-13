import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,           // Message texte
  image,          // Message image
  video,          // Message vidéo
  audio,          // Message audio
  file,           // Fichier
  location,       // Localisation
  jobOffer,       // Offre de travail
  jobAcceptance,  // Acceptation de travail
  jobRejection,   // Refus de travail
  payment,        // Paiement
  system          // Message système
}

enum MessageStatus {
  sent,           // Envoyé
  delivered,      // Livré
  read,           // Lu
  failed          // Échoué
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderImageUrl;
  final String senderType; // 'user' ou 'worker'
  final String receiverId;
  final String receiverName;
  final String? receiverImageUrl;
  final String receiverType; // 'user' ou 'worker'
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final String? mediaThumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final String? fileType;
  final LatLng? location;
  final String? locationAddress;
  final Map<String, dynamic> metadata;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? replyToMessageId;
  final Message? replyToMessage;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.senderType,
    required this.receiverId,
    required this.receiverName,
    this.receiverImageUrl,
    required this.receiverType,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.mediaThumbnailUrl,
    this.fileName,
    this.fileSize,
    this.fileType,
    this.location,
    this.locationAddress,
    this.metadata = const {},
    this.status = MessageStatus.sent,
    required this.createdAt,
    this.deliveredAt,
    this.readAt,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.replyToMessageId,
    this.replyToMessage,
  });

  // Factory constructor pour créer un Message depuis Firestore
  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    LatLng? location;
    if (data['location'] != null) {
      GeoPoint geoPoint = data['location'] as GeoPoint;
      location = LatLng(geoPoint.latitude, geoPoint.longitude);
    }

    return Message(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderImageUrl: data['senderImageUrl'],
      senderType: data['senderType'] ?? 'user',
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'] ?? '',
      receiverImageUrl: data['receiverImageUrl'],
      receiverType: data['receiverType'] ?? 'worker',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.text,
      ),
      content: data['content'] ?? '',
      mediaUrl: data['mediaUrl'],
      mediaThumbnailUrl: data['mediaThumbnailUrl'],
      fileName: data['fileName'],
      fileSize: data['fileSize'],
      fileType: data['fileType'],
      location: location,
      locationAddress: data['locationAddress'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${data['status']}',
        orElse: () => MessageStatus.sent,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deliveredAt: data['deliveredAt'] != null 
          ? (data['deliveredAt'] as Timestamp).toDate() 
          : null,
      readAt: data['readAt'] != null 
          ? (data['readAt'] as Timestamp).toDate() 
          : null,
      isEdited: data['isEdited'] ?? false,
      editedAt: data['editedAt'] != null 
          ? (data['editedAt'] as Timestamp).toDate() 
          : null,
      isDeleted: data['isDeleted'] ?? false,
      deletedAt: data['deletedAt'] != null 
          ? (data['deletedAt'] as Timestamp).toDate() 
          : null,
      replyToMessageId: data['replyToMessageId'],
    );
  }

  // Méthode pour convertir Message en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'senderType': senderType,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverImageUrl': receiverImageUrl,
      'receiverType': receiverType,
      'type': type.toString().split('.').last,
      'content': content,
      'mediaUrl': mediaUrl,
      'mediaThumbnailUrl': mediaThumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
      'locationAddress': locationAddress,
      'metadata': metadata,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'replyToMessageId': replyToMessageId,
    };

    if (location != null) {
      data['location'] = GeoPoint(location!.latitude, location!.longitude);
    }

    if (deliveredAt != null) {
      data['deliveredAt'] = Timestamp.fromDate(deliveredAt!);
    }

    if (readAt != null) {
      data['readAt'] = Timestamp.fromDate(readAt!);
    }

    if (editedAt != null) {
      data['editedAt'] = Timestamp.fromDate(editedAt!);
    }

    if (deletedAt != null) {
      data['deletedAt'] = Timestamp.fromDate(deletedAt!);
    }

    return data;
  }

  // Méthode pour créer une copie modifiée
  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderImageUrl,
    String? senderType,
    String? receiverId,
    String? receiverName,
    String? receiverImageUrl,
    String? receiverType,
    MessageType? type,
    String? content,
    String? mediaUrl,
    String? mediaThumbnailUrl,
    String? fileName,
    int? fileSize,
    String? fileType,
    LatLng? location,
    String? locationAddress,
    Map<String, dynamic>? metadata,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? replyToMessageId,
    Message? replyToMessage,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
      senderType: senderType ?? this.senderType,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverImageUrl: receiverImageUrl ?? this.receiverImageUrl,
      receiverType: receiverType ?? this.receiverType,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaThumbnailUrl: mediaThumbnailUrl ?? this.mediaThumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      location: location ?? this.location,
      locationAddress: locationAddress ?? this.locationAddress,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
    );
  }

  // Méthodes de gestion du statut
  Message markAsDelivered() {
    return copyWith(
      status: MessageStatus.delivered,
      deliveredAt: DateTime.now(),
    );
  }

  Message markAsRead() {
    return copyWith(
      status: MessageStatus.read,
      readAt: DateTime.now(),
    );
  }

  Message markAsFailed() {
    return copyWith(status: MessageStatus.failed);
  }

  Message editMessage(String newContent) {
    return copyWith(
      content: newContent,
      isEdited: true,
      editedAt: DateTime.now(),
    );
  }

  Message deleteMessage() {
    return copyWith(
      isDeleted: true,
      deletedAt: DateTime.now(),
    );
  }

  Message addMetadata(String key, dynamic value) {
    Map<String, dynamic> newMetadata = Map.from(metadata);
    newMetadata[key] = value;
    return copyWith(metadata: newMetadata);
  }

  Message removeMetadata(String key) {
    Map<String, dynamic> newMetadata = Map.from(metadata);
    newMetadata.remove(key);
    return copyWith(metadata: newMetadata);
  }

  // Getters utiles
  bool get isFromUser => senderType == 'user';
  
  bool get isFromWorker => senderType == 'worker';
  
  bool get isTextMessage => type == MessageType.text;
  
  bool get isMediaMessage => 
      type == MessageType.image || 
      type == MessageType.video || 
      type == MessageType.audio;
  
  bool get isFileMessage => type == MessageType.file;
  
  bool get isLocationMessage => type == MessageType.location;
  
  bool get isJobRelated => 
      type == MessageType.jobOffer || 
      type == MessageType.jobAcceptance || 
      type == MessageType.jobRejection;
  
  bool get isSystemMessage => type == MessageType.system;
  
  bool get isUnread => status != MessageStatus.read;
  
  bool get isDelivered => status == MessageStatus.delivered || status == MessageStatus.read;
  
  bool get hasReply => replyToMessageId != null;
  
  bool get canBeEdited => isTextMessage && !isDeleted && !isJobRelated;
  
  bool get canBeDeleted => !isJobRelated; // Les messages de travail ne peuvent pas être supprimés
  
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
      case MessageType.jobOffer:
        return 'Offre de travail';
      case MessageType.jobAcceptance:
        return 'Acceptation';
      case MessageType.jobRejection:
        return 'Refus';
      case MessageType.payment:
        return 'Paiement';
      case MessageType.system:
        return 'Système';
    }
  }

  String get statusDisplay {
    switch (status) {
      case MessageStatus.sent:
        return 'Envoyé';
      case MessageStatus.delivered:
        return 'Livré';
      case MessageStatus.read:
        return 'Lu';
      case MessageStatus.failed:
        return 'Échoué';
    }
  }

  // Méthode pour obtenir l'âge du message
  Duration get age => DateTime.now().difference(createdAt);
  
  // Méthode pour vérifier si le message est récent (moins de 1h)
  bool get isRecent => age.inMinutes < 60;
  
  // Méthode pour vérifier si le message est ancien (plus de 24h)
  bool get isOld => age.inHours > 24;

  // Méthode pour formater la taille du fichier
  String? get formattedFileSize {
    if (fileSize == null) return null;
    
    if (fileSize! < 1024) {
      return '${fileSize!} B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize! < 1024 * 1024 * 1024) {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  @override
  String toString() {
    return 'Message(id: $id, type: $type, content: $content, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}