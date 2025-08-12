import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

// ===== PALETTE DE COULEURS PAYTONE ONE =====
const Color kPrimaryYellow = Color(0xFFFCDC73);
const Color kPrimaryRed = Color(0xFFE76268);
const Color kPrimaryDark = Color(0xFF193948);
const Color kPrimaryTeal = Color(0xFF4FADCD);
const Color kBackgroundColor = Color(0xFFFEF7E6);
const Color kSurfaceColor = Color(0xFFFFFFFF);
const Color kTextColor = Color(0xFF193948);
const Color kSubtitleColor = Color(0xFF6B7280);
const Color kSuccessColor = Color(0xFF28A745);
const Color kErrorColor = Color(0xFFDC3545);
const Color kButton3DLight = Color(0xFFFFFFFF);
const Color kButton3DShadow = Color(0xFFD1D5DB);
const Color kButtonGradient1 = Color(0xFF193948);
const Color kButtonGradient2 = Color(0xFF4FADCD);

// ===== TYPOGRAPHIE PAYTONE ONE =====
final TextStyle kHeadingStyle = GoogleFonts.paytoneOne(
  fontSize: 28,
  fontWeight: FontWeight.w400,
  color: kTextColor,
);

final TextStyle kSubheadingStyle = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kTextColor,
);

final TextStyle kBodyStyle = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: kTextColor,
);

// ===== MODÈLES DE DONNÉES =====

// Modèle Worker avec style professionnel
class WorkerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final List<String> skills;
  final double rating;
  final int completedJobs;
  final double hourlyRate;
  final bool isAvailable;
  final GeoPoint location;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.skills,
    required this.rating,
    required this.completedJobs,
    required this.hourlyRate,
    required this.isAvailable,
    required this.location,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'skills': skills,
      'rating': rating,
      'completedJobs': completedJobs,
      'hourlyRate': hourlyRate,
      'isAvailable': isAvailable,
      'location': location,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    return WorkerModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      completedJobs: map['completedJobs'] ?? 0,
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      isAvailable: map['isAvailable'] ?? false,
      location: map['location'] ?? const GeoPoint(0, 0),
      address: map['address'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}

// Modèle Request pour les demandes de travail
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
}

// Statuts des demandes
enum RequestStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}

// Modèle pour les statistiques du dashboard
class DashboardStats {
  final int totalRequests;
  final int completedJobs;
  final double totalEarnings;
  final double averageRating;
  final int activeRequests;

  DashboardStats({
    required this.totalRequests,
    required this.completedJobs,
    required this.totalEarnings,
    required this.averageRating,
    required this.activeRequests,
  });
}

// Modèle pour les paiements
class PaymentModel {
  final String id;
  final String requestId;
  final String workerId;
  final String userId;
  final double amount;
  final PaymentStatus status;
  final PaymentMethod method;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.requestId,
    required this.workerId,
    required this.userId,
    required this.amount,
    required this.status,
    required this.method,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'workerId': workerId,
      'userId': userId,
      'amount': amount,
      'status': status.toString(),
      'method': method.toString(),
      'createdAt': createdAt,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      requestId: map['requestId'] ?? '',
      workerId: map['workerId'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => PaymentStatus.pending,
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == map['method'],
        orElse: () => PaymentMethod.cash,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

enum PaymentMethod {
  cash,
  card,
  mobileMoney,
}

// ===== SERVICES SOLID =====

// Interface d'authentification (SRP)
abstract class WorkerAuthenticationService {
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();
  Stream<User?> get authStateChanges;
}

// Interface de base de données (SRP)
abstract class WorkerDatabaseService {
  Future<void> createWorker(WorkerModel worker);
  Future<WorkerModel?> getWorker(String workerId);
  Future<void> updateWorker(WorkerModel worker);
  Future<List<RequestModel>> getWorkerRequests(String workerId);
  Future<void> updateRequestStatus(String requestId, RequestStatus status);
  Future<DashboardStats> getWorkerStats(String workerId);
}

// Interface de stockage (SRP)
abstract class WorkerStorageService {
  Future<String> uploadWorkerAvatar(String workerId, File file);
  Future<void> deleteWorkerAvatar(String workerId);
}

// Interface de géolocalisation (SRP)
abstract class WorkerLocationService {
  Future<Position> getCurrentLocation();
  Future<String> getAddressFromCoordinates(double lat, double lng);
  Future<void> updateWorkerLocation(String workerId, GeoPoint location);
}

// Interface de notifications (SRP)
abstract class WorkerNotificationService {
  Future<void> sendNotification(String userId, String title, String body);
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
}

// Interface de paiements (SRP)
abstract class PaymentProcessor {
  Future<bool> processPayment(PaymentModel payment);
  Future<List<PaymentModel>> getWorkerPayments(String workerId);
}

// Implémentations concrètes

class WorkerAuthService implements WorkerAuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Erreur de connexion: $e');
      return null;
    }
  }

  @override
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Erreur de création de compte: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

class WorkerFirestoreService implements WorkerDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createWorker(WorkerModel worker) async {
    await _firestore.collection('workers').doc(worker.id).set(worker.toMap());
  }

  @override
  Future<WorkerModel?> getWorker(String workerId) async {
    final doc = await _firestore.collection('workers').doc(workerId).get();
    if (doc.exists) {
      return WorkerModel.fromMap(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> updateWorker(WorkerModel worker) async {
    await _firestore.collection('workers').doc(worker.id).update(worker.toMap());
  }

  @override
  Future<List<RequestModel>> getWorkerRequests(String workerId) async {
    final querySnapshot = await _firestore
        .collection('requests')
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => RequestModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> updateRequestStatus(String requestId, RequestStatus status) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': status.toString(),
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<DashboardStats> getWorkerStats(String workerId) async {
    final requests = await getWorkerRequests(workerId);
    final completedJobs = requests.where((r) => r.status == RequestStatus.completed).length;
    final totalEarnings = requests
        .where((r) => r.status == RequestStatus.completed)
        .fold(0.0, (sum, r) => sum + r.price);
    final activeRequests = requests.where((r) => r.status == RequestStatus.inProgress).length;
    
    return DashboardStats(
      totalRequests: requests.length,
      completedJobs: completedJobs,
      totalEarnings: totalEarnings,
      averageRating: 4.5, // À calculer depuis les avis
      activeRequests: activeRequests,
    );
  }
}

class WorkerStorageServiceImpl implements WorkerStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String> uploadWorkerAvatar(String workerId, File file) async {
    final ref = _storage.ref().child('workers/$workerId/avatar.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  @override
  Future<void> deleteWorkerAvatar(String workerId) async {
    final ref = _storage.ref().child('workers/$workerId/avatar.jpg');
    await ref.delete();
  }
}

class WorkerLocationServiceImpl implements WorkerLocationService {
  @override
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Les services de localisation sont désactivés.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissions de localisation refusées.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    List<Placemark> placemarks = await geocodingFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      return '${place.street}, ${place.locality}, ${place.country}';
    }
    return 'Adresse non trouvée';
  }

  @override
  Future<void> updateWorkerLocation(String workerId, GeoPoint location) async {
    await FirebaseFirestore.instance
        .collection('workers')
        .doc(workerId)
        .update({
      'location': location,
      'updatedAt': DateTime.now(),
    });
  }
}

class WorkerNotificationServiceImpl implements WorkerNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  Future<void> sendNotification(String userId, String title, String body) async {
    // Implémentation pour envoyer des notifications push
    print('Notification envoyée à $userId: $title - $body');
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}

class BaridiMobPaymentProcessor implements PaymentProcessor {
  @override
  Future<bool> processPayment(PaymentModel payment) async {
    // Simulation de traitement de paiement Baridi Mob
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  @override
  Future<List<PaymentModel>> getWorkerPayments(String workerId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => PaymentModel.fromMap(doc.data()))
        .toList();
  }
}

class BankCardPaymentProcessor implements PaymentProcessor {
  @override
  Future<bool> processPayment(PaymentModel payment) async {
    // Simulation de traitement de paiement par carte bancaire
    await Future.delayed(Duration(seconds: 3));
    return true;
  }

  @override
  Future<List<PaymentModel>> getWorkerPayments(String workerId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => PaymentModel.fromMap(doc.data()))
        .toList();
  }
}

// ===== WIDGETS RÉUTILISABLES =====

// Widget pour les cartes du dashboard professionnel
class ProfessionalDashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ProfessionalDashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kPrimaryDark.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios, color: kSubtitleColor, size: 16),
              ],
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: kHeadingStyle.copyWith(fontSize: 24),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: kBodyStyle.copyWith(color: kSubtitleColor),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour les boutons bubble avec style professionnel
class ProfessionalBubbleButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const ProfessionalBubbleButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
  }) : super(key: key);

  @override
  _ProfessionalBubbleButtonState createState() => _ProfessionalBubbleButtonState();
}

class _ProfessionalBubbleButtonState extends State<ProfessionalBubbleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.backgroundColor ?? kButtonGradient1,
                    widget.backgroundColor ?? kButtonGradient2,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: kButton3DShadow,
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: kButton3DLight,
                    offset: Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.textColor ?? Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: kSubheadingStyle.copyWith(
                      color: widget.textColor ?? Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget pour les headers modernes sans AppBar
class ProfessionalHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const ProfessionalHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryDark.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (leading != null)
            leading!
          else if (onBackPressed != null)
            GestureDetector(
              onTap: onBackPressed,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_back, color: kPrimaryDark),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: kHeadingStyle.copyWith(fontSize: 24),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: kBodyStyle.copyWith(color: kSubtitleColor),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

// Widget pour les cartes de demande
class RequestCard extends StatelessWidget {
  final RequestModel request;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;

  const RequestCard({
    Key? key,
    required this.request,
    this.onAccept,
    this.onReject,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryDark.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(request.status),
                  style: kBodyStyle.copyWith(
                    color: _getStatusColor(request.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              Text(
                '${request.price.toStringAsFixed(2)} DA',
                style: kSubheadingStyle.copyWith(color: kSuccessColor),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            request.serviceType,
            style: kSubheadingStyle,
          ),
          SizedBox(height: 8),
          Text(
            request.description,
            style: kBodyStyle.copyWith(color: kSubtitleColor),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, color: kPrimaryTeal, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.address,
                  style: kBodyStyle.copyWith(color: kSubtitleColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (request.status == RequestStatus.pending) ...[
            Row(
              children: [
                Expanded(
                  child: ProfessionalBubbleButton(
                    text: 'Accepter',
                    onPressed: onAccept ?? () {},
                    backgroundColor: kSuccessColor,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ProfessionalBubbleButton(
                    text: 'Refuser',
                    onPressed: onReject ?? () {},
                    backgroundColor: kErrorColor,
                  ),
                ),
              ],
            ),
          ] else if (request.status == RequestStatus.accepted) ...[
            ProfessionalBubbleButton(
              text: 'Commencer le travail',
              onPressed: onComplete ?? () {},
              backgroundColor: kPrimaryTeal,
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return kPrimaryYellow;
      case RequestStatus.accepted:
        return kPrimaryTeal;
      case RequestStatus.inProgress:
        return kPrimaryDark;
      case RequestStatus.completed:
        return kSuccessColor;
      case RequestStatus.cancelled:
        return kErrorColor;
    }
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'En attente';
      case RequestStatus.accepted:
        return 'Acceptée';
      case RequestStatus.inProgress:
        return 'En cours';
      case RequestStatus.completed:
        return 'Terminée';
      case RequestStatus.cancelled:
        return 'Annulée';
    }
  }
}

// ===== ÉCRANS PRINCIPAUX =====

// Écran de démarrage professionnel
class WorkerSplashScreen extends StatefulWidget {
  @override
  _WorkerSplashScreenState createState() => _WorkerSplashScreenState();
}

class _WorkerSplashScreenState extends State<WorkerSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => WorkerAuthScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: kPrimaryTeal,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryTeal.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.work,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'KHIDMETI',
                      style: kHeadingStyle.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'WORKERS',
                      style: kSubheadingStyle.copyWith(
                        color: kPrimaryTeal,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 40),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryTeal),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Écran d'authentification professionnel
class WorkerAuthScreen extends StatefulWidget {
  @override
  _WorkerAuthScreenState createState() => _WorkerAuthScreenState();
}

class _WorkerAuthScreenState extends State<WorkerAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  final WorkerAuthService _authService = WorkerAuthService();
  final WorkerFirestoreService _databaseService = WorkerFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                // Logo et titre
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kSurfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryDark.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: kPrimaryDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.work,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _isLogin ? 'Connexion' : 'Inscription',
                        style: kHeadingStyle,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _isLogin 
                          ? 'Accédez à votre espace professionnel'
                          : 'Créez votre compte travailleur',
                        style: kBodyStyle.copyWith(color: kSubtitleColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                // Formulaire
                if (!_isLogin) ...[
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nom complet',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Téléphone',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre téléphone';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                ],
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@')) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                // Bouton de connexion/inscription
                ProfessionalBubbleButton(
                  text: _isLoading 
                    ? 'Chargement...' 
                    : (_isLogin ? 'Se connecter' : 'S\'inscrire'),
                  onPressed: _isLoading ? null : _handleAuth,
                  backgroundColor: kPrimaryDark,
                ),
                SizedBox(height: 20),
                // Lien pour changer de mode
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin 
                      ? 'Pas encore de compte ? S\'inscrire'
                      : 'Déjà un compte ? Se connecter',
                    style: kBodyStyle.copyWith(color: kPrimaryTeal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: kPrimaryDark.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: kPrimaryDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        final result = await _authService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
        if (result != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => WorkerHomeScreen()),
          );
        }
      } else {
        final result = await _authService.createUserWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
        if (result != null) {
          // Créer le profil worker
          final worker = WorkerModel(
            id: result.user!.uid,
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            avatarUrl: '',
            skills: [],
            rating: 0.0,
            completedJobs: 0,
            hourlyRate: 0.0,
            isAvailable: true,
            location: const GeoPoint(0, 0),
            address: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _databaseService.createWorker(worker);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => WorkerHomeScreen()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: kErrorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Écran principal avec navigation
class WorkerHomeScreen extends StatefulWidget {
  @override
  _WorkerHomeScreenState createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _views = [
    WorkerDashboardView(),
    WorkerRequestsView(),
    WorkerMapView(),
    WorkerEarningsView(),
    WorkerProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _views[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimaryDark.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                _buildNavItem(1, Icons.work, 'Demandes'),
                _buildNavItem(2, Icons.map, 'Carte'),
                _buildNavItem(3, Icons.attach_money, 'Gains'),
                _buildNavItem(4, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? kPrimaryDark : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : kSubtitleColor,
              size: 24,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: kBodyStyle.copyWith(
              color: isSelected ? kPrimaryDark : kSubtitleColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Vue Dashboard professionnel
class WorkerDashboardView extends StatefulWidget {
  @override
  _WorkerDashboardViewState createState() => _WorkerDashboardViewState();
}

class _WorkerDashboardViewState extends State<WorkerDashboardView> {
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final databaseService = WorkerFirestoreService();
      final stats = await databaseService.getWorkerStats(user.uid);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ProfessionalHeader(
              title: 'Dashboard',
              subtitle: 'Vue d\'ensemble de votre activité',
              actions: [
                GestureDetector(
                  onTap: () {
                    // Notifications
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kPrimaryDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.notifications, color: kPrimaryDark),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Statistiques principales
                          Row(
                            children: [
                              Expanded(
                                child: ProfessionalDashboardCard(
                                  title: 'Demandes totales',
                                  value: '${_stats?.totalRequests ?? 0}',
                                  icon: Icons.work,
                                  color: kPrimaryDark,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ProfessionalDashboardCard(
                                  title: 'Travaux terminés',
                                  value: '${_stats?.completedJobs ?? 0}',
                                  icon: Icons.check_circle,
                                  color: kSuccessColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ProfessionalDashboardCard(
                                  title: 'Gains totaux',
                                  value: '${_stats?.totalEarnings.toStringAsFixed(0) ?? 0} DA',
                                  icon: Icons.attach_money,
                                  color: kPrimaryTeal,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ProfessionalDashboardCard(
                                  title: 'Note moyenne',
                                  value: '${_stats?.averageRating.toStringAsFixed(1) ?? 0.0}',
                                  icon: Icons.star,
                                  color: kPrimaryYellow,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          // Actions rapides
                          Text(
                            'Actions rapides',
                            style: kSubheadingStyle,
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ProfessionalBubbleButton(
                                  text: 'Nouvelles demandes',
                                  onPressed: () {
                                    // Navigation vers les demandes
                                  },
                                  backgroundColor: kPrimaryTeal,
                                  icon: Icons.work,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ProfessionalBubbleButton(
                                  text: 'Mettre à jour profil',
                                  onPressed: () {
                                    // Navigation vers le profil
                                  },
                                  backgroundColor: kPrimaryDark,
                                  icon: Icons.edit,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          // Statut de disponibilité
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: kSurfaceColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryDark.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Statut de disponibilité',
                                  style: kSubheadingStyle,
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ProfessionalBubbleButton(
                                        text: 'Disponible',
                                        onPressed: () {
                                          // Mettre à jour le statut
                                        },
                                        backgroundColor: kSuccessColor,
                                        icon: Icons.check_circle,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: ProfessionalBubbleButton(
                                        text: 'Indisponible',
                                        onPressed: () {
                                          // Mettre à jour le statut
                                        },
                                        backgroundColor: kErrorColor,
                                        icon: Icons.cancel,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Vue des demandes
class WorkerRequestsView extends StatefulWidget {
  @override
  _WorkerRequestsViewState createState() => _WorkerRequestsViewState();
}

class _WorkerRequestsViewState extends State<WorkerRequestsView> {
  List<RequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final databaseService = WorkerFirestoreService();
      final requests = await databaseService.getWorkerRequests(user.uid);
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ProfessionalHeader(
              title: 'Mes demandes',
              subtitle: 'Gérez vos demandes de travail',
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _requests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.work_outline,
                                size: 80,
                                color: kSubtitleColor,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune demande pour le moment',
                                style: kSubheadingStyle.copyWith(
                                  color: kSubtitleColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Les nouvelles demandes apparaîtront ici',
                                style: kBodyStyle.copyWith(
                                  color: kSubtitleColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            final request = _requests[index];
                            return RequestCard(
                              request: request,
                              onAccept: () => _handleRequestAction(
                                request.id,
                                RequestStatus.accepted,
                              ),
                              onReject: () => _handleRequestAction(
                                request.id,
                                RequestStatus.cancelled,
                              ),
                              onComplete: () => _handleRequestAction(
                                request.id,
                                RequestStatus.completed,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRequestAction(String requestId, RequestStatus status) async {
    final databaseService = WorkerFirestoreService();
    await databaseService.updateRequestStatus(requestId, status);
    _loadRequests(); // Recharger les demandes
  }
}

// Vue de la carte
class WorkerMapView extends StatefulWidget {
  @override
  _WorkerMapViewState createState() => _WorkerMapViewState();
}

class _WorkerMapViewState extends State<WorkerMapView> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationService = WorkerLocationServiceImpl();
      final position = await locationService.getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Erreur de localisation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ProfessionalHeader(
              title: 'Carte',
              subtitle: 'Votre position et les demandes',
            ),
            Expanded(
              child: _currentLocation == null
                  ? Center(child: CircularProgressIndicator())
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _currentLocation!,
                        zoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.khidmeti.workers',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation!,
                              width: 80,
                              height: 80,
                              builder: (context) => Container(
                                decoration: BoxDecoration(
                                  color: kPrimaryTeal,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  Icons.my_location,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Vue des gains
class WorkerEarningsView extends StatefulWidget {
  @override
  _WorkerEarningsViewState createState() => _WorkerEarningsViewState();
}

class _WorkerEarningsViewState extends State<WorkerEarningsView> {
  List<PaymentModel> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final paymentProcessor = BaridiMobPaymentProcessor();
      final payments = await paymentProcessor.getWorkerPayments(user.uid);
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ProfessionalHeader(
              title: 'Mes gains',
              subtitle: 'Historique des paiements',
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _payments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: 80,
                                color: kSubtitleColor,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucun paiement pour le moment',
                                style: kSubheadingStyle.copyWith(
                                  color: kSubtitleColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(20),
                          itemCount: _payments.length,
                          itemBuilder: (context, index) {
                            final payment = _payments[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: kSurfaceColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimaryDark.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: kSuccessColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.attach_money,
                                      color: kSuccessColor,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${payment.amount.toStringAsFixed(2)} DA',
                                          style: kSubheadingStyle.copyWith(
                                            color: kSuccessColor,
                                          ),
                                        ),
                                        Text(
                                          'Paiement #${payment.id.substring(0, 8)}',
                                          style: kBodyStyle.copyWith(
                                            color: kSubtitleColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(payment.status)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getStatusText(payment.status),
                                      style: kBodyStyle.copyWith(
                                        color: _getStatusColor(payment.status),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return kPrimaryYellow;
      case PaymentStatus.completed:
        return kSuccessColor;
      case PaymentStatus.failed:
        return kErrorColor;
      case PaymentStatus.refunded:
        return kSubtitleColor;
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.completed:
        return 'Terminé';
      case PaymentStatus.failed:
        return 'Échoué';
      case PaymentStatus.refunded:
        return 'Remboursé';
    }
  }
}

// Vue du profil
class WorkerProfileView extends StatefulWidget {
  @override
  _WorkerProfileViewState createState() => _WorkerProfileViewState();
}

class _WorkerProfileViewState extends State<WorkerProfileView> {
  WorkerModel? _worker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final databaseService = WorkerFirestoreService();
      final worker = await databaseService.getWorker(user.uid);
      setState(() {
        _worker = worker;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ProfessionalHeader(
              title: 'Mon profil',
              subtitle: 'Gérez vos informations',
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Avatar et informations principales
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: kSurfaceColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryDark.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: kPrimaryDark,
                                  child: _worker?.avatarUrl.isNotEmpty == true
                                      ? ClipOval(
                                          child: Image.network(
                                            _worker!.avatarUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  _worker?.name ?? 'Nom non défini',
                                  style: kHeadingStyle,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _worker?.email ?? '',
                                  style: kBodyStyle.copyWith(
                                    color: kSubtitleColor,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            '${_worker?.completedJobs ?? 0}',
                                            style: kHeadingStyle.copyWith(
                                              fontSize: 24,
                                            ),
                                          ),
                                          Text(
                                            'Travaux terminés',
                                            style: kBodyStyle.copyWith(
                                              color: kSubtitleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            '${_worker?.rating.toStringAsFixed(1) ?? 0.0}',
                                            style: kHeadingStyle.copyWith(
                                              fontSize: 24,
                                            ),
                                          ),
                                          Text(
                                            'Note moyenne',
                                            style: kBodyStyle.copyWith(
                                              color: kSubtitleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Actions du profil
                          ProfessionalBubbleButton(
                            text: 'Modifier le profil',
                            onPressed: () {
                              // Navigation vers l'édition du profil
                            },
                            backgroundColor: kPrimaryDark,
                            icon: Icons.edit,
                          ),
                          SizedBox(height: 16),
                          ProfessionalBubbleButton(
                            text: 'Changer l\'avatar',
                            onPressed: () {
                              // Sélection d'avatar
                            },
                            backgroundColor: kPrimaryTeal,
                            icon: Icons.camera_alt,
                          ),
                          SizedBox(height: 16),
                          ProfessionalBubbleButton(
                            text: 'Se déconnecter',
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => WorkerAuthScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            backgroundColor: kErrorColor,
                            icon: Icons.logout,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(WorkerKhidmetiApp());
}

class WorkerKhidmetiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khidmeti Workers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Paytone One',
        scaffoldBackgroundColor: kBackgroundColor,
      ),
      home: WorkerSplashScreen(),
    );
  }
}
