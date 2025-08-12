import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Firebase (initialize only when available)
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';

// ============================
// Design Tokens - Paytone One
// ============================
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

// Style flags (Cursor checkpoints)
const bool USE_PAYTONE_COLORS = true;
const bool NO_APPBAR_DESIGN = true;
const bool BUBBLE_BUTTONS = true;
const bool ROUND_CORNERS_20PX = true;
const bool OPENSTREETMAP_ONLY = true;
const bool SINGLE_FILE_MAIN = true;
const bool SOLID_ARCHITECTURE = true;
const bool LOTTIE_ANIMATIONS = true;
const bool SVG_AVATARS = true;

TextStyle get kHeadingStyle => GoogleFonts.paytoneOne(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: kPrimaryDark,
  letterSpacing: -0.5,
);

TextStyle get kSubheadingStyle => GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kTextColor,
);

TextStyle get kBodyStyle => GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kSubtitleColor,
  height: 1.4,
);

// ============================
// Models (Users App)
// ============================
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarAssetPath;
  final GeoPoint? location;
  final DateTime createdAt;
  final Color primaryColor;
  final Color accentColor;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarAssetPath,
    this.location,
    required this.createdAt,
    this.primaryColor = kPrimaryYellow,
    this.accentColor = kPrimaryRed,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'selectedAvatar': avatarAssetPath,
        'preferences': {
          'primaryColor': _toHex(primaryColor),
          'accentColor': _toHex(accentColor),
        },
        'location': location,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static UserModel from(String id, Map<String, dynamic> json) => UserModel(
        id: id,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        avatarAssetPath: json['selectedAvatar'],
        location: json['location'],
        createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        primaryColor: _parseHex(json['preferences']?['primaryColor']) ?? kPrimaryYellow,
        accentColor: _parseHex(json['preferences']?['accentColor']) ?? kPrimaryRed,
      );
}

class WorkerModel {
  final String id;
  final String name;
  final String? avatarAssetPath;
  final bool visibilityOnMap;
  final String subscriptionStatus; // active|inactive|trial
  final String verificationStatus; // pending|verified|rejected
  final GeoPoint? location;
  final Color primaryColor;
  final Color accentColor;

  WorkerModel({
    required this.id,
    required this.name,
    this.avatarAssetPath,
    required this.visibilityOnMap,
    required this.subscriptionStatus,
    required this.verificationStatus,
    this.location,
    this.primaryColor = kPrimaryDark,
    this.accentColor = kPrimaryTeal,
  });

  static WorkerModel from(String id, Map<String, dynamic> json) => WorkerModel(
        id: id,
        name: json['name'] ?? '',
        avatarAssetPath: json['selectedAvatar'],
        visibilityOnMap: json['visibilityOnMap'] == true,
        subscriptionStatus: json['subscriptionStatus'] ?? 'inactive',
        verificationStatus: json['verificationStatus'] ?? 'pending',
        location: json['location'],
        primaryColor: _parseHex(json['businessStyle']?['primaryColor']) ?? kPrimaryDark,
        accentColor: _parseHex(json['businessStyle']?['accentColor']) ?? kPrimaryTeal,
      );
}

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String iconAssetPath;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.iconAssetPath,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'price': price,
        'icon': iconAssetPath,
      };
}

class RequestModel {
  final String id;
  final String userId;
  final String workerId;
  final String serviceId;
  final String status; // pending|accepted|rejected|completed
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.serviceId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'workerId': workerId,
        'serviceId': serviceId,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

// ============================
// SOLID Services (stubs)
// ============================
abstract class AuthenticationService {
  Future<User?> signInWithEmail(String email, String password);
  Future<void> signOut();
}

abstract class DatabaseService {
  Future<void> createDocument(String collection, String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getDocument(String collection, String id);
  Stream<List<Map<String, dynamic>>> listenCollection(String collection, {Query Function(Query)? where});
}

abstract class LocationService {
  Future<Position> getCurrentLocation();
  Stream<Position> getLocationStream();
}

abstract class NotificationSender {
  Future<void> sendNotification(String userId, String message);
}

class FirebaseAuthService implements AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  @override
  Future<void> signOut() async => _auth.signOut();
}

class FirestoreDatabaseService implements DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<void> createDocument(String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).set(data, SetOptions(merge: true));
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String collection, String id) async {
    final doc = await _db.collection(collection).doc(id).get();
    return doc.data();
  }

  @override
  Stream<List<Map<String, dynamic>>> listenCollection(String collection, {Query Function(Query)? where}) {
    Query query = _db.collection(collection);
    if (where != null) query = where(query);
    return query.snapshots().map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<Position> getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    return Geolocator.getCurrentPosition();
  }

  @override
  Stream<Position> getLocationStream() => Geolocator.getPositionStream();
}

class PushNotificationSender implements NotificationSender {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  @override
  Future<void> sendNotification(String userId, String message) async {
    // Placeholder - would call cloud function or topic
  }
}

class ChatService {
  Future<void> sendMessage({required String chatId, required String fromUserId, required String content}) async {}
  Stream<List<Map<String, dynamic>>> listenMessages(String chatId) async* {}
}

class AvatarService {
  static const List<String> userAvatars = [
    'assets/avatars/users/avatar_user_1.svg',
    'assets/avatars/users/avatar_user_2.svg',
    'assets/avatars/users/avatar_user_3.svg',
    'assets/avatars/users/avatar_user_4.svg',
    'assets/avatars/users/avatar_user_5.svg',
    'assets/avatars/users/avatar_user_6.svg',
    'assets/avatars/users/avatar_user_7.svg',
    'assets/avatars/users/avatar_user_8.svg',
    'assets/avatars/users/avatar_user_9.svg',
    'assets/avatars/users/avatar_user_10.svg',
  ];

  String getRandomUserAvatar() {
    final rnd = Random();
    return userAvatars[rnd.nextInt(userAvatars.length)];
  }

  List<String> getAllUserAvatars() => userAvatars;
}

class MapService {
  const MapService();
}

// ============================
// Widgets
// ============================
class ModernHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const ModernHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kPadding, vertical: 20),
      decoration: const BoxDecoration(
        color: kBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(kBorderRadius),
          bottomRight: Radius.circular(kBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Text(title, style: kHeadingStyle),
          const Spacer(),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kButtonGradient1, kButtonGradient2]),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(color: kButton3DLight, offset: Offset(-4, -4), blurRadius: 8),
            BoxShadow(color: kButton3DShadow, offset: Offset(4, 6), blurRadius: 12),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kPrimaryDark),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.paytoneOne(color: kPrimaryDark, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class PaytoneCard extends StatelessWidget {
  final Widget child;
  const PaytoneCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.all(kPadding),
      child: child,
    );
  }
}

// ============================
// Screens
// ============================
class KhidmetiUsersApp extends StatefulWidget {
  const KhidmetiUsersApp({super.key});
  @override
  State<KhidmetiUsersApp> createState() => _KhidmetiUsersAppState();
}

class _KhidmetiUsersAppState extends State<KhidmetiUsersApp> {
  bool _initialized = false;
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khidmeti Users',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryYellow, background: kBackgroundColor),
        scaffoldBackgroundColor: kBackgroundColor,
        useMaterial3: true,
        textTheme: TextTheme(
          titleLarge: kHeadingStyle,
          titleMedium: kSubheadingStyle,
          bodyMedium: kBodyStyle,
        ),
      ),
      home: !_initialized ? const SizedBox.shrink() : const SplashScreen(),
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
    Future.delayed(const Duration(seconds: 2), () => _go());
  }

  void _go() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ModernHeader(title: 'Khidmeti'),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Lottie.asset('assets/animations/splash_animation.json', repeat: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModernHeader(title: 'Bienvenue'),
              const SizedBox(height: 24),
              Text('Connexion', style: kHeadingStyle),
              const SizedBox(height: 12),
              PaytoneCard(
                child: Column(
                  children: [
                    TextField(decoration: _inputDecoration('Email')),
                    const SizedBox(height: 12),
                    TextField(obscureText: true, decoration: _inputDecoration('Mot de passe')),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        BubbleButton(label: 'Se connecter', icon: Icons.login, onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                        }),
                        const SizedBox(width: 12),
                        BubbleButton(label: 'Créer un compte', icon: Icons.person_add, onPressed: () {}),
                      ],
                    )
                  ],
                ),
              ),
              const Spacer(),
              Center(child: Lottie.asset('assets/animations/login_animation.json', height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernHeader(
              title: 'Trouver un pro',
              trailing: BubbleButton(label: 'Profil', icon: Icons.person, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(kPadding),
                child: PaytoneCard(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: const LatLng(36.752887, 3.042048),
                        initialZoom: 12,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        // In real app: markers streamed from Firestore workers where visibilityOnMap == true
                        // Example stream usage (pseudo-UI):
                        // StreamBuilder<List<Map<String, dynamic>>>(
                        //   stream: FirestoreDatabaseService().listenCollection('workers', where: (q) => q.where('visibilityOnMap', isEqualTo: true)),
                        //   builder: (context, snapshot) {
                        //     final docs = snapshot.data ?? [];
                        //     return MarkerLayer(markers: docs.map((d) {
                        //       final gp = d['location'] as GeoPoint?;
                        //       if (gp == null) return null;
                        //       return Marker(
                        //         point: LatLng(gp.latitude, gp.longitude),
                        //         child: Icon(Icons.location_pin, color: kPrimaryRed, size: 32),
                        //       );
                        //     }).whereType<Marker>().toList());
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kPadding),
              child: Row(
                children: [
                  Expanded(child: BubbleButton(label: 'Recherche', icon: Icons.search, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())))),
                  const SizedBox(width: 12),
                  Expanded(child: BubbleButton(label: 'Messages', icon: Icons.chat_bubble, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())))),
                ],
              ),
            )
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
          children: [
            const ModernHeader(title: 'Recherche'),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(kPadding),
                itemBuilder: (_, i) => PaytoneCard(
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/avatars/users/avatar_user_${(i % 10) + 1}.svg', height: 48),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Service ${(i + 1)}', style: kSubheadingStyle)),
                      BubbleButton(label: 'Voir', icon: Icons.chevron_right, onPressed: () {}),
                    ],
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: 6,
              ),
            )
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
            const ModernHeader(title: 'Messages'),
            Expanded(child: Center(child: Lottie.asset('assets/animations/chat_typing.json'))),
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
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModernHeader(title: 'Profil'),
              const SizedBox(height: 16),
              PaytoneCard(
                child: Row(
                  children: [
                    SvgPicture.asset('assets/avatars/users/avatar_user_1.svg', height: 64),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Utilisateur Khidmeti', style: kSubheadingStyle),
                        const SizedBox(height: 6),
                        Text('Sélectionnez votre avatar', style: kBodyStyle),
                      ]),
                    ),
                    BubbleButton(label: 'Changer', icon: Icons.edit, onPressed: () {}),
                  ],
                ),
              ),
              const Spacer(),
              Center(child: Lottie.asset('assets/animations/success_animation.json', height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================
// Utils
// ============================
String _toHex(Color c) => '#${c.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
Color? _parseHex(dynamic s) {
  if (s is! String) return null;
  final hex = s.replaceAll('#', '');
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return null;
  return Color(value);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  runApp(const KhidmetiUsersApp());
}
