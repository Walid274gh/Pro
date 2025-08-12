// Khidmeti Worker - Single file app (main.dart)
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Design constants (Professional emphasis)
const Color kPrimaryYellow = Color(0xFFFCDC73);
const Color kPrimaryRed = Color(0xFFE76268);
const Color kPrimaryDark = Color(0xFF193948); // Dominant
const Color kPrimaryTeal = Color(0xFF4FADCD); // Accent

const Color kBackgroundColor = Color(0xFFFFF8E7);
const Color kSurfaceColor = Color(0xFFFFFFFF);
const Color kTextColor = Color(0xFF193948);
const Color kSubtitleColor = Color(0xFF6B7280);
const Color kSuccessColor = Color(0xFF10B981);
const Color kErrorColor = Color(0xFFE76268);

const Color kButton3DLight = Color(0xFFFEF3C7);
const Color kButton3DShadow = Color(0xFF0D1F27);
const Color kButtonGradient1 = Color(0xFF4FADCD);
const Color kButtonGradient2 = Color(0xFF193948);

const double kBorderRadius = 20.0;
const double kElevation = 8.0;
const double kPadding = 16.0;

const bool USE_PAYTONE_COLORS = true;
const bool NO_APPBAR_DESIGN = true;
const bool BUBBLE_BUTTONS = true;
const bool ROUND_CORNERS_20PX = true;
const bool OPENSTREETMAP_ONLY = true;
const bool SINGLE_FILE_MAIN = true;
const bool SOLID_ARCHITECTURE = true;
const bool LOTTIE_ANIMATIONS = true;
const bool SVG_AVATARS = true;
const bool kUseFirebase = true;

const TextStyle kHeadingStyle = TextStyle(
  fontFamily: 'Paytone One',
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: kPrimaryDark,
  letterSpacing: -0.5,
);

const TextStyle kSubheadingStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kTextColor,
);

const TextStyle kBodyStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kSubtitleColor,
  height: 1.4,
);

// SOLID abstractions (mirrored)
abstract class AuthenticationService {
  Future<WorkerUserModel?> signInWithEmail(String email, String password);
  Future<void> signOut();
}

abstract class DatabaseService {
  Future<void> createDocument(String collection, String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getDocument(String collection, String id);
}

class Position {
  final double latitude;
  final double longitude;
  const Position({required this.latitude, required this.longitude});
}

abstract class LocationService {
  Future<Position> getCurrentLocation();
  Stream<Position> getLocationStream();
}

enum PaymentMethod { baridiMob, bankCard }

class PaymentResult {
  final bool isSuccess;
  final String? message;
  const PaymentResult({required this.isSuccess, this.message});
}

abstract class PaymentProcessor {
  Future<PaymentResult> processPayment(double amount, PaymentMethod method);
}

abstract class NotificationSender {
  Future<void> sendNotification(String userId, String message);
}

abstract class Readable {
  Future<T?> read<T>(String id);
}

abstract class Writable {
  Future<void> write<T>(String id, T data);
}

abstract class Deletable {
  Future<void> delete(String id);
}

class WorkerAppService {
  final Readable repository;
  final NotificationSender notifications;
  WorkerAppService(this.repository, this.notifications);
}

// Models
class WorkerUserModel {
  final String id;
  final String name;
  final String selectedAvatar;
  final Map<String, dynamic> businessStyle;
  final String subscriptionStatus; // active|inactive|trial
  final bool visibilityOnMap;
  final String verificationStatus; // pending|verified|rejected

  WorkerUserModel({
    required this.id,
    required this.name,
    required this.selectedAvatar,
    required this.businessStyle,
    required this.subscriptionStatus,
    required this.visibilityOnMap,
    required this.verificationStatus,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'selectedAvatar': selectedAvatar,
        'businessStyle': businessStyle,
        'subscriptionStatus': subscriptionStatus,
        'visibilityOnMap': visibilityOnMap,
        'verificationStatus': verificationStatus,
      };
}

class SubscriptionModel {
  final String id;
  final DateTime startAt;
  final DateTime endAt;
  final bool isActive;
  SubscriptionModel({required this.id, required this.startAt, required this.endAt, required this.isActive});
}

class ProfessionalServiceModel {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  ProfessionalServiceModel({required this.id, required this.name, required this.description, required this.iconPath});
}

class JobRequestModel {
  final String id;
  final String clientUserId;
  final String workerUserId;
  final String serviceId;
  final String status; // pending|accepted|rejected|completed
  JobRequestModel({required this.id, required this.clientUserId, required this.workerUserId, required this.serviceId, required this.status});
}

// Services (stubs)
class AuthService implements AuthenticationService {
  final _auth = FirebaseAuth.instance;

  @override
  Future<WorkerUserModel?> signInWithEmail(String email, String password) async {
    if (!kUseFirebase) return WorkerUserModel(
      id: 'local-worker',
      name: 'Local Pro',
      selectedAvatar: AvatarService().getRandomWorkerAvatar(),
      businessStyle: const {'primaryColor': '#193948', 'accentColor': '#4FADCD'},
      subscriptionStatus: 'trial',
      visibilityOnMap: false,
      verificationStatus: 'pending',
    );
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user == null) return null;
    return WorkerUserModel(
      id: user.uid,
      name: user.displayName ?? email.split('@').first,
      selectedAvatar: AvatarService().getRandomWorkerAvatar(),
      businessStyle: const {'primaryColor': '#193948', 'accentColor': '#4FADCD'},
      subscriptionStatus: 'trial',
      visibilityOnMap: false,
      verificationStatus: 'pending',
    );
  }

  @override
  Future<void> signOut() async {
    if (!kUseFirebase) return;
    await _auth.signOut();
  }
}

class FirestoreService implements DatabaseService, Readable, Writable, Deletable {
  final _db = FirebaseFirestore.instance;

  @override
  Future<void> createDocument(String collection, String id, Map<String, dynamic> data) async {
    if (!kUseFirebase) return;
    await _db.collection(collection).doc(id).set(data, SetOptions(merge: true));
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String collection, String id) async {
    if (!kUseFirebase) return null;
    final doc = await _db.collection(collection).doc(id).get();
    return doc.data();
  }

  @override
  Future<void> delete(String id) async {}

  @override
  Future<T?> read<T>(String id) async => null;

  @override
  Future<void> write<T>(String id, T data) async {}
}

class StorageService {
  Future<String> uploadFile(String path, List<int> bytes) async => path;
}

class OpenStreetMapLocationService implements LocationService {
  @override
  Future<Position> getCurrentLocation() async => const Position(latitude: 36.7529, longitude: 3.0420);

  @override
  Stream<Position> getLocationStream() async* {
    yield const Position(latitude: 36.7529, longitude: 3.0420);
  }
}

class PushNotificationSender implements NotificationSender {
  @override
  Future<void> sendNotification(String userId, String message) async {}
}

class ChatService {
  Future<void> sendMessage(String toId, String message) async {}
  Stream<List<String>> messagesStream(String conversationId) async* {
    yield <String>[];
  }
}

class AvatarService {
  static const List<String> workerAvatars = [
    'packages/shared_assets/avatars/workers/avatar_worker_1.svg',
    'packages/shared_assets/avatars/workers/avatar_worker_2.svg',
    'packages/shared_assets/avatars/workers/avatar_worker_3.svg',
    'packages/shared_assets/avatars/workers/avatar_worker_4.svg',
    'packages/shared_assets/avatars/workers/avatar_worker_5.svg',
    'packages/shared_assets/avatars/workers/avatar_worker_6.svg',
    'packages/shared_assets/avatars/workers/avatar_worker_7.svg',
    'packages/shared_assets/avatars/workers/avatar_worker_8.svg',
    'packages/shared_assets/avatars/workers/avatar_worker_9.svg',
    'packages/shared_assets/avatars/workers/avatar_worker_10.svg',
  ];

  String getRandomWorkerAvatar() {
    final idx = Random().nextInt(workerAvatars.length);
    return workerAvatars[idx];
  }

  List<String> getAllWorkerAvatars() => workerAvatars;
}

class MapService {
  const MapService();
}

class BaridiMobPaymentProcessor extends PaymentProcessor {
  @override
  Future<PaymentResult> processPayment(double amount, PaymentMethod method) async =>
      const PaymentResult(isSuccess: true, message: 'BaridiMob processed');
}

class BankCardPaymentProcessor extends PaymentProcessor {
  @override
  Future<PaymentResult> processPayment(double amount, PaymentMethod method) async =>
      const PaymentResult(isSuccess: true, message: 'Bank card processed');
}

class WorkersAdminRepository {
  final FirebaseFirestore db;
  WorkersAdminRepository(this.db);

  Future<void> setSubscriptionActive({required String workerId}) async {
    if (!kUseFirebase) return;
    await db.collection('workers').doc(workerId).set({
      'subscriptionStatus': 'active',
      'visibilityOnMap': true,
      'verificationStatus': 'verified',
      'businessStyle': {
        'primaryColor': '#193948',
        'accentColor': '#4FADCD',
      },
    }, SetOptions(merge: true));
  }
}

// Widgets
class ModernHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const ModernHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: const BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(kBorderRadius * 2),
          bottomRight: Radius.circular(kBorderRadius * 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: kHeadingStyle),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class BubbleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  const BubbleButton({super.key, required this.label, required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kButtonGradient1, kButtonGradient2]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: kButton3DLight.withOpacity(0.6), offset: const Offset(-2, -2), blurRadius: 6),
            const BoxShadow(color: kButton3DShadow, offset: Offset(3, 6), blurRadius: 12),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: kSubheadingStyle.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class PrimaryCard extends StatelessWidget {
  final Widget child;
  const PrimaryCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(kPadding),
      child: child,
    );
  }
}

class WorkerAvatarPicker extends StatelessWidget {
  final void Function(String assetPath) onSelected;
  const WorkerAvatarPicker({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final avatars = AvatarService.workerAvatars;
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: avatars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final a = avatars[index];
          return GestureDetector(
            onTap: () => onSelected(a),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: kPrimaryTeal,
              child: ClipOval(
                child: SvgPicture.asset(a, width: 64, height: 64),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});
  @override
  Widget build(BuildContext context) {
    return Lottie.asset('packages/shared_assets/animations/loading_spinner.json', width: 80, height: 80);
  }
}

// Screens
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kUseFirebase) {
    await Firebase.initializeApp();
  }
  runApp(const KhidmetiWorkerApp());
}

class KhidmetiWorkerApp extends StatelessWidget {
  const KhidmetiWorkerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khidmeti Worker',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryDark,
          primary: kPrimaryDark,
          secondary: kPrimaryTeal,
          surface: kSurfaceColor,
        ),
        textTheme: const TextTheme(
          headlineSmall: kHeadingStyle,
          titleMedium: kSubheadingStyle,
          bodyMedium: kBodyStyle,
        ),
      ),
      home: const WorkerSplashScreen(),
    );
  }
}

class WorkerSplashScreen extends StatefulWidget {
  const WorkerSplashScreen({super.key});
  @override
  State<WorkerSplashScreen> createState() => _WorkerSplashScreenState();
}

class _WorkerSplashScreenState extends State<WorkerSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WorkerAuthScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ModernHeader(title: 'Khidmeti Pro'),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Lottie.asset('packages/shared_assets/animations/splash_workers_background.json', width: 240, height: 240),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerAuthScreen extends StatelessWidget {
  const WorkerAuthScreen({super.key});
  @override
  Widget build(BuildContext context) {
    String? selectedAvatar;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModernHeader(title: 'Connexion Pro'),
              const SizedBox(height: 20),
              Text('Identité & Vérification', style: kHeadingStyle),
              const SizedBox(height: 8),
              Text('Choisissez un avatar professionnel', style: kBodyStyle),
              const SizedBox(height: 16),
              WorkerAvatarPicker(onSelected: (a) => selectedAvatar = a),
              const Spacer(),
              Center(
                child: BubbleButton(label: 'Continuer', icon: Icons.arrow_forward, onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => WorkerHomeScreen(selectedAvatar: selectedAvatar)),
                  );
                }),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkerHomeScreen extends StatelessWidget {
  final String? selectedAvatar;
  const WorkerHomeScreen({super.key, this.selectedAvatar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(kPadding),
          children: [
            const ModernHeader(title: 'Tableau de bord'),
            const SizedBox(height: 16),
            PrimaryCard(
              child: Row(
                children: [
                  if (selectedAvatar != null)
                    CircleAvatar(radius: 28, child: SvgPicture.asset(selectedAvatar!, width: 48, height: 48)),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Statut abonnement', style: kSubheadingStyle)),
                  BubbleButton(label: 'Renouveler', icon: Icons.verified, onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Carte (visibilité)', style: kSubheadingStyle),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      child: FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(36.7529, 3.0420),
                          initialZoom: 11,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.khidmeti.worker',
                          ),
                        ],
                      ),
                    ),
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

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = WorkersAdminRepository(FirebaseFirestore.instance);
    const workerId = 'demo-worker-id';
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModernHeader(title: 'Abonnement'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(kPadding),
              child: PrimaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Renouvellement', style: kSubheadingStyle),
                    const SizedBox(height: 8),
                    BubbleButton(label: 'Payer BaridiMob', icon: Icons.payment, onPressed: () async {
                      await repo.setSubscriptionActive(workerId: workerId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abonnement activé')));
                      }
                    }),
                    const SizedBox(height: 8),
                    BubbleButton(label: 'Payer Carte', icon: Icons.credit_card, onPressed: () async {
                      await repo.setSubscriptionActive(workerId: workerId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abonnement activé')));
                      }
                    }),
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