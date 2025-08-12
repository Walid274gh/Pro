import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}

class RequestModel {
  final String id;
  final String userId;
  final String workerId;
  final String serviceType;
  final String description;
  final RequestStatus status;
  final double price;
  final DateTime scheduledDate;
  final GeoPoint location;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  RequestModel({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.serviceType,
    required this.description,
    required this.status,
    required this.price,
    required this.scheduledDate,
    required this.location,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'workerId': workerId,
      'serviceType': serviceType,
      'description': description,
      'status': status.toString(),
      'price': price,
      'scheduledDate': scheduledDate,
      'location': location,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      workerId: map['workerId'] ?? '',
      serviceType: map['serviceType'] ?? '',
      description: map['description'] ?? '',
      status: RequestStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => RequestStatus.pending,
      ),
      price: (map['price'] ?? 0.0).toDouble(),
      scheduledDate: (map['scheduledDate'] as Timestamp).toDate(),
      location: map['location'] ?? const GeoPoint(0, 0),
      address: map['address'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  RequestModel copyWith({
    String? id,
    String? userId,
    String? workerId,
    String? serviceType,
    String? description,
    RequestStatus? status,
    double? price,
    DateTime? scheduledDate,
    GeoPoint? location,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workerId: workerId ?? this.workerId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      status: status ?? this.status,
      price: price ?? this.price,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      location: location ?? this.location,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RequestModel(id: $id, userId: $userId, workerId: $workerId, serviceType: $serviceType, description: $description, status: $status, price: $price, scheduledDate: $scheduledDate, location: $location, address: $address, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RequestModel &&
        other.id == id &&
        other.userId == userId &&
        other.workerId == workerId &&
        other.serviceType == serviceType &&
        other.description == description &&
        other.status == status &&
        other.price == price &&
        other.scheduledDate == scheduledDate &&
        other.location == location &&
        other.address == address &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        workerId.hashCode ^
        serviceType.hashCode ^
        description.hashCode ^
        status.hashCode ^
        price.hashCode ^
        scheduledDate.hashCode ^
        location.hashCode ^
        address.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}