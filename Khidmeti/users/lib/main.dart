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
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:image_picker/image_picker.dart';

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
      home: StreamBuilder<fb.User?>(
        stream: AuthService().authStateChanges(),
        builder: (context, snapshot) {
          final fb.User? user = snapshot.data;
          if (user == null) {
            return const UsersAuthScreen();
          }
          return const UsersAppShell();
        },
      ),
    );
  }
}

class UsersAuthScreen extends StatefulWidget {
  const UsersAuthScreen({super.key});

  @override
  State<UsersAuthScreen> createState() => _UsersAuthScreenState();
}

class _UsersAuthScreenState extends State<UsersAuthScreen> {
  final AuthService _auth = AuthService();
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final TextEditingController _loginEmailCtrl = TextEditingController();
  final TextEditingController _loginPasswordCtrl = TextEditingController();

  final TextEditingController _signupFirstNameCtrl = TextEditingController();
  final TextEditingController _signupLastNameCtrl = TextEditingController();
  final TextEditingController _signupEmailCtrl = TextEditingController();
  final TextEditingController _signupPasswordCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _signupFirstNameCtrl.dispose();
    _signupLastNameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _loginEmailCtrl.text.trim(),
        password: _loginPasswordCtrl.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur connexion: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.signUpWithEmailAndPassword(
        email: _signupEmailCtrl.text.trim(),
        password: _signupPasswordCtrl.text.trim(),
        firstName: _signupFirstNameCtrl.text.trim(),
        lastName: _signupLastNameCtrl.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inscription: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBackgroundColor,
      appBar: AppBar(title: const Text('KHIDMETI Users')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppTheme.kPrimaryDark,
              unselectedLabelColor: AppTheme.kSubtitleColor,
              tabs: [
                Tab(text: 'Connexion'),
                Tab(text: 'Inscription'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildLoginForm(),
                  _buildSignupForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Bienvenue', style: AppTheme.kHeadingStyle),
            const SizedBox(height: 12),
            TextFormField(
              controller: _loginEmailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Email requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _loginPasswordCtrl,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
              validator: (v) => (v == null || v.length < 6) ? 'Min 6 caractères' : null,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading ? const Text('Connexion...') : const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Créer un compte', style: AppTheme.kHeadingStyle),
            const SizedBox(height: 12),
            TextFormField(
              controller: _signupFirstNameCtrl,
              decoration: const InputDecoration(labelText: 'Prénom'),
              validator: (v) => (v == null || v.isEmpty) ? 'Prénom requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _signupLastNameCtrl,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (v) => (v == null || v.isEmpty) ? 'Nom requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _signupEmailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Email requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _signupPasswordCtrl,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
              validator: (v) => (v == null || v.length < 6) ? 'Min 6 caractères' : null,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _signup,
              child: _loading ? const Text('Création...') : const Text('S’inscrire'),
            ),
          ],
        ),
      ),
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
        _buildHomePage(),
        _buildSearchPage(),
        _buildRequestPage(),
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

  static Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: AppTheme.kBackgroundColor,
      appBar: AppBar(title: const Text('Accueil')),
      body: const UsersHomeRecommendations(),
    );
  }

  static Widget _buildSearchPage() {
    return Scaffold(
      backgroundColor: AppTheme.kBackgroundColor,
      appBar: AppBar(title: const Text('Recherche')),
      body: const UsersSearchMap(),
    );
  }

  static Widget _buildRequestPage() {
    return Scaffold(
      backgroundColor: AppTheme.kBackgroundColor,
      appBar: AppBar(title: const Text('Demande')),
      body: const UsersRequestForm(),
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

class RatingsRepository {
  RatingsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ratingsCol =>
      _firestore.collection('ratings');
  CollectionReference<Map<String, dynamic>> get _profilesCol =>
      _firestore.collection('profiles');

  // Clé stable pour empêcher plusieurs notations par la même personne pour une demande
  String _ratingDocId({required String requestId, required String raterUid}) =>
      '${requestId}_${raterUid}';

  Future<void> addOrUpdateRating({
    required String requestId,
    required String workerUid,
    required String raterUid,
    required double score, // 1..5
    String? comment,
  }) async {
    final String docId = _ratingDocId(requestId: requestId, raterUid: raterUid);

    await _firestore.runTransaction((txn) async {
      final ratingRef = _ratingsCol.doc(docId);
      final profileRef = _profilesCol.doc(workerUid);

      final ratingSnap = await txn.get(ratingRef);
      final profileSnap = await txn.get(profileRef);

      final double prevScore = ratingSnap.exists
          ? (ratingSnap.data()!['score'] as num).toDouble()
          : 0.0;

      final Map<String, dynamic> ratingData = {
        'requestId': requestId,
        'workerUid': workerUid,
        'raterUid': raterUid,
        'score': score,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!ratingSnap.exists) 'createdAt': FieldValue.serverTimestamp(),
      };
      txn.set(ratingRef, ratingData, SetOptions(merge: true));

      double ratingSum = 0.0;
      int ratingCount = 0;
      if (profileSnap.exists) {
        final data = profileSnap.data() as Map<String, dynamic>;
        ratingSum = (data['ratingSum'] ?? 0).toDouble();
        ratingCount = (data['ratingCount'] ?? 0) as int;
      }

      if (ratingSnap.exists) {
        // Mise à jour d’une note existante
        ratingSum += (score - prevScore);
      } else {
        // Nouvelle note
        ratingSum += score;
        ratingCount += 1;
      }

      final double ratingAvg = ratingCount > 0 ? (ratingSum / ratingCount) : 0.0;
      txn.set(
        profileRef,
        {
          'ratingSum': ratingSum,
          'ratingCount': ratingCount,
          'ratingAvg': double.parse(ratingAvg.toStringAsFixed(2)),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Stream<List<Map<String, dynamic>>> streamWorkerRatings(String workerUid) {
    return _ratingsCol
        .where('workerUid', isEqualTo: workerUid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((q) => q.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}

class WorkersDiscoveryRepository {
  WorkersDiscoveryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const double _cellSizeDeg = 0.02; // ~2.2km latitude

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore.collection('profiles');

  Stream<List<Map<String, dynamic>>> streamRecommendedWorkers({
    required double latitude,
    required double longitude,
    String? category,
    int neighborRadius = 1,
    int limit = 50,
  }) {
    final List<String> targetCells = _neighborCells(latitude, longitude, neighborRadius);

    Query<Map<String, dynamic>> q = _profiles
        .where('role', isEqualTo: 'worker')
        .where('approved', isEqualTo: true)
        .where('isOnline', isEqualTo: true)
        .where('cellId', whereIn: targetCells);

    if (category != null && category.isNotEmpty) {
      q = q.where('categories', arrayContains: category);
    }

    return q.limit(limit).snapshots().map((snap) {
      final List<Map<String, dynamic>> items = snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList();

      for (final m in items) {
        final GeoPoint? gp = m['lastKnownLocation'] as GeoPoint?;
        if (gp != null) {
          m['distanceKm'] = _haversineKm(latitude, longitude, gp.latitude, gp.longitude);
        } else {
          m['distanceKm'] = 99999.0;
        }
      }

      items.sort((a, b) {
        final double ra = (a['ratingAvg'] ?? 0.0).toDouble();
        final double rb = (b['ratingAvg'] ?? 0.0).toDouble();
        final int rc = rb.compareTo(ra);
        if (rc != 0) return rc;
        final int ca = (a['ratingCount'] ?? 0) as int;
        final int cb = (b['ratingCount'] ?? 0) as int;
        final int cc = cb.compareTo(ca);
        if (cc != 0) return cc;
        final double da = (a['distanceKm'] ?? 99999.0).toDouble();
        final double db = (b['distanceKm'] ?? 99999.0).toDouble();
        return da.compareTo(db);
      });

      return items;
    });
  }

  List<String> _neighborCells(double latitude, double longitude, int radius) {
    final int latKey = (latitude / _cellSizeDeg).floor();
    final int lngKey = (longitude / _cellSizeDeg).floor();
    final List<String> cells = <String>[];
    for (int dx = -radius; dx <= radius; dx++) {
      for (int dy = -radius; dy <= radius; dy++) {
        cells.add('c_${latKey + dx}_${lngKey + dy}');
      }
    }
    return cells;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371.0;
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);
    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(_degToRad(lat1)) *
                cos(_degToRad(lat2)) *
                (sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);
}

class UsersHomeRecommendations extends StatefulWidget {
  const UsersHomeRecommendations({super.key, this.category});

  final String? category;

  @override
  State<UsersHomeRecommendations> createState() => _UsersHomeRecommendationsState();
}

class _UsersHomeRecommendationsState extends State<UsersHomeRecommendations> {
  final GeolocationService _geo = const GeolocationService();
  final WorkersDiscoveryRepository _repo = WorkersDiscoveryRepository();

  Stream<List<Map<String, dynamic>>>? _stream;
  Position? _position;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _geo.ensurePermission();
      final pos = await _geo.getCurrentPosition();
      setState(() {
        _position = pos;
        _stream = _repo.streamRecommendedWorkers(
          latitude: pos.latitude,
          longitude: pos.longitude,
          category: widget.category,
        );
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text('Erreur: ${_error!}', style: AppTheme.kBodyStyle.copyWith(color: AppTheme.kErrorColor)),
      );
    }
    if (_stream == null || _position == null) {
      return Center(child: Text('Position indisponible', style: AppTheme.kBodyStyle));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final workers = snapshot.data ?? const <Map<String, dynamic>>[];
        if (workers.isEmpty) {
          return Center(child: Text('Aucun travailleur recommandé à proximité', style: AppTheme.kBodyStyle));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: workers.length,
          itemBuilder: (context, index) {
            final w = workers[index];
            return _WorkerCard(worker: w);
          },
        );
      },
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({required this.worker});

  final Map<String, dynamic> worker;

  @override
  Widget build(BuildContext context) {
    final String name = (worker['displayName'] ?? 'Travailleur').toString();
    final String photoUrl = (worker['photoUrl'] ?? '').toString();
    final double rating = (worker['ratingAvg'] ?? 0.0).toDouble();
    final int ratingCount = (worker['ratingCount'] ?? 0) as int;
    final double distanceKm = (worker['distanceKm'] ?? 0.0).toDouble();
    final List categories = (worker['categories'] ?? const <String>[]) as List;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.kPrimaryTeal.withValues(alpha: 0.2),
              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty
                  ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: AppTheme.kSubheadingStyle)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.kSubheadingStyle),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1), style: AppTheme.kBodyStyle.copyWith(color: AppTheme.kTextColor)),
                      const SizedBox(width: 8),
                      Text('($ratingCount)', style: AppTheme.kBodyStyle),
                      const SizedBox(width: 12),
                      const Icon(Icons.place_rounded, color: AppTheme.kPrimaryTeal, size: 18),
                      const SizedBox(width: 4),
                      Text('${distanceKm.toStringAsFixed(1)} km', style: AppTheme.kBodyStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: categories
                        .take(4)
                        .map((c) => Chip(
                              label: Text(c.toString()),
                              backgroundColor: AppTheme.kButton3DLight,
                              side: const BorderSide(color: AppTheme.kPrimaryYellow),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to worker profile details (to implement)
              },
              child: const Text('Profil'),
            ),
          ],
        ),
      ),
    );
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

class UsersSubmitRating extends StatefulWidget {
  const UsersSubmitRating({
    super.key,
    required this.workerUid,
    required this.requestId,
  });

  final String workerUid;
  final String requestId;

  @override
  State<UsersSubmitRating> createState() => _UsersSubmitRatingState();
}

class _UsersSubmitRatingState extends State<UsersSubmitRating> {
  final RatingsRepository _ratings = RatingsRepository();
  final AuthService _auth = AuthService();
  final TextEditingController _commentCtrl = TextEditingController();
  double _score = 5.0;
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final fb.User? user = _auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await _ratings.addOrUpdateRating(
        requestId: widget.requestId,
        workerUid: widget.workerUid,
        raterUid: user.uid,
        score: _score,
        comment: _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci pour votre évaluation !')),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBackgroundColor,
      appBar: AppBar(title: const Text('Évaluer le travail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Note globale', style: AppTheme.kSubheadingStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _score,
                    min: 1,
                    max: 5,
                    divisions: 8,
                    label: _score.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _score = v),
                  ),
                ),
                Text(_score.toStringAsFixed(1), style: AppTheme.kSubheadingStyle),
              ],
            ),
            const SizedBox(height: 12),
            Text('Commentaire (optionnel)', style: AppTheme.kSubheadingStyle),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Partagez votre expérience...',
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: const Icon(Icons.send_rounded),
              label: _submitting ? const Text('Envoi...') : const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
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

class UsersSearchMap extends StatefulWidget {
  const UsersSearchMap({super.key});

  @override
  State<UsersSearchMap> createState() => _UsersSearchMapState();
}

class _UsersSearchMapState extends State<UsersSearchMap> {
  final GeolocationService _geo = const GeolocationService();
  final WorkersDiscoveryRepository _repo = WorkersDiscoveryRepository();

  Position? _pos;
  List<Map<String, dynamic>> _workers = const <Map<String, dynamic>>[];
  Stream<List<Map<String, dynamic>>>? _stream;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _geo.ensurePermission();
    final pos = await _geo.getCurrentPosition();
    setState(() {
      _pos = pos;
      _stream = _repo.streamRecommendedWorkers(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pos == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final ll.LatLng center = ll.LatLng(_pos!.latitude, _pos!.longitude);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        _workers = snapshot.data ?? const <Map<String, dynamic>>[];
        final markers = <Marker>[
          Marker(
            width: 40,
            height: 40,
            point: center,
            child: const Icon(Icons.my_location_rounded, color: AppTheme.kPrimaryTeal, size: 28),
          ),
          ..._workers.map((w) {
            final GeoPoint? gp = w['lastKnownLocation'] as GeoPoint?;
            if (gp == null) return const Marker(point: ll.LatLng(0, 0), child: SizedBox.shrink());
            return Marker(
              width: 44,
              height: 44,
              point: ll.LatLng(gp.latitude, gp.longitude),
              child: GestureDetector(
                onTap: () {
                  _showWorkerSheet(context, w);
                },
                child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 36),
              ),
            );
          }),
        ];

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.khidmeti.khidmeti_users',
            ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }

  void _showWorkerSheet(BuildContext context, Map<String, dynamic> w) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((w['displayName'] ?? 'Travailleur').toString(), style: AppTheme.kSubheadingStyle),
              const SizedBox(height: 8),
              Text((w['bio'] ?? '—').toString(), style: AppTheme.kBodyStyle),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text(((w['ratingAvg'] ?? 0.0).toDouble()).toStringAsFixed(1), style: AppTheme.kBodyStyle),
                  const SizedBox(width: 6),
                  Text('(${(w['ratingCount'] ?? 0) as int})', style: AppTheme.kBodyStyle),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to full profile screen
                  },
                  child: const Text('Voir le profil'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UsersRequestForm extends StatefulWidget {
  const UsersRequestForm({super.key});

  @override
  State<UsersRequestForm> createState() => _UsersRequestFormState();
}

class _UsersRequestFormState extends State<UsersRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  String _category = 'Plomberie';
  final List<XFile> _media = <XFile>[];
  final ImagePicker _picker = ImagePicker();
  final GeolocationService _geo = const GeolocationService();
  final RequestsRepository _requests = RequestsRepository();
  late final StorageService _storage;
  Position? _pos;
  bool _submitting = false;
  final List<String> _categories = const [
    'Plomberie', 'Électricité', 'Nettoyage', 'Livraison', 'Peinture',
    'Réparation électroménager', 'Maçonnerie', 'Climatisation', 'Baby-sitting', 'Cours particuliers',
  ];

  @override
  void initState() {
    super.initState();
    _storage = StorageService(role: 'users');
    _init();
  }

  Future<void> _init() async {
    await _geo.ensurePermission();
    final pos = await _geo.getCurrentPosition();
    setState(() => _pos = pos);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final List<XFile> files = await _picker.pickMultipleMedia();
    if (files.isNotEmpty) {
      setState(() => _media.addAll(files));
    }
  }

  Future<void> _submit() async {
    if (_pos == null) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final String uid = 'demo-user'; // TODO: replace with AuthService.currentUser!.uid when wired
      final List<String> urls = <String>[];
      for (final XFile f in _media) {
        final bytes = await f.readAsBytes();
        final String ext = f.name.split('.').last;
        final String url = await _storage.uploadData(
          uid: uid,
          data: bytes,
          category: 'requests',
          extension: ext,
        );
        urls.add(url);
      }
      final String id = await _requests.createRequest(
        userUid: uid,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        latitude: _pos!.latitude,
        longitude: _pos!.longitude,
        mediaUrls: urls,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande publiée !')),
      );
      setState(() {
        _titleCtrl.clear();
        _descCtrl.clear();
        _media.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pos == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Nouvelle demande', style: AppTheme.kHeadingStyle),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Catégorie'),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Titre'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Description'),
            minLines: 3,
            maxLines: 6,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.attach_file_rounded),
                label: const Text('Ajouter médias'),
              ),
              const SizedBox(width: 12),
              Text('${_media.length} fichiers sélectionnés', style: AppTheme.kBodyStyle),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: ll.LatLng(_pos!.latitude, _pos!.longitude),
                initialZoom: 14,
                onTap: (tapPosition, point) {
                  setState(() {
                    _pos = Position(
                      longitude: point.longitude,
                      latitude: point.latitude,
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      heading: 0,
                      speed: 0,
                      speedAccuracy: 0,
                      altitudeAccuracy: 0,
                      headingAccuracy: 0,
                    );
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.khidmeti.khidmeti_users',
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: ll.LatLng(_pos!.latitude, _pos!.longitude),
                    width: 44,
                    height: 44,
                    child: const Icon(Icons.place_rounded, color: Colors.red, size: 36),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: const Icon(Icons.send_rounded),
              label: _submitting ? const Text('Envoi...') : const Text('Publier'),
            ),
          ),
        ],
      ),
    );
  }
}
