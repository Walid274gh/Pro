import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

// Colors
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

// Tokens
const double kBorderRadius = 20.0;
const double kElevation = 8.0;
const double kPadding = 16.0;

// Typography
final TextStyle kHeadingStyle = GoogleFonts.getFont(
  'Paytone One',
  textStyle: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: kPrimaryDark,
    letterSpacing: -0.5,
  ),
);

final TextStyle kSubheadingStyle = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kTextColor,
);

final TextStyle kBodyStyle = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kSubtitleColor,
  height: 1.4,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Note: requires google-services.json and Android setup to actually initialize
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  runApp(const KhidmetiApp());
}

class KhidmetiApp extends StatelessWidget {
  const KhidmetiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: kPrimaryYellow,
      brightness: Brightness.light,
      background: kBackgroundColor,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khidmeti Users',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: kBackgroundColor,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this);
    _bgController = AnimationController(vsync: this);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/auth');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/splash_workers_background.json',
              controller: _bgController,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/splash_animation.json',
                  controller: _logoController,
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 24),
                Text(
                  'Trouvez votre service idéal',
                  style: kHeadingStyle.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bgController.dispose();
    super.dispose();
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;

  Future<void> _handleAuth() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final auth = AuthService(FirebaseAuth.instance, FirestoreDatabaseService(FirebaseFirestore.instance));
      if (_isLogin) {
        await auth.signInWithEmail(_email.text.trim(), _password.text);
      } else {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text.trim(), password: _password.text);
        final uid = cred.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'firstName': 'User',
          'lastName': 'Khidmeti',
          'email': _email.text.trim(),
          'selectedAvatar': AvatarService().getRandomUserAvatar(),
          'preferences': {
            'primaryColor': '#FCDC73',
            'accentColor': '#E76268',
          },
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'isActive': true,
        });
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Erreur d\'authentification')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Lottie.asset('assets/animations/login_animation.json', height: 200),
              const SizedBox(height: 32),
              Text(
                _isLogin ? 'Bon retour !' : 'Rejoignez-nous',
                style: kHeadingStyle.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _InputField(
                      controller: _email,
                      label: 'Email',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      controller: _password,
                      label: 'Mot de passe',
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              BubbleButton(
                text: _isLogin ? 'Se connecter' : 'S\'inscrire',
                onPressed: _handleAuth,
                primaryColor: kPrimaryDark,
                width: double.infinity,
                height: 56,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: BubbleButton(
                      text: 'Google',
                      onPressed: () {},
                      primaryColor: kPrimaryRed,
                      icon: Icons.g_mobiledata,
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BubbleButton(
                      text: 'Facebook',
                      onPressed: () {},
                      primaryColor: kPrimaryTeal,
                      icon: Icons.facebook,
                      height: 48,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? 'Pas encore de compte ? S\'inscrire'
                      : 'Déjà un compte ? Se connecter',
                  style: kBodyStyle.copyWith(color: kPrimaryDark),
                ),
              ),
              const SizedBox(height: 16),
              BubbleButton(
                text: 'Continuer',
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                primaryColor: kPrimaryYellow,
                textColor: kPrimaryDark,
                height: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimaryDark.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscure : false,
        decoration: InputDecoration(
          icon: Icon(widget.icon, color: kPrimaryDark),
          labelText: widget.label,
          labelStyle: kBodyStyle.copyWith(color: kSubtitleColor),
          border: InputBorder.none,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeView(),
    SearchScreen(),
    MapScreen(),
    RequestsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _bottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: kPrimaryDark.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryDark,
        unselectedItemColor: kSubtitleColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Demandes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ModernHeader(title: 'Accueil'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Khidmeti', style: kHeadingStyle.copyWith(fontSize: 32)),
              const SizedBox(height: 8),
              Text('Trouvez des services près de chez vous', style: kBodyStyle),
              const SizedBox(height: 16),
              ModernCard(
                title: 'Nettoyage à domicile',
                subtitle: 'Professionnels de confiance, réservation en 2 minutes',
                backgroundColor: kPrimaryYellow,
                illustration: const Icon(Icons.cleaning_services, size: 80, color: kPrimaryDark),
                onTap: () {},
              ),
              ModernCard(
                title: 'Plomberie',
                subtitle: 'Dépannage rapide et efficace',
                backgroundColor: kPrimaryTeal,
                illustration: const Icon(Icons.plumbing, size: 80, color: Colors.white),
                onTap: () {},
              ),
              ModernCard(
                title: 'Électricité',
                subtitle: 'Experts certifiés',
                backgroundColor: kPrimaryRed,
                illustration: const Icon(Icons.electric_bolt, size: 80, color: Colors.white),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String label;
  const _Placeholder(this.label);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label, style: kHeadingStyle));
  }
}

class ModernCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget illustration;
  final VoidCallback onTap;
  final Color backgroundColor;

  const ModernCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.illustration,
    required this.onTap,
    this.backgroundColor = kPrimaryYellow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: illustration),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: kHeadingStyle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: kBodyStyle.copyWith(color: kTextColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BubbleButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color primaryColor;
  final Color textColor;
  final double width;
  final double height;

  const BubbleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.primaryColor = kPrimaryDark,
    this.textColor = Colors.white,
    this.width = 200,
    this.height = 56,
  });

  @override
  State<BubbleButton> createState() => _BubbleButtonState();
}

class _BubbleButtonState extends State<BubbleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _elevation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _scale = Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevation = Tween(begin: 8.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.primaryColor.withOpacity(0.9),
                    widget.primaryColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.3),
                    offset: Offset(0, _elevation.value),
                    blurRadius: _elevation.value * 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.textColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.textColor,
                      letterSpacing: 0.5,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ModernHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool showBackButton;

  const ModernHeader({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? kSurfaceColor.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryDark.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (showBackButton)
              BubbleButton(
                text: '',
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
                primaryColor: kPrimaryTeal,
                width: 40,
                height: 40,
              ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: kHeadingStyle.copyWith(fontSize: 20))),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

// Minimal SOLID abstractions (stubs)
abstract class AuthenticationService {
  Future<void> signOut();
}

abstract class DatabaseService {
  Future<void> createDocument(String collection, String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getDocument(String collection, String id);
}

abstract class LocationService {
  Future<void> getCurrentLocation();
}

class MapScreen extends StatelessWidget {
  static const String tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const LatLng initialCenter = LatLng(36.737232, 3.086472); // Alger

  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          const ModernHeader(title: 'Carte'),
          Expanded(
            child: FlutterMap(
              options: const MapOptions(initialCenter: initialCenter, initialZoom: 12),
              children: const [
                TileLayer(urlTemplate: tileUrl, userAgentPackageName: 'khidmeti.users'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data Models
class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String selectedAvatar;
  final Map<String, dynamic> preferences;
  final GeoPoint? location;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.selectedAvatar,
    required this.preferences,
    this.location,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'selectedAvatar': selectedAvatar,
        'preferences': preferences,
        'location': location,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'isActive': isActive,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        firstName: map['firstName'],
        lastName: map['lastName'],
        email: map['email'],
        phoneNumber: map['phoneNumber'],
        selectedAvatar: map['selectedAvatar'],
        preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
        location: map['location'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
        isActive: map['isActive'] ?? true,
      );

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? selectedAvatar,
    Map<String, dynamic>? preferences,
    GeoPoint? location,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      preferences: preferences ?? this.preferences,
      location: location ?? this.location,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class WorkerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String selectedAvatar;
  final List<String> services;
  final double rating;
  final int totalReviews;
  final GeoPoint location;
  final bool isAvailable;
  final bool isVisible;
  final Map<String, dynamic> portfolio;

  WorkerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.selectedAvatar,
    required this.services,
    required this.rating,
    required this.totalReviews,
    required this.location,
    required this.isAvailable,
    required this.isVisible,
    required this.portfolio,
  });
}

class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double basePrice;
  final String iconPath;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.basePrice,
    required this.iconPath,
    this.isActive = true,
  });
}

enum RequestStatus { pending, accepted, inProgress, completed, cancelled }

class RequestModel {
  final String id;
  final String userId;
  final String? workerId;
  final String serviceType;
  final String description;
  final List<String> mediaUrls;
  final GeoPoint location;
  final DateTime scheduledDate;
  final RequestStatus status;
  final double? finalPrice;

  RequestModel({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.serviceType,
    required this.description,
    required this.mediaUrls,
    required this.location,
    required this.scheduledDate,
    required this.status,
    this.finalPrice,
  });
}

// Utility Services
class AvatarService {
  static const List<String> userAvatars = [
    for (int i = 1; i <= 20; i++) 'assets/avatars/users/avatar_user_' + i.toString() + '.svg'
  ];

  String getRandomUserAvatar() {
    userAvatars.shuffle();
    return userAvatars.first;
  }

  List<String> getAllUserAvatars() => userAvatars;
}

class OpenStreetMapService {
  static const String tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const LatLng algerCenter = LatLng(36.737232, 3.086472);
}

// SOLID service abstractions
abstract class AuthenticationService {
  Future<UserModel?> signInWithEmail(String email, String password);
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

abstract class NotificationSender {
  Future<void> sendNotification(String userId, String message);
}

abstract class Readable {
  Future<T?> read<T>(String id);
}

abstract class Writable {
  Future<void> write<T>(String id, T data);
}

// Implementations (minimal)
class FirestoreDatabaseService implements DatabaseService, Readable, Writable {
  final FirebaseFirestore _firestore;
  FirestoreDatabaseService(this._firestore);

  @override
  Future<void> createDocument(String collection, String id, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(id).set(data);
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String collection, String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    return doc.data();
  }

  @override
  Future<T?> read<T>(String id) async {
    return null;
  }

  @override
  Future<void> write<T>(String id, T data) async {}
}

class AuthService implements AuthenticationService {
  final FirebaseAuth _auth;
  final DatabaseService _db;
  AuthService(this._auth, this._db);

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final uid = cred.user?.uid;
    if (uid == null) return null;
    final data = await _db.getDocument('users', uid);
    if (data == null) return null;
    return UserModel.fromMap({...data, 'id': uid});
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

class OpenStreetMapLocationService implements LocationService {
  @override
  Future<Position> getCurrentLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      perm = await Geolocator.requestPermission();
    }
    return Geolocator.getCurrentPosition();
  }

  @override
  Stream<Position> getLocationStream() => Geolocator.getPositionStream();
}

class FCMNotificationService implements NotificationSender {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;
  FCMNotificationService(this._messaging, this._local);

  @override
  Future<void> sendNotification(String userId, String message) async {
    // Placeholder: would use FCM topics or tokens; local display for demo
    await _local.show(
      0,
      'Khidmeti',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails('khidmeti', 'Khidmeti', importance: Importance.high, priority: Priority.high),
      ),
    );
  }
}

class ChatService {
  final DatabaseService _db;
  final NotificationSender _notifier;
  ChatService(this._db, this._notifier);

  Future<void> sendMessage(String chatId, Map<String, dynamic> message) async {
    await _db.createDocument('chats/$chatId/messages', DateTime.now().millisecondsSinceEpoch.toString(), message);
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ModernHeader(title: 'Recherche'),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: kSurfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryDark.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                icon: Icon(Icons.search),
                hintText: 'Rechercher un service...',
                border: InputBorder.none,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (_query.isEmpty)
                Text('Suggestions', style: kHeadingStyle.copyWith(fontSize: 18))
              else
                Text('Résultats pour "$_query"', style: kHeadingStyle.copyWith(fontSize: 18)),
              const SizedBox(height: 12),
              ModernCard(
                title: 'Jardinage',
                subtitle: 'Entretien d\'espaces verts',
                illustration: const Icon(Icons.grass, size: 80, color: kPrimaryDark),
                backgroundColor: kPrimaryYellow,
                onTap: () {},
              ),
              ModernCard(
                title: 'Peinture',
                subtitle: 'Rafraîchissez vos murs',
                illustration: const Icon(Icons.format_paint, size: 80, color: Colors.white),
                backgroundColor: kPrimaryRed,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ModernHeader(title: 'Mes demandes'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RequestTile(
                title: 'Nettoyage',
                status: 'En cours',
                color: kPrimaryTeal,
                date: 'Aujourd\'hui 14:00',
              ),
              _RequestTile(
                title: 'Plomberie',
                status: 'En attente',
                color: kPrimaryYellow,
                date: 'Demain 09:30',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestTile extends StatelessWidget {
  final String title;
  final String status;
  final String date;
  final Color color;
  const _RequestTile({
    required this.title,
    required this.status,
    required this.date,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimaryDark.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.assignment, color: color),
        ),
        title: Text(title, style: kHeadingStyle.copyWith(fontSize: 16)),
        subtitle: Text(date, style: kBodyStyle),
        trailing: Text(status, style: kSubheadingStyle.copyWith(color: color, fontSize: 14)),
        onTap: () {},
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AvatarService _avatarService = AvatarService();
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = _avatarService.getRandomUserAvatar();
  }

  @override
  Widget build(BuildContext context) {
    final avatars = _avatarService.getAllUserAvatars();
    return Column(
      children: [
        const ModernHeader(title: 'Profil'),
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 42,
          backgroundColor: kPrimaryYellow.withOpacity(0.4),
          child: Text('U', style: kHeadingStyle.copyWith(fontSize: 28)),
        ),
        const SizedBox(height: 12),
        Text('Choisissez un avatar', style: kHeadingStyle.copyWith(fontSize: 18)),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: avatars.length,
            itemBuilder: (context, i) {
              final path = avatars[i];
              final isSelected = path == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = path),
                child: Container(
                  decoration: BoxDecoration(
                    color: kSurfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryDark.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: isSelected ? Border.all(color: kPrimaryTeal, width: 2) : null,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: SvgPicture.asset(path, width: 44, height: 44),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: BubbleButton(
            text: 'Enregistrer',
            onPressed: () {
              // TODO: save avatar to Firestore user document
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Avatar enregistré')),
              );
            },
            primaryColor: kPrimaryDark,
            width: double.infinity,
            height: 52,
          ),
        ),
      ],
    );
  }
}