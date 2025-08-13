import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'models/job.dart' as jm;
import 'models/service_category.dart';
import 'services/auth_service.dart' as users_auth;
import 'services/job_service.dart';
import 'services/worker_service.dart';
import 'services/notification_service.dart' as users_notif;
import 'firebase_config.dart';
import 'utils/app_locale.dart';

@pragma('vm:entry-point')
Future<void> _fcmBackground(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AppLocale.loadInitial();
  FirebaseMessaging.onBackgroundMessage(_fcmBackground);
  runApp(const KhidmetiUsersApp());
}

// Palette
const Color kPrimaryYellow = Color(0xFFFCCBF0);
const Color kPrimaryRed = Color(0xFFFF5A57);
const Color kPrimaryDark = Color(0xFF6700A3);
const Color kPrimaryTeal = Color(0xFFE02F75);
const Color kBackgroundColor = Color(0xFF1B2062);
const Color kSurfaceColor = Color(0xFFFFFFFF);
const Color kTextColor = Color(0xFF050C38);
const Color kSubtitleColor = Color(0xFF6B7280);

class KhidmetiUsersApp extends StatefulWidget {
  const KhidmetiUsersApp({super.key});

  @override
  State<KhidmetiUsersApp> createState() => _KhidmetiUsersAppState();
}

class _KhidmetiUsersAppState extends State<KhidmetiUsersApp> {
  final users_auth.AuthService _auth = users_auth.AuthService();
  final users_notif.NotificationService _notif = users_notif.NotificationService();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _auth.initialize();
    await _notif.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'KHIDMETI Users',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryTeal),
            scaffoldBackgroundColor: kBackgroundColor,
            fontFamily: 'Inter',
          ),
          locale: locale,
          supportedLocales: AppLocale.supportedLocales,
          home: StreamBuilder<fb_auth.User?>(
            stream: users_auth.AuthService().authStateChanges,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: kBackgroundColor,
                  body: Center(child: CircularProgressIndicator(color: kPrimaryTeal)),
                );
              }
              if (snap.data == null) return const _SignInScreen();
              return const _MainNav();
            },
          ),
        );
      },
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

  final users_auth.AuthService _auth = users_auth.AuthService();

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
              Text('KHIDMETI Users', style: const TextStyle(fontFamily: 'Paytone One', fontSize: 24, color: kPrimaryDark)),
              const SizedBox(height: 16),
              TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Mot de passe'), obscureText: true),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: kPrimaryRed)),
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
    _SearchMapScreen(),
    _CreateJobScreen(),
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
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Recherche'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Demande'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Paramètres'),
        ],
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(backgroundColor: kBackgroundColor, title: const Text('Accueil', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(20)),
          child: StreamBuilder<List<dynamic>>( // map to Worker models if needed
            stream: WorkerService().getRecommendedWorkers(userId: uid, limit: 10),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final workers = snap.data!;
              if (workers.isEmpty) return const Center(child: Text('Aucun travailleur recommandé pour le moment'));
              return ListView.separated(
                itemCount: workers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final w = workers[i];
                  return ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: Colors.white,
                    title: Text(w.fullName ?? ''),
                    subtitle: Text('Note: ${w.rating?.toStringAsFixed(1) ?? '—'}'),
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

class _SearchMapScreen extends StatefulWidget {
  const _SearchMapScreen();
  @override
  State<_SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<_SearchMapScreen> {
  LatLng _center = LatLng(FirebaseConfig.defaultLatitude, FirebaseConfig.defaultLongitude);
  Position? _position;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return;
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _position = pos;
        _center = LatLng(pos.latitude, pos.longitude);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(backgroundColor: kBackgroundColor, title: const Text('Recherche', style: TextStyle(color: Colors.white))),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FirebaseConfig.workersCollection)
                  .where('status', isEqualTo: 'verified')
                  .where('isOnline', isEqualTo: true)
                  .snapshots(),
              builder: (context, snap) {
                final markers = <Marker>[];
                if (snap.hasData) {
                  for (final doc in snap.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final loc = data['currentLocation'];
                    if (loc != null) {
                      markers.add(Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(loc.latitude, loc.longitude),
                        builder: (ctx) => GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => _WorkerProfileSheet(data: data),
                            );
                          },
                          child: const Icon(Icons.location_pin, color: kPrimaryRed, size: 36),
                        ),
                      ));
                    }
                  }
                }
                return FlutterMap(
                  options: MapOptions(center: _center, zoom: 13),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.khidmeti.users',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkerProfileSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  const _WorkerProfileSheet({required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${data['firstName'] ?? ''} ${data['lastName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Services: ${(data['services'] as List<dynamic>? ?? []).join(', ')}'),
          const SizedBox(height: 8),
          Text('Note: ${(data['rating'] ?? 0.0).toStringAsFixed(1)}'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }
}

class _CreateJobScreen extends StatefulWidget {
  const _CreateJobScreen();
  @override
  State<_CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<_CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _jobService = JobService();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  String _category = '';
  DateTime _deadline = DateTime.now().add(const Duration(days: 2));
  LatLng? _jobLocation;
  String _address = '';
  List<File> _images = [];
  List<File> _videos = [];

  @override
  void initState() {
    super.initState();
    _initPosition();
  }

  Future<void> _initPosition() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return;
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _jobLocation = LatLng(pos.latitude, pos.longitude));
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (x != null) setState(() => _images.add(File(x.path)));
  }

  Future<void> _pickVideo() async {
    final x = await _picker.pickVideo(source: ImageSource.camera);
    if (x != null) setState(() => _videos.add(File(x.path)));
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, firstDate: now, lastDate: now.add(const Duration(days: 30)), initialDate: _deadline);
    if (d != null) setState(() => _deadline = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_jobLocation == null) return;

    final uid = fb_auth.FirebaseAuth.instance.currentUser!.uid;
    // Fetch minimal user identity for job card
    final userDoc = await FirebaseFirestore.instance.collection(FirebaseConfig.usersCollection).doc(uid).get();
    final userData = userDoc.data() as Map<String, dynamic>? ?? {};

    await _jobService.createJob(
      userId: uid,
      userFirstName: userData['firstName'] ?? '',
      userLastName: userData['lastName'] ?? '',
      userImageUrl: userData['profileImageUrl'],
      userPhoneNumber: userData['phoneNumber'],
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      budget: double.tryParse(_budgetCtrl.text) ?? 0,
      deadline: _deadline,
      latitude: _jobLocation!.latitude,
      longitude: _jobLocation!.longitude,
      address: _address,
      images: _images,
      videos: _videos,
      priority: jm.JobPriority.medium,
      isUrgent: false,
      requirements: const {},
      tags: const [],
      language: userData['language'] ?? 'fr',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande créée')));
      _formKey.currentState!.reset();
      setState(() { _images.clear(); _videos.clear(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(backgroundColor: kBackgroundColor, title: const Text('Nouvelle demande', style: TextStyle(color: Colors.white))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(20)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Titre'),
                  validator: (v) => v == null || v.length < 10 ? 'Au moins 10 caractères' : null,
                ),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 3,
                  maxLines: 6,
                  validator: (v) => v == null || v.length < 20 ? 'Au moins 20 caractères' : null,
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<ServiceCategory>>(
                  stream: JobService().getServiceCategories(),
                  builder: (context, snap) {
                    final cats = snap.data ?? [];
                    return DropdownButtonFormField<String>(
                      value: _category.isEmpty && cats.isNotEmpty ? cats.first.name : (_category.isEmpty ? null : _category),
                      items: cats.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                      onChanged: (v) => setState(() => _category = v ?? ''),
                      decoration: const InputDecoration(labelText: 'Catégorie'),
                    );
                  },
                ),
                TextFormField(
                  controller: _budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Budget (DZD)'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(_deadline.toLocal().toString().split(' ').first)),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: _pickDeadline, child: const Text('Choisir une date')),
                  ],
                ),
                const SizedBox(height: 8),
                if (_jobLocation != null)
                  Text('Localisation: ${_jobLocation!.latitude.toStringAsFixed(4)}, ${_jobLocation!.longitude.toStringAsFixed(4)}')
                else
                  const Text('Localisation en cours...'),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Adresse (optionnel)'),
                  onChanged: (v) => _address = v,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo_camera), label: const Text('Ajouter image')),
                    ElevatedButton.icon(onPressed: _pickVideo, icon: const Icon(Icons.videocam), label: const Text('Ajouter vidéo')),
                  ],
                ),
                const SizedBox(height: 8),
                if (_images.isNotEmpty)
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_images[i], width: 120, height: 90, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Publier la demande'),
                ),
              ],
            ),
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
  final _auth = users_auth.AuthService();
  String _language = FirebaseConfig.defaultLanguage;

  @override
  void initState() {
    super.initState();
    _language = _auth.currentUser?.language ?? FirebaseConfig.defaultLanguage;
  }

  Future<void> _setLanguage(String lang) async {
    await _auth.updateLanguage(lang);
    await AppLocale.setLanguage(lang);
    if (mounted) setState(() => _language = lang);
  }

  Future<void> _signOut() async {
    await _auth.signOut();
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryRed, foregroundColor: Colors.white),
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}