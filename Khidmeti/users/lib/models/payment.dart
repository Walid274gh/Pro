import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de données pour les paiements dans l'application KHIDMETI Users
/// Cette classe respecte le principe de responsabilité unique (SRP) du SOLID
class Payment {
  final String id;
  final String workerId;
  final String workerName;
  final String workerEmail;
  final PaymentType type;
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final String description;
  final DateTime createdAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? transactionId;
  final String? receiptUrl;
  final String? failureReason;
  final Map<String, dynamic> metadata;
  final String language;
  final String? subscriptionId;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final String? invoiceNumber;

  const Payment({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.workerEmail,
    required this.type,
    required this.method,
    this.status = PaymentStatus.pending,
    required this.amount,
    this.currency = 'DZD',
    required this.description,
    required this.createdAt,
    this.processedAt,
    this.completedAt,
    this.failedAt,
    this.transactionId,
    this.receiptUrl,
    this.failureReason,
    this.metadata = const {},
    this.language = 'fr',
    this.subscriptionId,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.invoiceNumber,
  });

  /// Création d'un paiement à partir des données Firestore
  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      workerId: data['workerId'] ?? '',
      workerName: data['workerName'] ?? '',
      workerEmail: data['workerEmail'] ?? '',
      type: PaymentType.values.firstWhere(
        (e) => e.toString() == 'PaymentType.${data['type'] ?? 'subscription'}',
        orElse: () => PaymentType.subscription,
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${data['method'] ?? 'barid_mob'}',
        orElse: () => PaymentMethod.barid_mob,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${data['status'] ?? 'pending'}',
        orElse: () => PaymentStatus.pending,
      ),
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'DZD',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      processedAt: data['processedAt'] != null ? (data['processedAt'] as Timestamp).toDate() : null,
      completedAt: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
      failedAt: data['failedAt'] != null ? (data['failedAt'] as Timestamp).toDate() : null,
      transactionId: data['transactionId'],
      receiptUrl: data['receiptUrl'],
      failureReason: data['failureReason'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      language: data['language'] ?? 'fr',
      subscriptionId: data['subscriptionId'],
      subscriptionStartDate: data['subscriptionStartDate'] != null ? (data['subscriptionStartDate'] as Timestamp).toDate() : null,
      subscriptionEndDate: data['subscriptionEndDate'] != null ? (data['subscriptionEndDate'] as Timestamp).toDate() : null,
      invoiceNumber: data['invoiceNumber'],
    );
  }

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'workerId': workerId,
      'workerName': workerName,
      'workerEmail': workerEmail,
      'type': type.toString().split('.').last,
      'method': method.toString().split('.').last,
      'status': status.toString().split('.').last,
      'amount': amount,
      'currency': currency,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'failedAt': failedAt != null ? Timestamp.fromDate(failedAt!) : null,
      'transactionId': transactionId,
      'receiptUrl': receiptUrl,
      'failureReason': failureReason,
      'metadata': metadata,
      'language': language,
      'subscriptionId': subscriptionId,
      'subscriptionStartDate': subscriptionStartDate != null ? Timestamp.fromDate(subscriptionStartDate!) : null,
      'subscriptionEndDate': subscriptionEndDate != null ? Timestamp.fromDate(subscriptionEndDate!) : null,
      'invoiceNumber': invoiceNumber,
    };
  }

  /// Création d'une copie avec modifications
  Payment copyWith({
    String? id,
    String? workerId,
    String? workerName,
    String? workerEmail,
    PaymentType? type,
    PaymentMethod? method,
    PaymentStatus? status,
    double? amount,
    String? currency,
    String? description,
    DateTime? createdAt,
    DateTime? processedAt,
    DateTime? completedAt,
    DateTime? failedAt,
    String? transactionId,
    String? receiptUrl,
    String? failureReason,
    Map<String, dynamic>? metadata,
    String? language,
    String? subscriptionId,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    String? invoiceNumber,
  }) {
    return Payment(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      workerEmail: workerEmail ?? this.workerEmail,
      type: type ?? this.type,
      method: method ?? this.method,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      failedAt: failedAt ?? this.failedAt,
      transactionId: transactionId ?? this.transactionId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
      language: language ?? this.language,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    );
  }

  /// Vérification si le paiement est en attente
  bool get isPending => status == PaymentStatus.pending;

  /// Vérification si le paiement est en cours de traitement
  bool get isProcessing => status == PaymentStatus.processing;

  /// Vérification si le paiement est terminé avec succès
  bool get isCompleted => status == PaymentStatus.completed;

  /// Vérification si le paiement a échoué
  bool get isFailed => status == PaymentStatus.failed;

  /// Vérification si le paiement est annulé
  bool get isCancelled => status == PaymentStatus.cancelled;

  /// Vérification si le paiement est remboursé
  bool get isRefunded => status == PaymentStatus.refunded;

  /// Vérification si le paiement est récent (< 24 heures)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Vérification si le paiement a un reçu
  bool get hasReceipt => receiptUrl != null;

  /// Vérification si le paiement a une raison d'échec
  bool get hasFailureReason => failureReason != null;

  /// Vérification si le paiement est lié à un abonnement
  bool get isSubscriptionPayment => subscriptionId != null;

  /// Vérification si l'abonnement est actif
  bool get isSubscriptionActive {
    if (subscriptionEndDate == null) return false;
    return DateTime.now().isBefore(subscriptionEndDate!);
  }

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

  /// Montant formaté pour l'affichage
  String get amountDisplay {
    if (currency == 'DZD') {
      return '${amount.toStringAsFixed(0)} DZD';
    }
    return '${amount.toStringAsFixed(2)} $currency';
  }

  /// Statut formaté pour l'affichage
  String get statusDisplay {
    switch (status) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.processing:
        return 'En cours';
      case PaymentStatus.completed:
        return 'Terminé';
      case PaymentStatus.failed:
        return 'Échoué';
      case PaymentStatus.cancelled:
        return 'Annulé';
      case PaymentStatus.refunded:
        return 'Remboursé';
    }
  }

  /// Type formaté pour l'affichage
  String get typeDisplay {
    switch (type) {
      case PaymentType.subscription:
        return 'Abonnement';
      case PaymentType.renewal:
        return 'Renouvellement';
      case PaymentType.upgrade:
        return 'Mise à niveau';
      case PaymentType.oneTime:
        return 'Paiement unique';
      case PaymentType.refund:
        return 'Remboursement';
    }
  }

  /// Méthode formatée pour l'affichage
  String get methodDisplay {
    switch (method) {
      case PaymentMethod.barid_mob:
        return 'Barid Mob';
      case PaymentMethod.credit_card:
        return 'Carte bancaire';
      case PaymentMethod.post_office:
        return 'Bureau de poste';
      case PaymentMethod.bank_transfer:
        return 'Virement bancaire';
      case PaymentMethod.cash:
        return 'Espèces';
    }
  }

  /// Marquer comme en cours de traitement
  Payment markAsProcessing() {
    return copyWith(
      status: PaymentStatus.processing,
      processedAt: DateTime.now(),
    );
  }

  /// Marquer comme terminé
  Payment markAsCompleted(String transactionId) {
    return copyWith(
      status: PaymentStatus.completed,
      completedAt: DateTime.now(),
      transactionId: transactionId,
    );
  }

  /// Marquer comme échoué
  Payment markAsFailed(String reason) {
    return copyWith(
      status: PaymentStatus.failed,
      failedAt: DateTime.now(),
      failureReason: reason,
    );
  }

  /// Marquer comme annulé
  Payment markAsCancelled() {
    return copyWith(
      status: PaymentStatus.cancelled,
    );
  }

  /// Marquer comme remboursé
  Payment markAsRefunded() {
    return copyWith(
      status: PaymentStatus.refunded,
    );
  }

  @override
  String toString() {
    return 'Payment(id: $id, amount: $amountDisplay, status: $status, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Énumération des types de paiement
enum PaymentType {
  subscription,  // Abonnement
  renewal,       // Renouvellement
  upgrade,       // Mise à niveau
  oneTime,       // Paiement unique
  refund,        // Remboursement
}

/// Énumération des méthodes de paiement
enum PaymentMethod {
  barid_mob,     // Barid Mob
  credit_card,   // Carte bancaire
  post_office,   // Bureau de poste
  bank_transfer, // Virement bancaire
  cash,          // Espèces
}

/// Énumération des statuts de paiement
enum PaymentStatus {
  pending,     // En attente
  processing,  // En cours de traitement
  completed,   // Terminé avec succès
  failed,      // Échoué
  cancelled,   // Annulé
  refunded,    // Remboursé
}

/// Extension pour les méthodes utilitaires sur PaymentType
extension PaymentTypeExtension on PaymentType {
  /// Icône associée au type de paiement
  String get icon {
    switch (this) {
      case PaymentType.subscription:
        return '📅';
      case PaymentType.renewal:
        return '🔄';
      case PaymentType.upgrade:
        return '⬆️';
      case PaymentType.oneTime:
        return '💳';
      case PaymentType.refund:
        return '↩️';
    }
  }

  /// Couleur associée au type de paiement
  String get color {
    switch (this) {
      case PaymentType.subscription:
        return '#3B82F6'; // Bleu
      case PaymentType.renewal:
        return '#10B981'; // Vert
      case PaymentType.upgrade:
        return '#8B5CF6'; // Violet
      case PaymentType.oneTime:
        return '#F59E0B'; // Orange
      case PaymentType.refund:
        return '#EF4444'; // Rouge
    }
  }

  /// Description du type de paiement
  String get description {
    switch (this) {
      case PaymentType.subscription:
        return 'Paiement d\'abonnement mensuel ou annuel';
      case PaymentType.renewal:
        return 'Renouvellement automatique d\'abonnement';
      case PaymentType.upgrade:
        return 'Mise à niveau du plan d\'abonnement';
      case PaymentType.oneTime:
        return 'Paiement unique pour service spécial';
      case PaymentType.refund:
        return 'Remboursement de paiement précédent';
    }
  }
}

/// Extension pour les méthodes utilitaires sur PaymentMethod
extension PaymentMethodExtension on PaymentMethod {
  /// Icône associée à la méthode de paiement
  String get icon {
    switch (this) {
      case PaymentMethod.barid_mob:
        return '📱';
      case PaymentMethod.credit_card:
        return '💳';
      case PaymentMethod.post_office:
        return '🏣';
      case PaymentMethod.bank_transfer:
        return '🏦';
      case PaymentMethod.cash:
        return '💵';
    }
  }

  /// Couleur associée à la méthode de paiement
  String get color {
    switch (this) {
      case PaymentMethod.barid_mob:
        return '#10B981'; // Vert
      case PaymentMethod.credit_card:
        return '#3B82F6'; // Bleu
      case PaymentMethod.post_office:
        return '#F59E0B'; // Orange
      case PaymentMethod.bank_transfer:
        return '#8B5CF6'; // Violet
      case PaymentMethod.cash:
        return '#6B7280'; // Gris
    }
  }

  /// Frais de transaction en pourcentage
  double get transactionFee {
    switch (this) {
      case PaymentMethod.barid_mob:
        return 0.5; // 0.5%
      case PaymentMethod.credit_card:
        return 2.5; // 2.5%
      case PaymentMethod.post_office:
        return 0.0; // 0%
      case PaymentMethod.bank_transfer:
        return 1.0; // 1%
      case PaymentMethod.cash:
        return 0.0; // 0%
    }
  }

  /// Délai de traitement en heures
  int get processingTime {
    switch (this) {
      case PaymentMethod.barid_mob:
        return 1; // 1 heure
      case PaymentMethod.credit_card:
        return 2; // 2 heures
      case PaymentMethod.post_office:
        return 24; // 24 heures
      case PaymentMethod.bank_transfer:
        return 48; // 48 heures
      case PaymentMethod.cash:
        return 0; // Immédiat
    }
  }
}

/// Extension pour les méthodes utilitaires sur PaymentStatus
extension PaymentStatusExtension on PaymentStatus {
  /// Icône associée au statut
  String get icon {
    switch (this) {
      case PaymentStatus.pending:
        return '⏳';
      case PaymentStatus.processing:
        return '🔄';
      case PaymentStatus.completed:
        return '✅';
      case PaymentStatus.failed:
        return '❌';
      case PaymentStatus.cancelled:
        return '🚫';
      case PaymentStatus.refunded:
        return '↩️';
    }
  }

  /// Couleur associée au statut
  String get color {
    switch (this) {
      case PaymentStatus.pending:
        return '#F59E0B'; // Orange
      case PaymentStatus.processing:
        return '#3B82F6'; // Bleu
      case PaymentStatus.completed:
        return '#10B981'; // Vert
      case PaymentStatus.failed:
        return '#EF4444'; // Rouge
      case PaymentStatus.cancelled:
        return '#6B7280'; // Gris
      case PaymentStatus.refunded:
        return '#8B5CF6'; // Violet
    }
  }

  /// Description du statut
  String get description {
    switch (this) {
      case PaymentStatus.pending:
        return 'Paiement en attente de traitement';
      case PaymentStatus.processing:
        return 'Paiement en cours de traitement';
      case PaymentStatus.completed:
        return 'Paiement terminé avec succès';
      case PaymentStatus.failed:
        return 'Paiement échoué';
      case PaymentStatus.cancelled:
        return 'Paiement annulé';
      case PaymentStatus.refunded:
        return 'Paiement remboursé';
    }
  }
}