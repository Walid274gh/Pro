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
import 'dart:io';
import 'dart:convert';

// ============================================================================
// 🎨 PALETTE DE COULEURS PAYTONE ONE
// ============================================================================

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

// ============================================================================
// 🎭 STYLES TYPOGRAPHIQUES MODERNES
// ============================================================================

TextStyle get kHeadingStyle => GoogleFonts.paytoneOne(
  fontSize: 24,
  fontWeight: FontWeight.bold,
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

// ============================================================================
// 📱 MODÈLES DE DONNÉES (Architecture SOLID)
// ============================================================================

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

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      selectedAvatar: map['selectedAvatar'] ?? 'assets/avatars/users/avatar_user_1.svg',
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      location: map['location'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'selectedAvatar': selectedAvatar,
      'preferences': preferences,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

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

  factory WorkerModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkerModel(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      selectedAvatar: map['selectedAvatar'] ?? 'assets/avatars/workers/avatar_worker_1.svg',
      services: List<String>.from(map['services'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      location: map['location'] ?? const GeoPoint(0, 0),
      isAvailable: map['isAvailable'] ?? false,
      isVisible: map['isVisible'] ?? true,
      portfolio: Map<String, dynamic>.from(map['portfolio'] ?? {}),
    );
  }
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
    this.workerId,
    required this.serviceType,
    required this.description,
    required this.mediaUrls,
    required this.location,
    required this.scheduledDate,
    required this.status,
    this.finalPrice,
  });
}

// ============================================================================
// 🔧 SERVICES (Architecture SOLID - SRP, DIP)
// ============================================================================

abstract class AuthenticationService {
  Future<UserModel?> signInWithEmail(String email, String password);
  Future<void> signOut();
}

abstract class DatabaseService {
  Future<void> createDocument(String collection, String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getDocument(String collection, String id);
}

abstract class Readable {
  Future<T?> read<T>(String id);
}

abstract class Writable {
  Future<void> write<T>(String id, T data);
}

class AuthService implements AuthenticationService {
  final FirebaseAuth _auth;
  final DatabaseService _databaseService;

  AuthService(this._auth, this._databaseService);

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        final userData = await _databaseService.getDocument('users', userCredential.user!.uid);
        if (userData != null) {
          return UserModel.fromMap(userData, userCredential.user!.uid);
        }
      }
      return null;
    } catch (e) {
      print('Erreur d\'authentification: $e');
      return null;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    // Implémentation Google Sign-In
    return null;
  }

  Future<UserModel?> signInWithFacebook() async {
    // Implémentation Facebook Sign-In
    return null;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

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
    // Implémentation générique
    return null;
  }

  @override
  Future<void> write<T>(String id, T data) async {
    // Implémentation générique
  }

  Stream<List<WorkerModel>> getAvailableWorkers(GeoPoint userLocation, double radiusKm) {
    return _firestore
        .collection('workers')
        .where('isAvailable', isEqualTo: true)
        .where('isVisible', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkerModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

class AvatarService {
  static const List<String> userAvatars = [
    'assets/avatars/users/avatar_user_1.svg',
    'assets/avatars/users/avatar_user_2.svg',
    'assets/avatars/users/avatar_user_3.svg',
  ];

  String getRandomUserAvatar() {
    return userAvatars[DateTime.now().millisecondsSinceEpoch % userAvatars.length];
  }

  List<String> getAllUserAvatars() => userAvatars;
}

// ============================================================================
// 🎨 WIDGETS RÉUTILISABLES
// ============================================================================

class ModernCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget illustration;
  final VoidCallback onTap;
  final Color backgroundColor;

  const ModernCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.illustration,
    required this.onTap,
    this.backgroundColor = kPrimaryYellow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
                  style: kBodyStyle,
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
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.primaryColor = kPrimaryDark,
    this.textColor = Colors.white,
    this.width = 200,
    this.height = 56,
  }) : super(key: key);

  @override
  State<BubbleButton> createState() => _BubbleButtonState();
}

class _BubbleButtonState extends State<BubbleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
            scale: _scaleAnimation.value,
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
                    offset: Offset(0, _elevationAnimation.value),
                    blurRadius: _elevationAnimation.value * 2,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.textColor,
                      size: 20,
                    ),
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
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.showBackButton = false,
  }) : super(key: key);

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
            Expanded(
              child: Text(
                title,
                style: kHeadingStyle.copyWith(fontSize: 20),
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

// ============================================================================
// 📱 ÉCRANS PRINCIPAUX (SANS APPBAR)
// ============================================================================

class KhidmetiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khidmeti',
      theme: ThemeData(
        primaryColor: kPrimaryYellow,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryYellow,
          background: kBackgroundColor,
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToHome();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _logoController.repeat();
    _backgroundController.repeat();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // Animation arrière-plan
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/splash_animation.json',
              controller: _backgroundController,
              fit: BoxFit.cover,
            ),
          ),

          // Logo principal
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
                  style: kHeadingStyle.copyWith(
                    color: kPrimaryDark,
                    fontSize: 18,
                  ),
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
    _backgroundController.dispose();
    super.dispose();
  }
}

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

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

              // Animation de connexion
              Lottie.asset(
                'assets/animations/splash_animation.json',
                height: 200,
              ),

              const SizedBox(height: 32),

              // Titre principal
              Text(
                _isLogin ? 'Bon retour !' : 'Rejoignez-nous',
                style: kHeadingStyle.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Formulaire
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bouton principal
              BubbleButton(
                text: _isLogin ? 'Se connecter' : 'S\'inscrire',
                onPressed: _handleAuth,
                primaryColor: kPrimaryDark,
                width: double.infinity,
                height: 56,
              ),

              const SizedBox(height: 24),

              // Boutons sociaux
              Row(
                children: [
                  Expanded(
                    child: BubbleButton(
                      text: 'Google',
                      onPressed: _signInWithGoogle,
                      primaryColor: kPrimaryRed,
                      icon: Icons.google,
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BubbleButton(
                      text: 'Facebook',
                      onPressed: _signInWithFacebook,
                      primaryColor: kPrimaryTeal,
                      icon: Icons.facebook,
                      height: 48,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Basculer mode
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? 'Pas encore de compte ? S\'inscrire'
                      : 'Déjà un compte ? Se connecter',
                  style: kBodyStyle.copyWith(color: kPrimaryDark),
                ),
              ),
            ],
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimaryDark.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: kPrimaryTeal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  void _handleAuth() async {
    // Logique d'authentification
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _signInWithGoogle() async {
    // Authentification Google
  }

  void _signInWithFacebook() async {
    // Authentification Facebook
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const SearchView(),
    const MapView(),
    const RequestsView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
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
        onTap: (index) => setState(() => _currentIndex = index),
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

// ============================================================================
// 🏠 VUES PRINCIPALES
// ============================================================================

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header personnalisé
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/avatars/users/avatar_user_1.svg',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour !',
                            style: kHeadingStyle.copyWith(fontSize: 20),
                          ),
                          Text(
                            'Que recherchez-vous aujourd\'hui ?',
                            style: kBodyStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Services populaires
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Services populaires',
                  style: kHeadingStyle.copyWith(fontSize: 22),
                ),
              ),

              const SizedBox(height: 16),

              // Cards de services
              ModernCard(
                title: 'Plomberie',
                subtitle: 'Réparation et installation',
                illustration: Icon(Icons.plumbing, size: 60, color: kPrimaryDark),
                onTap: () {},
                backgroundColor: kPrimaryYellow,
              ),

              ModernCard(
                title: 'Électricité',
                subtitle: 'Installation et dépannage',
                illustration: Icon(Icons.electrical_services, size: 60, color: kPrimaryDark),
                onTap: () {},
                backgroundColor: kPrimaryTeal,
              ),

              ModernCard(
                title: 'Nettoyage',
                subtitle: 'Ménage et entretien',
                illustration: Icon(Icons.cleaning_services, size: 60, color: kPrimaryDark),
                onTap: () {},
                backgroundColor: kPrimaryRed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchView extends StatelessWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Rechercher un service',
                style: kHeadingStyle.copyWith(fontSize: 24),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Fonctionnalité en cours de développement',
                  style: kBodyStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapView extends StatelessWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Carte des services',
                style: kHeadingStyle.copyWith(fontSize: 24),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Carte OpenStreetMap en cours de développement',
                  style: kBodyStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestsView extends StatelessWidget {
  const RequestsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Mes demandes',
                style: kHeadingStyle.copyWith(fontSize: 24),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Historique des demandes en cours de développement',
                  style: kBodyStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Mon profil',
                style: kHeadingStyle.copyWith(fontSize: 24),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Gestion du profil en cours de développement',
                  style: kBodyStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 🚀 POINT D'ENTRÉE PRINCIPAL
// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation Firebase
  await Firebase.initializeApp();
  
  runApp(KhidmetiApp());
}
