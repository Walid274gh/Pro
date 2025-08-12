// Khidmeti Users - Single file app (main.dart)
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Design constants (Paytone One palette)
const Color kPrimaryYellow = Color(0xFFFCDC73);
const Color kPrimaryRed = Color(0xFFE76268);
const Color kPrimaryDark = Color(0xFF193948);
const Color kPrimaryTeal = Color(0xFF4FADCD);

const Color kBackgroundColor = Color(0xFFFFF8E7);
const Color kSurfaceColor = Color(0xFFFFFFFF);
const Color kTextColor = Color(0xFF193948);
const Color kSubtitleColor = Color(0xFF6B7280);
const Color kSuccessColor = Color(0xFF10B981);
const Color kErrorColor = Color(0xFFE76268);

const Color kButton3DLight = Color(0xFFFEF3C7);
const Color kButton3DShadow = Color(0xFF92400E);
const Color kButtonGradient1 = Color(0xFFFCDC73);
const Color kButtonGradient2 = Color(0xFFF59E0B);

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

// Typography styles
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

// ---------- SOLID: Core abstractions ----------
abstract class AuthenticationService {
  Future<UserModel?> signInWithEmail(String email, String password);
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

class UserService {
  final Readable userRepository;
  final NotificationSender notificationSender;
  UserService(this.userRepository, this.notificationSender);
}

// ---------- Models ----------
class UserModel {
  final String id;
  final String name;
  final String email;
  final String selectedAvatar;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.selectedAvatar,
    required this.preferences,
    required this.createdAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    final createdRaw = map['createdAt'];
    DateTime created;
    if (createdRaw is int) {
      created = DateTime.fromMillisecondsSinceEpoch(createdRaw);
    } else if (createdRaw is Timestamp) {
      created = createdRaw.toDate();
    } else {
      created = DateTime.now();
    }
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      selectedAvatar: map['selectedAvatar'] ?? '',
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'selectedAvatar': selectedAvatar,
        'preferences': preferences,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? name,
    String? email,
    String? selectedAvatar,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  void validate() => UserValidator.validateUser(this);
}

class WorkerModel {
  final String id;
  final String name;
  final String selectedAvatar;
  final Map<String, dynamic> businessStyle;
  final String subscriptionStatus;
  final bool visibilityOnMap;
  final String verificationStatus;

  WorkerModel({
    required this.id,
    required this.name,
    required this.selectedAvatar,
    required this.businessStyle,
    required this.subscriptionStatus,
    required this.visibilityOnMap,
    required this.verificationStatus,
  });

  factory WorkerModel.fromMap(String id, Map<String, dynamic> map) => WorkerModel(
        id: id,
        name: map['name'] ?? '',
        selectedAvatar: map['selectedAvatar'] ?? '',
        businessStyle: Map<String, dynamic>.from(map['businessStyle'] ?? {}),
        subscriptionStatus: map['subscriptionStatus'] ?? 'inactive',
        visibilityOnMap: map['visibilityOnMap'] ?? false,
        verificationStatus: map['verificationStatus'] ?? 'pending',
      );
}

class ServiceModel {
  final String id;
  final String name;
  final String iconPath;
  final String description;
  final double basePrice;

  ServiceModel({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.description,
    required this.basePrice,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'iconPath': iconPath,
        'description': description,
        'basePrice': basePrice,
      };
}

class RequestModel {
  final String id;
  final String userId;
  final String workerId;
  final String serviceId;
  final String status; // pending | accepted | in_progress | completed | canceled
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.serviceId,
    required this.status,
    required this.createdAt,
  });
}

// ---------- Services (stubs) ----------
class AuthService implements AuthenticationService {
  final _auth = FirebaseAuth.instance;

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    if (!kUseFirebase) return UserModel(
      id: 'local-dev', name: 'Local Dev', email: email, selectedAvatar: AvatarService().getRandomUserAvatar(), preferences: const {
        'primaryColor': '#FCDC73', 'accentColor': '#E76268'
      }, createdAt: DateTime.now());
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      name: user.displayName ?? email.split('@').first,
      email: user.email ?? email,
      selectedAvatar: AvatarService().getRandomUserAvatar(),
      preferences: const {'primaryColor': '#FCDC73', 'accentColor': '#E76268'},
      createdAt: DateTime.now(),
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
  Future<void> delete(String id) async {
    // Not bound to specific collection in this stub. No-op.
  }

  @override
  Future<T?> read<T>(String id) async {
    return null; // Generic stub
  }

  @override
  Future<void> write<T>(String id, T data) async {
    // Generic stub
  }
}

class StorageService {
  Future<String> uploadFile(String path, List<int> bytes) async {
    return path; // TODO: integrate Firebase Storage
  }
}

class OpenStreetMapLocationService implements LocationService {
  @override
  Future<Position> getCurrentLocation() async {
    return const Position(latitude: 36.7529, longitude: 3.0420); // Algiers placeholder
  }

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
  static const List<String> userAvatars = [
    'packages/shared_assets/avatars/users/avatar_user_1.svg',
    'packages/shared_assets/avatars/users/avatar_user_2.svg',
    'packages/shared_assets/avatars/users/avatar_user_3.svg',
    'packages/shared_assets/avatars/users/avatar_user_4.svg',
    'packages/shared_assets/avatars/users/avatar_user_5.svg',
    'packages/shared_assets/avatars/users/avatar_user_6.svg',
    'packages/shared_assets/avatars/users/avatar_user_7.svg',
    'packages/shared_assets/avatars/users/avatar_user_8.svg',
    'packages/shared_assets/avatars/users/avatar_user_9.svg',
    'packages/shared_assets/avatars/users/avatar_user_10.svg',
  ];

  String getRandomUserAvatar() {
    final idx = Random().nextInt(userAvatars.length);
    return userAvatars[idx];
  }

  List<String> getAllUserAvatars() => userAvatars;
}

class MapService {
  const MapService();
}

class BaridiMobPaymentProcessor extends PaymentProcessor {
  @override
  Future<PaymentResult> processPayment(double amount, PaymentMethod method) async {
    return const PaymentResult(isSuccess: true, message: 'BaridiMob processed');
  }
}

class BankCardPaymentProcessor extends PaymentProcessor {
  @override
  Future<PaymentResult> processPayment(double amount, PaymentMethod method) async {
    return const PaymentResult(isSuccess: true, message: 'Bank card processed');
  }
}

// ---------- Widgets ----------
class ModernHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const ModernHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(kBorderRadius * 2),
          bottomRight: Radius.circular(kBorderRadius * 2),
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryYellow.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
          boxShadow: const [
            BoxShadow(color: kButton3DLight, offset: Offset(-2, -2), blurRadius: 6),
            BoxShadow(color: kButton3DShadow, offset: Offset(3, 6), blurRadius: 12),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kPrimaryDark),
            const SizedBox(width: 8),
            Text(label, style: kSubheadingStyle.copyWith(color: kPrimaryDark)),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(kPadding),
      child: child,
    );
  }
}

class AvatarPicker extends StatelessWidget {
  final void Function(String assetPath) onSelected;
  const AvatarPicker({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final avatars = AvatarService.userAvatars;
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
              backgroundColor: kPrimaryYellow,
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

class RatingStars extends StatelessWidget {
  final double rating;
  const RatingStars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    return Row(
      children: List.generate(5, (i) {
        return Icon(i < fullStars ? Icons.star : Icons.star_border, color: kPrimaryYellow);
      }),
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

class SuccessAnimationWidget extends StatelessWidget {
  const SuccessAnimationWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Lottie.asset('packages/shared_assets/animations/success_animation.json', width: 160, height: 160);
  }
}

class ErrorAnimationWidget extends StatelessWidget {
  const ErrorAnimationWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Lottie.asset('packages/shared_assets/animations/error_animation.json', width: 160, height: 160);
  }
}

class TypingIndicatorWidget extends StatelessWidget {
  const TypingIndicatorWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Lottie.asset('packages/shared_assets/animations/chat_typing.json', width: 100, height: 40);
  }
}

class MapMarkerWidget extends StatelessWidget {
  const MapMarkerWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Lottie.asset('packages/shared_assets/animations/map_marker.json', width: 64, height: 64);
  }
}

// ---------- Screens ----------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kUseFirebase) {
    await Firebase.initializeApp();
  }
  runApp(const KhidmetiApp());
}

class KhidmetiApp extends StatelessWidget {
  const KhidmetiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khidmeti Users',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryYellow,
          primary: kPrimaryYellow,
          secondary: kPrimaryRed,
          surface: kSurfaceColor,
        ),
        textTheme: const TextTheme(
          headlineSmall: kHeadingStyle,
          titleMedium: kSubheadingStyle,
          bodyMedium: kBodyStyle,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ModernHeader(title: 'Khidmeti'),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Lottie.asset('packages/shared_assets/animations/splash_animation.json', width: 240, height: 240),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
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
              const ModernHeader(title: 'Bienvenue'),
              const SizedBox(height: 20),
              Text('Connectez-vous', style: kHeadingStyle),
              const SizedBox(height: 8),
              Text('Choisissez votre avatar et continuez', style: kBodyStyle),
              const SizedBox(height: 16),
              AvatarPicker(onSelected: (a) => selectedAvatar = a),
              const Spacer(),
              Center(
                child: BubbleButton(
                  label: 'Continuer',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => HomeScreen(selectedAvatar: selectedAvatar)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class UsersRepository {
  final FirebaseFirestore db;
  UsersRepository(this.db);

  CollectionReference<Map<String, dynamic>> get _col => db.collection('users');

  Future<void> upsertUser(UserModel user) async {
    if (!kUseFirebase) return;
    user.validate();
    await _col.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String userId) async {
    if (!kUseFirebase) return null;
    final doc = await _col.doc(userId).get();
    final data = doc.data();
    if (data == null) return null;
    return UserModel.fromMap(doc.id, data);
  }
}

class WorkersRepository {
  final FirebaseFirestore db;
  WorkersRepository(this.db);

  Stream<List<WorkerModel>> activeWorkers() {
    if (!kUseFirebase) {
      return Stream.value(<WorkerModel>[]);
    }
    return db
        .collection('workers')
        .where('subscriptionStatus', isEqualTo: 'active')
        .where('visibilityOnMap', isEqualTo: true)
        .where('verificationStatus', isEqualTo: 'verified')
        .snapshots()
        .map((snap) => snap.docs.map((d) => WorkerModel.fromMap(d.id, d.data())).toList(growable: false));
  }
}

class WorkerSyncService {
  final WorkersRepository repository;
  WorkerSyncService(this.repository);

  Stream<List<WorkerModel>> get visibleWorkersStream => repository.activeWorkers();
}

class HomeScreen extends StatelessWidget {
  final String? selectedAvatar;
  const HomeScreen({super.key, this.selectedAvatar});

  @override
  Widget build(BuildContext context) {
    final workerSync = WorkerSyncService(WorkersRepository(FirebaseFirestore.instance));
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(kPadding),
          children: [
            const ModernHeader(title: 'Accueil'),
            const SizedBox(height: 16),
            PrimaryCard(
              child: Row(
                children: [
                  if (selectedAvatar != null)
                    CircleAvatar(radius: 28, child: SvgPicture.asset(selectedAvatar!, width: 48, height: 48)),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Trouver un service', style: kSubheadingStyle)),
                  BubbleButton(label: 'Chercher', icon: Icons.search, onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Autour de vous', style: kSubheadingStyle),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: kUseFirebase
                            ? FirebaseFirestore.instance
                                .collection('workers')
                                .where('subscriptionStatus', isEqualTo: 'active')
                                .where('visibilityOnMap', isEqualTo: true)
                                .snapshots()
                            : const Stream.empty(),
                        builder: (context, snapshot) {
                          final markers = <Marker>[];
                          if (snapshot.hasData) {
                            for (final d in snapshot.data!.docs) {
                              final data = d.data();
                              final loc = data['location'];
                              if (loc is GeoPoint) {
                                markers.add(
                                  Marker(
                                    width: 40,
                                    height: 40,
                                    point: LatLng(loc.latitude, loc.longitude),
                                    child: const Icon(Icons.location_pin, color: kPrimaryRed, size: 36),
                                  ),
                                );
                              }
                            }
                          }
                          return FlutterMap(
                            options: const MapOptions(
                              initialCenter: LatLng(36.7529, 3.0420),
                              initialZoom: 11,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.khidmeti.users',
                              ),
                              if (markers.isNotEmpty) MarkerLayer(markers: markers),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (kUseFirebase)
                    StreamBuilder<List<WorkerModel>>(
                      stream: workerSync.visibleWorkersStream,
                      builder: (context, snapshot) {
                        final workers = snapshot.data ?? [];
                        if (workers.isEmpty) return Text('Aucun pro visible', style: kBodyStyle);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: workers.take(5).map((w) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.verified, color: kPrimaryTeal, size: 18),
                                const SizedBox(width: 6),
                                Expanded(child: Text(w.name, style: kBodyStyle.copyWith(color: kTextColor))),
                              ],
                            ),
                          )).toList(),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications', style: kSubheadingStyle),
                  const SizedBox(height: 8),
                  Lottie.asset('packages/shared_assets/animations/notification_animation.json', height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BubbleButton(label: 'Chat', icon: Icons.chat_bubble, onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
            }),
            BubbleButton(label: 'Profil', icon: Icons.person, onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModernHeader(title: 'Recherche'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPadding),
              child: PrimaryCard(
                child: Row(children: [
                  const Icon(Icons.search, color: kPrimaryDark),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Plombier, Électricien...', style: kBodyStyle)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ModernHeader(title: 'Chat'),
            const SizedBox(height: 8),
            const Expanded(child: Center(child: TypingIndicatorWidget())),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(kPadding),
          children: [
            const ModernHeader(title: 'Profil'),
            const SizedBox(height: 16),
            PrimaryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paramètres', style: kSubheadingStyle),
                  const SizedBox(height: 8),
                  BubbleButton(label: 'Se déconnecter', icon: Icons.logout, onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SplashScreen()), (r) => false)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserValidator {
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^\S+@\S+\.\S+');
    return regex.hasMatch(email);
  }

  static void validateUser(UserModel user) {
    if (user.name.trim().isEmpty) {
      throw ArgumentError('Le nom est requis');
    }
    if (!isValidEmail(user.email)) {
      throw ArgumentError('Email invalide');
    }
    if (user.selectedAvatar.isEmpty) {
      throw ArgumentError('Avatar requis');
    }
  }
}