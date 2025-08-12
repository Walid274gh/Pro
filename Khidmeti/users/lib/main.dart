import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KHIDMETI Users',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: const Locale('fr'),
      home: const UsersAppShell(),
    );
  }
}

class UsersAppShell extends StatefulWidget {
  const UsersAppShell({super.key});

  @override
  State<UsersAppShell> createState() => _UsersAppShellState();
}

class _UsersAppShellState extends State<UsersAppShell> {
  int _currentIndex = 0;

  List<Widget> get _pages => <Widget>[
        _buildPage('Accueil', 'Recommandations de travailleurs'),
        _buildPage('Recherche', 'Carte des travailleurs disponibles'),
        _buildPage('Demande', 'Publier une demande avec médias et localisation'),
        _buildPage('Paramètres', 'Langue, déconnexion, infos'),
      ];

  static Widget _buildPage(String title, String subtitle) {
    return Scaffold(
      backgroundColor: AppTheme.kBackgroundColor,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppTheme.kHeadingStyle),
            const SizedBox(height: 12),
            Text(subtitle, style: AppTheme.kBodyStyle),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.kPrimaryDark,
        unselectedItemColor: AppTheme.kSubtitleColor,
        backgroundColor: AppTheme.kPrimaryYellow,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded), label: 'Demande'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Paramètres'),
        ],
        onTap: (int index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<void> initialize() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final String? token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM token (Users): $token');
  }
}

class AuthService {
  AuthService({fb.FirebaseAuth? auth}) : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  fb.User? get currentUser => _auth.currentUser;

  Future<fb.UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    final fb.UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName('$firstName $lastName');
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Optionally store phone in user profile via custom claims or Firestore later
    }
    return cred;
  }

  Future<fb.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendEmailVerification() async {
    final fb.User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> startPhoneNumberVerification({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String verificationId, int? forceResendingToken) onTimeout,
    required void Function(fb.PhoneAuthCredential credential) onVerified,
    required void Function(fb.FirebaseAuthException error) onFailed,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerified,
      verificationFailed: onFailed,
      codeSent: (String verificationId, int? resendToken) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (String verificationId) => onTimeout(verificationId, forceResendingToken),
      forceResendingToken: forceResendingToken,
    );
  }

  Future<fb.UserCredential> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final fb.PhoneAuthCredential credential = fb.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }
}

class FirestoreProfileRepository {
  FirestoreProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _profilesCol =>
      _firestore.collection('profiles');

  Future<void> upsertProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    final now = FieldValue.serverTimestamp();
    final DocumentReference<Map<String, dynamic>> doc = _profilesCol.doc(uid);
    await doc.set(
      <String, dynamic>{
        'updatedAt': now,
        ...data,
      },
      SetOptions(merge: true),
    );
    await doc.set(
      <String, dynamic>{
        'createdAt': now,
      },
      SetOptions(merge: true),
    );
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final snap = await _profilesCol.doc(uid).get();
    if (!snap.exists) return null;
    return snap.data();
  }

  Stream<Map<String, dynamic>?> streamProfile(String uid) {
    return _profilesCol.doc(uid).snapshots().map((d) => d.data());
  }

  Future<void> addFcmToken({required String uid, required String token}) async {
    await _profilesCol.doc(uid).set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setOnlineStatus({required String uid, required bool isOnline}) async {
    await _profilesCol.doc(uid).set(
      {
        'isOnline': isOnline,
        'lastSeenAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateLocation({
    required String uid,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
  }) async {
    await _profilesCol.doc(uid).set(
      {
        'lastKnownLocation': GeoPoint(latitude, longitude),
        if (accuracyMeters != null) 'locationAccuracyM': accuracyMeters,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> ensureUniqueIdCardHash({
    required String uid,
    required String idCardHash,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> existing = await _profilesCol
        .where('idCardHash', isEqualTo: idCardHash)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty && existing.docs.first.id != uid) {
      throw StateError('ID card already used by another account');
    }
    await _profilesCol.doc(uid).set(
      {
        'idCardHash': idCardHash,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

class StorageService {
  StorageService({FirebaseStorage? storage, required String role})
      : _storage = storage ?? FirebaseStorage.instance,
        _role = role;

  final FirebaseStorage _storage;
  final String _role; // 'users' or 'workers'

  String _buildPath({
    required String uid,
    required String category,
    required String fileName,
  }) => '$_role/$uid/$category/$fileName';

  Future<String> uploadData({
    required String uid,
    required Uint8List data,
    required String category,
    required String extension,
    String? fileName,
    String? contentType,
  }) async {
    final String safeExt = extension.replaceAll('.', '').toLowerCase();
    final String inferredType = contentType ?? _contentTypeForExtension(safeExt);
    final String name = fileName ?? _generateFileName(safeExt);
    final String fullPath = _buildPath(uid: uid, category: category, fileName: name);
    final Reference ref = _storage.ref(fullPath);
    final SettableMetadata meta = SettableMetadata(contentType: inferredType);
    final UploadTask task = ref.putData(data, meta);
    await task.whenComplete(() {});
    return ref.getDownloadURL();
  }

  Future<void> deleteAtPath({
    required String uid,
    required String category,
    required String fileName,
  }) async {
    final String fullPath = _buildPath(uid: uid, category: category, fileName: fileName);
    await _storage.ref(fullPath).delete();
  }

  Future<ListResult> listCategory({
    required String uid,
    required String category,
  }) {
    return _storage.ref('$_role/$uid/$category').listAll();
  }

  String _generateFileName(String extension) {
    final int ts = DateTime.now().millisecondsSinceEpoch;
    final Random rand = Random.secure();
    final int salt = rand.nextInt(0xFFFFFF);
    return '$ts-$salt.$extension';
  }

  String _contentTypeForExtension(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}

class GeolocationService {
  const GeolocationService();

  Future<LocationPermission> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // The user might need to enable location services manually
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately in UI later
    }
    return permission;
  }

  Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    return Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
  }

  Stream<Position> positionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterMeters,
      ),
    );
  }
}

class RequestsRepository {
  RequestsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('requests');

  Future<String> createRequest({
    required String userUid,
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    List<String> mediaUrls = const <String>[],
  }) async {
    final String cellId = _computeCellId(latitude: latitude, longitude: longitude);
    final DocumentReference<Map<String, dynamic>> doc = await _col.add({
      'userUid': userUid,
      'title': title,
      'description': description,
      'category': category,
      'status': 'open',
      'mediaUrls': mediaUrls,
      'location': GeoPoint(latitude, longitude),
      'cellId': cellId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Stream<List<Map<String, dynamic>>> streamUserRequests(String userUid) {
    return _col
        .where('userUid', isEqualTo: userUid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((q) => q.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String status, // open, assigned, completed, cancelled
  }) async {
    await _col.doc(requestId).set(
      {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // Simple hex grid using fixed cell size in degrees (approximate)
  static const double _cellSizeDeg = 0.02; // ~2.2km latitude

  String _computeCellId({required double latitude, required double longitude}) {
    final int latKey = (latitude / _cellSizeDeg).floor();
    final int lngKey = (longitude / _cellSizeDeg).floor();
    return 'c_${latKey}_$lngKey';
  }
}

class PushNotificationService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    required FirestoreProfileRepository profileRepository,
    required String role, // 'users'
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _profileRepository = profileRepository,
        _role = role;

  final FirebaseMessaging _messaging;
  final FirestoreProfileRepository _profileRepository;
  final String _role;

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp;

  Future<void> initForSignedInUser(String uid) async {
    await _messaging.setAutoInitEnabled(true);
    final String? token = await _messaging.getToken();
    if (token != null) {
      await _profileRepository.addFcmToken(uid: uid, token: token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _profileRepository.addFcmToken(uid: uid, token: newToken);
    });
  }

  Future<void> subscribeToRequestTopic(String requestId) async {
    await _messaging.subscribeToTopic('request_$requestId');
  }

  Future<void> unsubscribeFromRequestTopic(String requestId) async {
    await _messaging.unsubscribeFromTopic('request_$requestId');
  }

  Future<void> subscribeToGeoCells(List<String> cellIds) async {
    for (final String cell in cellIds) {
      await _messaging.subscribeToTopic('geo_$cell');
    }
  }

  Future<void> unsubscribeFromGeoCells(List<String> cellIds) async {
    for (final String cell in cellIds) {
      await _messaging.unsubscribeFromTopic('geo_$cell');
    }
  }
}

class AppTheme {
  // Couleurs
  static const Color kPrimaryYellow = Color(0xFFFCDC73);
  static const Color kPrimaryRed = Color(0xFFE76268);
  static const Color kPrimaryDark = Color(0xFF193948);
  static const Color kPrimaryTeal = Color(0xFF4FADCD);
  static const Color kBackgroundColor = Color(0xFFFFF8E7);
  static const Color kSurfaceColor = Color(0xFFFFFFFF);
  static const Color kTextColor = Color(0xFF193948);
  static const Color kSubtitleColor = Color(0xFF6B7280);
  static const Color kSuccessColor = Color(0xFF10B981);
  static const Color kErrorColor = Color(0xFFE76268);
  static const Color kButton3DLight = Color(0xFFFEF3C7);
  static const Color kButton3DShadow = Color(0xFF92400E);
  static const Color kButtonGradient1 = Color(0xFFFCDC73);
  static const Color kButtonGradient2 = Color(0xFFF59E0B);

  // Typographies
  static const TextStyle kHeadingStyle = TextStyle(
    fontFamily: 'Paytone One',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: kPrimaryDark,
    letterSpacing: -0.5,
  );
  static const TextStyle kSubheadingStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: kTextColor,
  );
  static const TextStyle kBodyStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: kSubtitleColor,
    height: 1.4,
  );

  static ThemeData light() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: kPrimaryYellow,
      brightness: Brightness.light,
    ).copyWith(
      primary: kPrimaryYellow,
      onPrimary: kPrimaryDark,
      secondary: kPrimaryTeal,
      onSecondary: kPrimaryDark,
      error: kErrorColor,
      surface: kSurfaceColor,
      onSurface: kTextColor,
    );

    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: kBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimaryYellow,
        foregroundColor: kPrimaryDark,
        elevation: 4,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineSmall: kHeadingStyle,
        titleMedium: kSubheadingStyle,
        bodyMedium: kBodyStyle,
        bodySmall: kBodyStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(kPrimaryYellow),
          foregroundColor: const WidgetStatePropertyAll(kPrimaryDark),
          elevation: const WidgetStatePropertyAll(4),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}
