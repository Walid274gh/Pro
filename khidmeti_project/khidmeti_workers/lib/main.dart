import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Palette Paytone One (accent pro)
const Color kPrimaryYellow = Color(0xFFFCDC73);
const Color kPrimaryRed = Color(0xFFE76268);
const Color kPrimaryDark = Color(0xFF193948);
const Color kPrimaryTeal = Color(0xFF4FADCD);

const Color kBackgroundColor = Color(0xFFFFF8E7);
const Color kSurfaceColor = Color(0xFFFFFFFF);
const Color kTextColor = Color(0xFF193948);
const Color kSubtitleColor = Color(0xFF6B7280);

const TextStyle kHeadingStyle = TextStyle(
	fontFamily: 'Paytone One',
	fontSize: 24,
	fontWeight: FontWeight.bold,
	color: kPrimaryDark,
	letterSpacing: -0.5,
);

const TextStyle kBodyStyle = TextStyle(
	fontFamily: 'Inter',
	fontSize: 14,
	fontWeight: FontWeight.w400,
	color: kSubtitleColor,
	height: 1.4,
);

// Firebase options placeholder
class DefaultFirebaseOptions {
	static FirebaseOptions get currentPlatform {
		return const FirebaseOptions(
			apiKey: 'your-api-key',
			appId: 'your-app-id',
			messagingSenderId: 'your-sender-id',
			projectId: 'your-project-id',
		);
	}
}

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
	runApp(const KhidmetiWorkersApp());
}

class KhidmetiWorkersApp extends StatelessWidget {
	const KhidmetiWorkersApp({super.key});
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Khidmeti Workers',
			theme: ThemeData(
				primaryColor: kPrimaryDark,
				colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryDark, background: kBackgroundColor),
				fontFamily: 'Inter',
				useMaterial3: true,
				appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
			),
			home: StreamBuilder<fb_auth.User?>(
				stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
				builder: (context, snapshot) {
					if (snapshot.connectionState == ConnectionState.waiting) {
						return const SplashScreen();
					}
					if (snapshot.hasData && snapshot.data != null) {
						return const WorkersHomeShell();
					}
					return const WorkersAuthScreen();
				},
			),
			routes: {
				'/home': (context) => const DashboardScreen(),
				'/map': (context) => const WorkerMapScreen(),
			},
		);
	}
}

class SplashScreen extends StatefulWidget {
	const SplashScreen({super.key});
	@override
	State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
	late final AnimationController _logoController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..forward();
	@override
	void initState() {
		super.initState();
		Future.delayed(const Duration(seconds: 2), () {
			if (!mounted) return;
			Navigator.pushReplacementNamed(context, '/home');
		});
	}
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: Center(
				child: Lottie.asset('assets/animations/splash_animation.json', controller: _logoController, width: 180, height: 180),
			),
		);
	}
}

class DashboardScreen extends StatelessWidget {
	const DashboardScreen({super.key});
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const ModernHeader(title: 'Tableau de bord'),
						Expanded(
							child: ListView(
								padding: const EdgeInsets.all(16),
								children: const [
									ProfessionalDashboardCard(
										title: 'Revenus (mensuel)',
										value: '120 000 DZD',
										icon: Icons.payments,
										trend: '+12% ce mois',
									),
									ProfessionalDashboardCard(
										title: 'Demandes actives',
										value: '8',
										icon: Icons.assignment,
										trend: '2 nouvelles',
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

class ProfessionalDashboardCard extends StatelessWidget {
	final String title;
	final String value;
	final IconData icon;
	final Color accentColor;
	final String trend;
	final VoidCallback? onTap;
	const ProfessionalDashboardCard({super.key, required this.title, required this.value, required this.icon, this.accentColor = kPrimaryTeal, required this.trend, this.onTap});
	@override
	Widget build(BuildContext context) {
		return Container(
			margin: const EdgeInsets.all(8),
			child: Material(
				elevation: 6,
				borderRadius: BorderRadius.circular(20),
				color: kSurfaceColor,
				child: InkWell(
					borderRadius: BorderRadius.circular(20),
					onTap: onTap,
					child: Padding(
						padding: const EdgeInsets.all(20),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									children: [
										Container(
											padding: const EdgeInsets.all(12),
											decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
											child: Icon(icon, color: accentColor, size: 24),
										),
										const Spacer(),
										Text(trend, style: TextStyle(fontSize: 12, color: accentColor, fontWeight: FontWeight.w600)),
									],
								),
								const SizedBox(height: 16),
								Text(value, style: const TextStyle(fontFamily: 'Paytone One', fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryDark)),
								const SizedBox(height: 4),
								Text(title, style: const TextStyle(fontSize: 14, color: kSubtitleColor, fontWeight: FontWeight.w500)),
							],
						),
					),
				),
			),
		);
	}
}

class ModernHeader extends StatelessWidget implements PreferredSizeWidget {
	final String title;
	final List<Widget>? actions;
	final Widget? leading;
	final Color? backgroundColor;
	final bool showBackButton;
	const ModernHeader({super.key, required this.title, this.actions, this.leading, this.backgroundColor, this.showBackButton = false});
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
					BoxShadow(color: kPrimaryDark.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 10),
				],
			),
			child: SafeArea(
				bottom: false,
				child: Row(
					children: [
						if (showBackButton)
							IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: kPrimaryTeal)),
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

class WorkerMapScreen extends StatefulWidget {
	const WorkerMapScreen({super.key});
	@override
	State<WorkerMapScreen> createState() => _WorkerMapScreenState();
}

class _WorkerMapScreenState extends State<WorkerMapScreen> {
	static const LatLng algerCenter = LatLng(36.737232, 3.086472);
	LatLng? _workerLocation;
	List<LatLng> _routeToIntervention = [];
	bool _isAvailable = true;
	bool _isLoadingRoute = false;
	
	@override
	void initState() {
		super.initState();
		_getCurrentLocation();
	}
	
	Future<void> _getCurrentLocation() async {
		try {
			final position = await Geolocator.getCurrentPosition();
			setState(() {
				_workerLocation = LatLng(position.latitude, position.longitude);
			});
			// Update location in Firestore
			await _updateLocationInFirestore();
		} catch (e) {
			print('Location error: $e');
		}
	}
	
	Future<void> _updateLocationInFirestore() async {
		final user = fb_auth.FirebaseAuth.instance.currentUser;
		if (user != null && _workerLocation != null) {
			await FirebaseFirestore.instance
				.collection('workers')
				.doc(user.uid)
				.update({
					'location': GeoPoint(_workerLocation!.latitude, _workerLocation!.longitude),
					'lastLocationUpdate': FieldValue.serverTimestamp(),
				});
		}
	}
	
	Future<void> _calculateRouteToIntervention() async {
		if (_workerLocation == null) return;
		
		setState(() => _isLoadingRoute = true);
		
		// Simulate intervention location
		final interventionLocation = LatLng(36.737232, 3.086472);
		
		try {
			// Use OpenRouteService (same as users app)
			final response = await http.get(
				Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car?api_key=your-api-key&start=${_workerLocation!.longitude},${_workerLocation!.latitude}&end=${interventionLocation.longitude},${interventionLocation.latitude}'),
			);
			
			if (response.statusCode == 200) {
				final data = json.decode(response.body);
				final coordinates = data['features'][0]['geometry']['coordinates'] as List;
				final route = coordinates.map((coord) => LatLng(coord[1] as double, coord[0] as double)).toList();
				
				setState(() {
					_routeToIntervention = route;
					_isLoadingRoute = false;
				});
			}
		} catch (e) {
			setState(() => _isLoadingRoute = false);
			print('Route calculation error: $e');
		}
	}
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: Stack(
					children: [
						const ModernHeader(title: 'Carte (pro)', showBackButton: true),
						Padding(
							padding: const EdgeInsets.only(top: 88),
							child: FlutterMap(
								options: MapOptions(
									initialCenter: _workerLocation ?? algerCenter,
									initialZoom: 15,
									onMapReady: () => _getCurrentLocation(),
								),
								children: [
									const TileLayer(
										urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
										userAgentPackageName: 'khidmeti.workers',
									),
									// Worker location marker
									if (_workerLocation != null)
										MarkerLayer(
											markers: [
												Marker(
													point: _workerLocation!,
													width: 40,
													height: 40,
													child: Container(
														decoration: BoxDecoration(
															color: _isAvailable ? kPrimaryTeal : kPrimaryRed,
															shape: BoxShape.circle,
															border: Border.all(color: Colors.white, width: 2),
														),
														child: const Icon(Icons.person, color: Colors.white, size: 20),
													),
												),
											],
										),
									// Route to intervention
									if (_routeToIntervention.isNotEmpty)
										PolylineLayer(
											polylines: [
												Polyline(
													points: _routeToIntervention,
													strokeWidth: 4,
													color: kPrimaryDark,
												),
											],
										),
								],
							),
						),
						// Status toggle
						Positioned(
							top: 100,
							left: 16,
							child: Container(
								padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
								decoration: BoxDecoration(
									color: _isAvailable ? kPrimaryTeal : kPrimaryRed,
									borderRadius: BorderRadius.circular(20),
									boxShadow: [
										BoxShadow(
											color: kPrimaryDark.withOpacity(0.2),
											offset: const Offset(0, 2),
											blurRadius: 8,
										),
									],
								),
								child: Row(
									mainAxisSize: MainAxisSize.min,
									children: [
										Icon(
											_isAvailable ? Icons.check_circle : Icons.cancel,
											color: Colors.white,
											size: 16,
										),
										const SizedBox(width: 8),
										Text(
											_isAvailable ? 'Disponible' : 'Occupé',
											style: const TextStyle(
												color: Colors.white,
												fontWeight: FontWeight.bold,
												fontSize: 12,
											),
										),
									],
								),
							),
						),
						// Floating action buttons
						Positioned(
							top: 100,
							right: 16,
							child: Column(
								children: [
									FloatingActionButton.small(
										onPressed: _getCurrentLocation,
										backgroundColor: kPrimaryTeal,
										child: const Icon(Icons.my_location, color: Colors.white),
									),
									const SizedBox(height: 8),
									FloatingActionButton.small(
										onPressed: _calculateRouteToIntervention,
										backgroundColor: kPrimaryDark,
										child: _isLoadingRoute
											? const SizedBox(
												width: 16,
												height: 16,
												child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
											)
											: const Icon(Icons.route, color: Colors.white),
									),
								],
							),
						),
						// Bottom CTA
						Positioned(
							left: 16,
							right: 16,
							bottom: 24,
							child: FilledButton.icon(
								onPressed: () => _toggleAvailability(),
								icon: Icon(_isAvailable ? Icons.pause : Icons.play_arrow),
								label: Text(_isAvailable ? 'Mettre en pause' : 'Reprendre'),
								style: FilledButton.styleFrom(
									backgroundColor: _isAvailable ? kPrimaryRed : kPrimaryTeal,
									minimumSize: const Size(double.infinity, 56),
								),
							),
						),
					],
				),
			),
		);
	}
	
	void _toggleAvailability() {
		setState(() => _isAvailable = !_isAvailable);
		// Update availability in Firestore
		final user = fb_auth.FirebaseAuth.instance.currentUser;
		if (user != null) {
			FirebaseFirestore.instance
				.collection('workers')
				.doc(user.uid)
				.update({'isAvailable': _isAvailable});
		}
	}
}

// Professional services for workers
class WorkerServices {
	static Future<List<Map<String, dynamic>>> getNearbyRequests(LatLng workerLocation, double radiusKm) async {
		try {
			// Query Firestore for nearby requests
			final requests = await FirebaseFirestore.instance
				.collection('requests')
				.where('status', isEqualTo: 'pending')
				.get();
			
			// Filter by distance (simplified)
			return requests.docs.map((doc) {
				final data = doc.data();
				final requestLocation = data['location'] as GeoPoint;
				final distance = Geolocator.distanceBetween(
					workerLocation.latitude,
					workerLocation.longitude,
					requestLocation.latitude,
					requestLocation.longitude,
				) / 1000; // Convert to km
				
				return {
					...data,
					'id': doc.id,
					'distance': distance,
				};
			}).where((request) => request['distance'] <= radiusKm).toList();
		} catch (e) {
			print('Error getting nearby requests: $e');
			return [];
		}
	}
	
	static Future<void> acceptRequest(String requestId, String workerId) async {
		try {
			await FirebaseFirestore.instance
				.collection('requests')
				.doc(requestId)
				.update({
					'workerId': workerId,
					'status': 'accepted',
					'acceptedAt': FieldValue.serverTimestamp(),
				});
		} catch (e) {
			print('Error accepting request: $e');
		}
	}
	
	static Future<void> updateRequestStatus(String requestId, String status) async {
		try {
			await FirebaseFirestore.instance
				.collection('requests')
				.doc(requestId)
				.update({
					'status': status,
					'updatedAt': FieldValue.serverTimestamp(),
				});
		} catch (e) {
			print('Error updating request status: $e');
		}
	}
}

class WorkersHomeShell extends StatefulWidget {
	const WorkersHomeShell({super.key});
	@override
	State<WorkersHomeShell> createState() => _WorkersHomeShellState();
}

class _WorkersHomeShellState extends State<WorkersHomeShell> {
	int _index = 0;
	final List<Widget> _screens = const [DashboardScreen(), WorkerMapScreen(), WorkersRequestsScreen(), WorkersProfileScreen()];
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: _screens[_index],
			bottomNavigationBar: Container(
				margin: const EdgeInsets.all(16),
				decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: kPrimaryDark.withOpacity(0.1), offset: const Offset(0, 4), blurRadius: 20)]),
				child: BottomNavigationBar(
					currentIndex: _index,
					onTap: (i) => setState(() => _index = i),
					backgroundColor: Colors.transparent,
					elevation: 0,
					type: BottomNavigationBarType.fixed,
					selectedItemColor: kPrimaryDark,
					unselectedItemColor: kSubtitleColor,
					items: const [
						BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
						BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
						BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Interventions'),
						BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
					],
				),
			),
		);
	}
}

class WorkersAuthScreen extends StatefulWidget {
	const WorkersAuthScreen({super.key});
	@override
	State<WorkersAuthScreen> createState() => _WorkersAuthScreenState();
}

class _WorkersAuthScreenState extends State<WorkersAuthScreen> {
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
							Lottie.asset('assets/animations/login_animation.json', height: 200),
							const SizedBox(height: 32),
							Text(_isLogin ? 'Connexion Pro' : 'Inscription Pro', style: kHeadingStyle.copyWith(fontSize: 28), textAlign: TextAlign.center),
							const SizedBox(height: 32),
							Form(
								key: _formKey,
								child: Column(
									children: [
										_buildTextField(controller: _emailController, label: 'Email', icon: Icons.email),
										const SizedBox(height: 16),
										_buildTextField(controller: _passwordController, label: 'Mot de passe', icon: Icons.lock, isPassword: true),
									],
								),
							),
							const SizedBox(height: 32),
							FilledButton(
								onPressed: _handleAuth,
								style: FilledButton.styleFrom(backgroundColor: kPrimaryDark, minimumSize: const Size(double.infinity, 56)),
								child: Text(_isLogin ? 'Se connecter' : 'S\'inscrire', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
							),
							const SizedBox(height: 24),
							TextButton(
								onPressed: () => setState(() => _isLogin = !_isLogin),
								child: Text(_isLogin ? 'Pas encore de compte ? S\'inscrire' : 'Déjà un compte ? Se connecter', style: kBodyStyle.copyWith(color: kPrimaryDark)),
							),
						],
					),
				),
			),
		);
	}
	Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
		return Container(
			decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: kPrimaryDark.withOpacity(0.06), offset: const Offset(0, 8), blurRadius: 24)]),
			child: TextFormField(
				controller: controller,
				obscureText: isPassword,
				validator: (value) {
					if (value == null || value.isEmpty) return 'Ce champ est requis';
					if (label == 'Email' && !value.contains('@')) return 'Email invalide';
					if (isPassword && value.length < 6) return 'Minimum 6 caractères';
					return null;
				},
				decoration: InputDecoration(
					prefixIcon: Icon(icon, color: kPrimaryDark),
					labelText: label,
					labelStyle: kBodyStyle,
					border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
					filled: true,
					fillColor: Colors.transparent,
				),
			),
		);
	}
	void _handleAuth() async {
		if (!_formKey.currentState!.validate()) return;
		setState(() => _isLoading = true);
		try {
			if (_isLogin) {
				await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text);
			} else {
				final credential = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text);
				await FirebaseFirestore.instance.collection('workers').doc(credential.user!.uid).set({
					'email': _emailController.text.trim(),
					'firstName': '',
					'lastName': '',
					'selectedAvatar': 'assets/avatars/workers/avatar_worker_1.svg',
					'services': [],
					'rating': 0.0,
					'totalReviews': 0,
					'location': const GeoPoint(0, 0),
					'isAvailable': true,
					'isVisible': true,
					'portfolio': {},
					'createdAt': FieldValue.serverTimestamp(),
				});
			}
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
		}
		if (!mounted) return;
		setState(() => _isLoading = false);
	}
}

class WorkersRequestsScreen extends StatelessWidget {
	const WorkersRequestsScreen({super.key});
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: Column(
					children: [
						const ModernHeader(title: 'Interventions', showBackButton: true),
						Expanded(
							child: ListView(
								padding: const EdgeInsets.all(16),
								children: const [
									ProfessionalDashboardCard(
										title: 'Intervention #123',
										value: 'Plomberie',
										icon: Icons.plumbing,
										trend: 'En cours',
									),
									ProfessionalDashboardCard(
										title: 'Intervention #124',
										value: 'Électricité',
										icon: Icons.electrical_services,
										trend: 'Programmée',
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

class WorkersProfileScreen extends StatelessWidget {
	const WorkersProfileScreen({super.key});
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: Column(
					children: [
						const ModernHeader(title: 'Profil Pro', showBackButton: true),
						const SizedBox(height: 24),
						CircleAvatar(
							radius: 56,
							backgroundColor: kPrimaryDark.withOpacity(0.3),
							child: const Icon(Icons.person, size: 56, color: kPrimaryDark),
						),
						const SizedBox(height: 16),
						Text('Travailleur Khidmeti', style: kHeadingStyle),
						const SizedBox(height: 4),
						const Text('email@example.com', style: kBodyStyle),
						const SizedBox(height: 24),
						FilledButton.icon(
							onPressed: () => fb_auth.FirebaseAuth.instance.signOut(),
							icon: const Icon(Icons.logout),
							label: const Text('Se déconnecter'),
							style: FilledButton.styleFrom(backgroundColor: kPrimaryRed),
						),
					],
				),
			),
		);
	}
}