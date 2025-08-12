import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';

// ============================
// Design Tokens - Paytone One (Pro variant)
// ============================
const Color kPrimaryYellow = Color(0xFFFCDC73);
const Color kPrimaryRed = Color(0xFFE76268);
const Color kPrimaryDark = Color(0xFF193948);
const Color kPrimaryTeal = Color(0xFF4FADCD);

const Color kBackgroundColor = Color(0xFFF7FAFC);
const Color kSurfaceColor = Color(0xFFFFFFFF);
const Color kTextColor = Color(0xFF193948);
const Color kSubtitleColor = Color(0xFF6B7280);
const Color kSuccessColor = Color(0xFF10B981);
const Color kErrorColor = Color(0xFFE76268);

const Color kButton3DLight = Color(0xFFE6F4F9);
const Color kButton3DShadow = Color(0xFF0F172A);
const Color kButtonGradient1 = Color(0xFF4FADCD);
const Color kButtonGradient2 = Color(0xFF193948);

const double kBorderRadius = 20.0;
const double kElevation = 8.0;
const double kPadding = 16.0;

// Flags
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
// Models (Worker)
// ============================
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'selectedAvatar': avatarAssetPath,
        'businessStyle': {
          'primaryColor': _toHex(primaryColor),
          'accentColor': _toHex(accentColor),
        },
        'subscriptionStatus': subscriptionStatus,
        'visibilityOnMap': visibilityOnMap,
        'verificationStatus': verificationStatus,
        'location': location,
      };
}

// ============================
// SOLID Services (Worker)
// ============================
abstract class AuthenticationService {
  Future<User?> signInWithEmail(String email, String password);
  Future<void> signOut();
}

abstract class DatabaseService {
  Future<void> createDocument(String collection, String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getDocument(String collection, String id);
}

abstract class LocationService {
  Future<Position> getCurrentLocation();
  Stream<Position> getLocationStream();
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

class WorkerService {
  final DatabaseService _db;
  final LocationService _location;
  WorkerService(this._db, this._location);

  Future<void> verifyIdentity({required String workerId}) async {
    await _db.createDocument('workers', workerId, {
      'verificationStatus': 'verified',
    });
  }

  Future<void> renewSubscription({required String workerId}) async {
    // Mark subscription active and enable map visibility
    final pos = await _location.getCurrentLocation();
    await _db.createDocument('workers', workerId, {
      'subscriptionStatus': 'active',
      'visibilityOnMap': true,
      'location': GeoPoint(pos.latitude, pos.longitude),
    });
  }
}

class AvatarService {
  static const List<String> workerAvatars = [
    'assets/avatars/workers/avatar_worker_1.svg',
    'assets/avatars/workers/avatar_worker_2.svg',
    'assets/avatars/workers/avatar_worker_3.svg',
    'assets/avatars/workers/avatar_worker_4.svg',
    'assets/avatars/workers/avatar_worker_5.svg',
    'assets/avatars/workers/avatar_worker_6.svg',
    'assets/avatars/workers/avatar_worker_7.svg',
    'assets/avatars/workers/avatar_worker_8.svg',
    'assets/avatars/workers/avatar_worker_9.svg',
    'assets/avatars/workers/avatar_worker_10.svg',
  ];

  String getRandomWorkerAvatar() {
    final rnd = Random();
    return workerAvatars[rnd.nextInt(workerAvatars.length)];
  }

  List<String> getAllWorkerAvatars() => workerAvatars;
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
        color: Color(0xFFF0F5F8),
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
          Text(title, style: kHeadingStyle.copyWith(color: kPrimaryDark)),
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
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.paytoneOne(color: Colors.white, fontSize: 16)),
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
class KhidmetiWorkersApp extends StatefulWidget {
  const KhidmetiWorkersApp({super.key});
  @override
  State<KhidmetiWorkersApp> createState() => _KhidmetiWorkersAppState();
}

class _KhidmetiWorkersAppState extends State<KhidmetiWorkersApp> {
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
      title: 'Khidmeti Workers',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryTeal, background: Colors.white),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        textTheme: TextTheme(
          titleLarge: kHeadingStyle,
          titleMedium: kSubheadingStyle,
          bodyMedium: kBodyStyle,
        ),
      ),
      home: !_initialized ? const SizedBox.shrink() : const WorkerSplashScreen(),
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
    Future.delayed(const Duration(seconds: 2), () => _go());
  }

  void _go() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const WorkerAuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ModernHeader(title: 'Khidmeti Pro'),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Lottie.asset('assets/animations/splash_workers_background.json', repeat: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkerAuthScreen extends StatelessWidget {
  const WorkerAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModernHeader(title: 'Connexion Pro'),
              const SizedBox(height: 24),
              Text('Connectez-vous', style: kHeadingStyle),
              const SizedBox(height: 12),
              PaytoneCard(
                child: Column(
                  children: [
                    TextField(decoration: _inputDecoration('Email pro')),
                    const SizedBox(height: 12),
                    TextField(obscureText: true, decoration: _inputDecoration('Mot de passe')),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        BubbleButton(label: 'Entrer', icon: Icons.login, onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WorkerDashboardScreen()));
                        }),
                        const SizedBox(width: 12),
                        BubbleButton(label: 'Créer compte', icon: Icons.person_add, onPressed: () {}),
                      ],
                    )
                  ],
                ),
              ),
              const Spacer(),
              Center(child: Lottie.asset('assets/animations/worker_verification.json', height: 120)),
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

class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreDatabaseService();
    final location = GeolocatorLocationService();
    final service = WorkerService(db, location);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModernHeader(
                title: 'Tableau de bord',
                trailing: BubbleButton(label: 'Profil', icon: Icons.person, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkerProfileScreen()))),
              ),
              const SizedBox(height: 12),
              PaytoneCard(
                child: Row(
                  children: [
                    Expanded(child: Text('Vérification identité', style: kSubheadingStyle)),
                    BubbleButton(label: 'Vérifier', icon: Icons.verified, onPressed: () async {
                      await service.verifyIdentity(workerId: 'demo-worker');
                      if (context.mounted) _showSnack(context, 'Identité vérifiée');
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PaytoneCard(
                child: Row(
                  children: [
                    Expanded(child: Text('Abonnement', style: kSubheadingStyle)),
                    BubbleButton(label: 'Renouveler', icon: Icons.credit_card, onPressed: () async {
                      await service.renewSubscription(workerId: 'demo-worker');
                      if (context.mounted) _showSnack(context, 'Abonnement actif et visibilité sur la carte');
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            children: [
              const ModernHeader(title: 'Profil Pro'),
              const SizedBox(height: 16),
              PaytoneCard(
                child: Row(
                  children: [
                    SvgPicture.asset('assets/avatars/workers/avatar_worker_1.svg', height: 64),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Travailleur Khidmeti', style: kSubheadingStyle)),
                    BubbleButton(label: 'Changer', icon: Icons.edit, onPressed: () {}),
                  ],
                ),
              ),
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  runApp(const KhidmetiWorkersApp());
}
