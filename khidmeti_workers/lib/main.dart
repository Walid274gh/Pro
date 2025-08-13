import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import 'models/worker.dart';
import 'services/auth_service.dart';
import 'services/presence_service.dart';
import 'services/job_request_service.dart';
import 'services/subscription_service.dart';
import 'services/notification_service.dart';
import 'services/message_service.dart';
import 'utils/firebase_config.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const KhidmetiWorkersApp());
}

class KhidmetiWorkersApp extends StatefulWidget {
  const KhidmetiWorkersApp({super.key});

  @override
  State<KhidmetiWorkersApp> createState() => _KhidmetiWorkersAppState();
}

class _KhidmetiWorkersAppState extends State<KhidmetiWorkersApp> {
  final WorkerAuthService _auth = WorkerAuthService();
  final WorkerNotificationService _notif = WorkerNotificationService();
  StreamSubscription<fb_auth.User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _auth.initialize();
    _authSub = _auth.authStateChanges.listen((user) async {
      if (user != null) {
        await _notif.initialize(user.uid);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KHIDMETI Workers',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryRed),
        scaffoldBackgroundColor: kBackgroundColor,
        fontFamily: 'Inter',
      ),
      home: StreamBuilder<fb_auth.User?>(
        stream: _auth.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _Splash();
          }
          final user = snapshot.data;
          if (user == null) {
            return const _SignInScreen();
          }
          return const _MainNav();
        },
      ),
    );
  }
}

// Colors (inspiré Paytone One)
const Color kPrimaryYellow = Color(0xFFFCCBF0);   // Rose clair
const Color kPrimaryRed = Color(0xFFFF5A57);      // Rouge orangé
const Color kPrimaryDark = Color(0xFF6700A3);     // Violet foncé
const Color kPrimaryTeal = Color(0xFFE02F75);     // Rose fuchsia
const Color kBackgroundColor = Color(0xFF1B2062); // Bleu nuit
const Color kSurfaceColor = Color(0xFFFFFFFF);    // Blanc
const Color kTextColor = Color(0xFF050C38);       // Bleu très foncé
const Color kSubtitleColor = Color(0xFF6B7280);   // Texte secondaire
const Color kSuccessColor = Color(0xFF10B981);    // Vert succès
const Color kErrorColor = Color(0xFFFF5A57);      // Rouge orangé

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(child: CircularProgressIndicator(color: kPrimaryTeal)),
    );
  }
}

class _SignInScreen extends StatefulWidget {
  const _SignInScreen();
  @override
  State<_SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<_SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  final WorkerAuthService _auth = WorkerAuthService();

  Future<void> _signIn() async {
    setState(() { _busy = true; _error = null; });
    try {
      await _auth.signInWithEmail(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(20)),
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('KHIDMETI Workers', style: const TextStyle(fontFamily: 'Paytone One', fontSize: 24, color: kPrimaryDark)),
              const SizedBox(height: 16),
              TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Mot de passe'), obscureText: true),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: kErrorColor)),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryTeal, foregroundColor: Colors.white),
                onPressed: _busy ? null : _signIn,
                child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainNav extends StatefulWidget {
  const _MainNav();
  @override
  State<_MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<_MainNav> {
  int _idx = 0;
  final _pages = const [
    _HomeScreen(),
    _RequestsScreen(),
    _HistoryScreen(),
    _SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        backgroundColor: kSurfaceColor,
        indicatorColor: kPrimaryYellow,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.power_settings_new), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Demandes'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Paramètres'),
        ],
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();
  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final PresenceService _presence = PresenceService();
  final JobRequestService _requests = JobRequestService();

  bool _online = false;
  StreamSubscription<DocumentSnapshot>? _workerSub;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser!.uid;
    _workerSub = FirebaseFirestore.instance.collection(FirebaseConfig.workersCollection).doc(uid).snapshots().listen((doc) {
      final data = doc.data();
      if (data != null) {
        setState(() { _online = data['isOnline'] == true; });
      }
    });
  }

  @override
  void dispose() {
    _workerSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleOnline(bool value) async {
    final uid = _auth.currentUser!.uid;
    setState(() { _online = value; });
    if (value) {
      // Permission localisation et update
      final pos = await _ensureLocation();
      await _presence.goOnline(uid);
      if (pos != null) {
        await _presence.updateLocation(workerId: uid, latitude: pos.latitude, longitude: pos.longitude);
      }
    } else {
      await _presence.goOffline(uid);
    }
  }

  Future<Position?> _ensureLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return null;
    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: const Text('Accueil', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0,6))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Statut', style: TextStyle(color: kSubtitleColor)),
                      Text(_online ? 'En ligne' : 'Hors ligne', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor)),
                    ],
                  ),
                  Switch(
                    value: _online,
                    activeColor: kSuccessColor,
                    onChanged: _toggleOnline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0,6))]),
                child: _NearbyRequestsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyRequestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection(FirebaseConfig.workersCollection).doc(uid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final data = snap.data!.data() as Map<String, dynamic>;
        final services = List<String>.from(data['services'] ?? []);
        final loc = data['currentLocation'];
        if (loc == null) return const Center(child: Text('Activez votre statut en ligne pour voir les demandes'));
        final workerLocation = LatLng(loc.latitude, loc.longitude);
        return StreamBuilder<List<JobRequest>>(
          stream: JobRequestService().getNearbyRequests(workerServices: services, workerLocation: workerLocation, radiusKm: 20),
          builder: (context, reqSnap) {
            if (!reqSnap.hasData) return const Center(child: CircularProgressIndicator());
            final requests = reqSnap.data!;
            if (requests.isEmpty) return const Center(child: Text('Aucune demande proche pour le moment'));
            return ListView.separated(
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = requests[i];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${r.category} · ${r.budget.toStringAsFixed(0)} DZD'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryTeal, foregroundColor: Colors.white),
                    onPressed: () async {
                      final user = fb_auth.FirebaseAuth.instance.currentUser!;
                      await JobRequestService().acceptJob(jobId: r.jobId, workerId: user.uid, workerName: data['firstName'] + ' ' + data['lastName'], workerImageUrl: data['profileImageUrl']);
                    },
                    child: const Text('Accepter'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _RequestsScreen extends StatelessWidget {
  const _RequestsScreen();
  @override
  Widget build(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(backgroundColor: kBackgroundColor, title: const Text('Demandes', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(20)),
          child: StreamBuilder<List<JobRequest>>(
            stream: JobRequestService().getMyAcceptedRequests(uid),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final items = snap.data!;
              if (items.isEmpty) return const Center(child: Text('Aucune demande acceptée pour le moment'));
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final r = items[i];
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(r.title),
                    subtitle: Text(r.statusDisplay),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryScreen extends StatelessWidget {
  const _HistoryScreen();
  @override
  Widget build(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(backgroundColor: kBackgroundColor, title: const Text('Historique', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(20)),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(FirebaseConfig.jobsCollection)
                .where('acceptedByWorkerId', isEqualTo: uid)
                .where('status', whereIn: ['completed', 'cancelled'])
                .orderBy('updatedAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snap.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('Aucun historique'));
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(d['title'] ?? ''),
                    subtitle: Text('${d['status']} · ${d['finalPrice']?.toStringAsFixed(0) ?? '—'} DZD'),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen();
  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  final _auth = WorkerAuthService();
  final _subs = SubscriptionService();

  bool _busy = false;
  String _language = FirebaseConfig.defaultLanguage;

  @override
  void initState() {
    super.initState();
    final w = _auth.currentWorker;
    if (w != null) _language = w.language;
  }

  Future<void> _applyFreeTrial() async {
    setState(() => _busy = true);
    try {
      final uid = fb_auth.FirebaseAuth.instance.currentUser!.uid;
      await _subs.ensureFreeTrial(uid);
      if (mounted) _snack('Essai gratuit activé');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _setLanguage(String lang) async {
    setState(() => _language = lang);
    final w = _auth.currentWorker;
    if (w != null) {
      await _auth.updateProfile(language: lang);
      _snack('Langue mise à jour');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(backgroundColor: kBackgroundColor, title: const Text('Paramètres', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Langue'),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _language,
                items: const [
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (v) { if (v != null) _setLanguage(v); },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _busy ? null : _applyFreeTrial,
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryTeal, foregroundColor: Colors.white),
                child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Activer essai gratuit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}