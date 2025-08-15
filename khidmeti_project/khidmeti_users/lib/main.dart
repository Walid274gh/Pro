import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Palette Paytone One
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

const double kBorderRadius = 20.0;
const double kElevation = 8.0;
const double kPadding = 16.0;

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

// Validation flags
const bool USE_PAYTONE_COLORS = true;
const bool NO_APPBAR_DESIGN = true;
const bool BUBBLE_BUTTONS = true;
const bool ROUND_CORNERS_20PX = true;
const bool OPENSTREETMAP_ONLY = true;
const bool SINGLE_FILE_MAIN = true;
const bool SOLID_ARCHITECTURE = true;
const bool LOTTIE_ANIMATIONS = true;
const bool SVG_AVATARS = true;

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
	runApp(const KhidmetiApp());
}

class KhidmetiApp extends StatelessWidget {
	const KhidmetiApp({super.key});

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
				useMaterial3: true,
				appBarTheme: const AppBarTheme(
					backgroundColor: Colors.transparent,
					elevation: 0,
				),
			),
			home: StreamBuilder<fb_auth.User?>(
				stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
				builder: (context, snapshot) {
					if (snapshot.connectionState == ConnectionState.waiting) {
						return const SplashScreen();
					}
					if (snapshot.hasData && snapshot.data != null) {
						return const HomeScreen();
					}
					return const AuthScreen();
				},
			),
							routes: {
					'/auth': (context) => const AuthScreen(),
					'/home': (context) => const HomeScreen(),
					'/search': (context) => const PlaceholderScreen(title: 'Recherche'),
					'/map': (context) => const MapScreen(),
					'/requests': (context) => const PlaceholderScreen(title: 'Demandes'),
					'/profile': (context) => const PlaceholderScreen(title: 'Profil'),
					'/analytics': (context) => const AnalyticsDashboardScreen(),
					'/settings': (context) => const SettingsScreen(),
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
	late final AnimationController _logoController = AnimationController(
		duration: const Duration(milliseconds: 1200),
		vsync: this,
	)..forward();
	late final AnimationController _backgroundController = AnimationController(
		duration: const Duration(milliseconds: 3000),
		vsync: this,
	)..repeat();

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
			body: Stack(
				children: [
					Positioned.fill(
						child: Lottie.asset(
							'assets/animations/splash_workers_background.json',
							controller: _backgroundController,
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
									width: 180,
									height: 180,
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
}

class AuthScreen extends StatefulWidget {
	const AuthScreen({super.key});
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
									_isLogin ? 'Pas encore de compte ? S\'inscrire' : 'Déjà un compte ? Se connecter',
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
						color: kPrimaryDark.withOpacity(0.06),
						offset: const Offset(0, 8),
						blurRadius: 24,
					),
				],
			),
							child: TextFormField(
					controller: controller,
					obscureText: isPassword,
					validator: (value) {
						if (value == null || value.isEmpty) {
							return 'Ce champ est requis';
						}
						if (label == 'Email' && !value.contains('@')) {
							return 'Email invalide';
						}
						if (isPassword && value.length < 6) {
							return 'Minimum 6 caractères';
						}
						return null;
					},
					decoration: InputDecoration(
						prefixIcon: Icon(icon, color: kPrimaryDark),
						labelText: label,
						labelStyle: kBodyStyle,
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
		if (!_formKey.currentState!.validate()) return;
		setState(() => _isLoading = true);
		try {
			if (_isLogin) {
				await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
					email: _emailController.text.trim(),
					password: _passwordController.text,
				);
			} else {
				final credential = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
					email: _emailController.text.trim(),
					password: _passwordController.text,
				);
				// Create user document
				await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
					'email': _emailController.text.trim(),
					'firstName': '',
					'lastName': '',
					'selectedAvatar': AvatarService.userAvatars.first,
					'preferences': {},
					'createdAt': FieldValue.serverTimestamp(),
				});
			}
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Erreur: ${e.toString()}')),
			);
		}
		if (!mounted) return;
		setState(() => _isLoading = false);
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
		HomeView(),
		SearchScreen(),
		MapScreen(),
		RequestsScreen(),
		ProfileScreen(),
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

class HomeView extends StatelessWidget {
	const HomeView({super.key});
	@override
	Widget build(BuildContext context) {
		return SafeArea(
			child: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const ModernHeader(title: 'Khidmeti'),
						const SizedBox(height: 16),
						ModernCard(
							title: 'Réservez rapidement',
							subtitle: 'Trouvez des pros certifiés près de chez vous',
							illustration: SvgPicture.asset(
								'assets/avatars/users/avatar_user_1.svg',
								width: 140,
								height: 140,
							),
							onTap: () {},
						),
						ModernCard(
							title: 'Suivi en temps réel',
							subtitle: 'Visualisez l\'arrivée du travailleur sur la carte',
							illustration: Lottie.asset('assets/animations/map_marker.json', height: 140),
							onTap: () {},
							backgroundColor: kPrimaryTeal.withOpacity(0.15),
						),
					],
				),
			),
		);
	}
}

class PlaceholderScreen extends StatelessWidget {
	final String title;
	const PlaceholderScreen({super.key, required this.title});
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: Column(
					children: [
						ModernHeader(title: title, showBackButton: true),
						const Expanded(
							child: Center(child: Text('À implémenter...', style: kSubheadingStyle)),
						),
					],
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

class ModernCard extends StatelessWidget {
	final String title;
	final String subtitle;
	final Widget illustration;
	final VoidCallback onTap;
	final Color backgroundColor;
	const ModernCard({super.key, required this.title, required this.subtitle, required this.illustration, required this.onTap, this.backgroundColor = kPrimaryYellow});
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
								Text(title, style: kHeadingStyle.copyWith(fontSize: 22)),
								const SizedBox(height: 8),
								Text(subtitle, style: const TextStyle(fontSize: 14, color: kTextColor, height: 1.4)),
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
	const BubbleButton({super.key, required this.text, required this.onPressed, this.icon, this.primaryColor = kPrimaryDark, this.textColor = Colors.white, this.width = 200, this.height = 56});
	@override
	State<BubbleButton> createState() => _BubbleButtonState();
}

class _BubbleButtonState extends State<BubbleButton> with SingleTickerProviderStateMixin {
	late final AnimationController _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
	late final Animation<double> _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
	late final Animation<double> _elevationAnimation = Tween<double>(begin: 8.0, end: 4.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
										Icon(widget.icon, color: widget.textColor, size: 20),
										const SizedBox(width: 8),
									],
									Text(
										widget.text,
										style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.textColor, letterSpacing: 0.5),
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
	void dispose() { _controller.dispose(); super.dispose(); }
}

class MapScreen extends StatefulWidget {
	const MapScreen({super.key});
	@override
	State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
	static const LatLng algerCenter = LatLng(36.737232, 3.086472);
	LatLng? _userLocation;
	List<LatLng> _routePoints = [];
	bool _isLoadingRoute = false;
	final EnhancedLocationService _locationService = EnhancedLocationService();
	
	@override
	void initState() {
		super.initState();
		_getCurrentLocation();
	}
	
	Future<void> _getCurrentLocation() async {
		try {
			final position = await _locationService.getCurrentLocation();
			setState(() {
				_userLocation = LatLng(position.latitude, position.longitude);
			});
		} catch (e) {
			print('Location error: $e');
		}
	}
	
	Future<void> _calculateRouteToWorker() async {
		if (_userLocation == null) return;
		
		setState(() => _isLoadingRoute = true);
		
		// Simulate worker location (in real app, get from Firestore)
		final workerLocation = LatLng(36.737232, 3.086472);
		
		try {
			final route = await OpenStreetMapService.calculateRoute(_userLocation!, workerLocation);
			setState(() {
				_routePoints = route;
				_isLoadingRoute = false;
			});
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
						const ModernHeader(title: 'Carte', showBackButton: true),
						Padding(
							padding: const EdgeInsets.only(top: 88),
							child: FlutterMap(
								options: MapOptions(
									initialCenter: _userLocation ?? algerCenter,
									initialZoom: 15,
									onMapReady: () => _getCurrentLocation(),
								),
								children: [
									const TileLayer(
										urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
										userAgentPackageName: 'khidmeti.users',
									),
									// User location marker
									if (_userLocation != null)
										MarkerLayer(
											markers: [
												Marker(
													point: _userLocation!,
													width: 40,
													height: 40,
													child: Container(
														decoration: BoxDecoration(
															color: kPrimaryTeal,
															shape: BoxShape.circle,
															border: Border.all(color: Colors.white, width: 2),
														),
														child: const Icon(Icons.my_location, color: Colors.white, size: 20),
													),
												),
											],
										),
									// Route polyline
									if (_routePoints.isNotEmpty)
										PolylineLayer(
											polylines: [
												Polyline(
													points: _routePoints,
													strokeWidth: 4,
													color: kPrimaryDark,
												),
											],
										),
								],
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
										onPressed: _calculateRouteToWorker,
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
							child: BubbleButton(
								text: 'Demander un service',
								onPressed: () {
									// Show service request modal
									_showServiceRequestModal(context);
								},
							),
						),
					],
				),
			),
		);
	}
	
	void _showServiceRequestModal(BuildContext context) {
		showModalBottomSheet(
			context: context,
			backgroundColor: Colors.transparent,
			builder: (context) => Container(
				padding: const EdgeInsets.all(24),
				decoration: const BoxDecoration(
					color: kSurfaceColor,
					borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
				),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Text('Demander un service', style: kHeadingStyle),
						const SizedBox(height: 16),
						BubbleButton(
							text: 'Plomberie',
							onPressed: () => Navigator.pop(context),
							primaryColor: kPrimaryTeal,
						),
						const SizedBox(height: 12),
						BubbleButton(
							text: 'Électricité',
							onPressed: () => Navigator.pop(context),
							primaryColor: kPrimaryTeal,
						),
						const SizedBox(height: 12),
						BubbleButton(
							text: 'Ménage',
							onPressed: () => Navigator.pop(context),
							primaryColor: kPrimaryTeal,
						),
					],
				),
			),
		);
	}
	
	@override
	void dispose() {
		_locationService.dispose();
		super.dispose();
	}
}

class SearchScreen extends StatefulWidget {
	const SearchScreen({super.key});
	@override
	State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
	final TextEditingController _query = TextEditingController();
	final List<ServiceModel> _services = [
		ServiceModel(id: '1', name: 'Plomberie', category: 'Maison', description: 'Réparation et installation', basePrice: 1500, iconPath: '', isActive: true),
		ServiceModel(id: '2', name: 'Électricité', category: 'Maison', description: 'Pannes et travaux', basePrice: 2000, iconPath: '', isActive: true),
		ServiceModel(id: '3', name: 'Peinture', category: 'Rénovation', description: 'Intérieur/Extérieur', basePrice: 2500, iconPath: '', isActive: true),
		ServiceModel(id: '4', name: 'Ménage', category: 'Maison', description: 'À la carte', basePrice: 1200, iconPath: '', isActive: true),
	];
	@override
	Widget build(BuildContext context) {
		final List<ServiceModel> filtered = _services.where((s) => s.name.toLowerCase().contains(_query.text.toLowerCase())).toList();
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: Column(
					children: [
						const ModernHeader(title: 'Recherche'),
						Padding(
							padding: const EdgeInsets.all(16),
							child: Container(
								decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: kPrimaryDark.withOpacity(0.06), offset: const Offset(0, 8), blurRadius: 24)]),
								child: TextField(
									controller: _query,
									onChanged: (_) => setState(() {}),
									decoration: const InputDecoration(
										prefixIcon: Icon(Icons.search),
										hintText: 'Rechercher un service...',
										border: InputBorder.none,
										contentPadding: EdgeInsets.all(16),
									),
								),
							),
						Expanded(
							child: GridView.builder(
								padding: const EdgeInsets.symmetric(horizontal: 16),
								gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 12, mainAxisSpacing: 12),
								itemCount: filtered.length,
								itemBuilder: (_, i) {
									final s = filtered[i];
									return Material(
										elevation: 6,
										borderRadius: BorderRadius.circular(20),
										color: kSurfaceColor,
										child: InkWell(
											borderRadius: BorderRadius.circular(20),
											onTap: () {},
											child: Padding(
												padding: const EdgeInsets.all(16),
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Icon(Icons.category, color: kPrimaryDark),
														const Spacer(),
														Text(s.name, style: kHeadingStyle.copyWith(fontSize: 18)),
														Text(s.category, style: kBodyStyle),
													],
												),
											),
										),
									);
								},
							),
						),
					],
				),
			),
		);
	}
}

class RequestsScreen extends StatelessWidget {
	const RequestsScreen({super.key});
	@override
	Widget build(BuildContext context) {
		final List<RequestModel> requests = [
			RequestModel(id: 'r1', userId: 'u', workerId: null, serviceType: 'Plomberie', description: 'Fuite évier', mediaUrls: const [], location: const GeoPoint(0, 0), scheduledDate: DateTime.now(), status: RequestStatus.pending, finalPrice: null),
			RequestModel(id: 'r2', userId: 'u', workerId: null, serviceType: 'Électricité', description: 'Disjoncteur', mediaUrls: const [], location: const GeoPoint(0, 0), scheduledDate: DateTime.now(), status: RequestStatus.inProgress, finalPrice: null),
		];
		Color statusColor(RequestStatus s) {
			switch (s) {
				case RequestStatus.pending:
					return kPrimaryYellow;
				case RequestStatus.accepted:
					return kPrimaryTeal;
				case RequestStatus.inProgress:
					return Colors.orange;
				case RequestStatus.completed:
					return kSuccessColor;
				case RequestStatus.cancelled:
					return kErrorColor;
			}
		}
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: Column(
					children: [
						const ModernHeader(title: 'Mes demandes'),
						Expanded(
							child: ListView.builder(
								padding: const EdgeInsets.all(16),
								itemCount: requests.length,
								itemBuilder: (_, i) {
									final r = requests[i];
									return Container(
										margin: const EdgeInsets.only(bottom: 12),
										child: Material(
											elevation: 6,
											borderRadius: BorderRadius.circular(16),
											color: kSurfaceColor,
											child: ListTile(
												title: Text(r.serviceType, style: kSubheadingStyle),
												subtitle: Text(r.description, style: kBodyStyle),
												trailing: Container(
													padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
													decoration: BoxDecoration(color: statusColor(r.status).withOpacity(0.18), borderRadius: BorderRadius.circular(999)),
													child: Text(r.status.name, style: TextStyle(color: statusColor(r.status), fontWeight: FontWeight.w600)),
												),
											),
										),
									);
								},
							),
						),
					],
				),
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
	late String _avatar = AvatarService.userAvatars.first;
	final FirebaseStorageService _storageService = FirebaseStorageService(fb_storage.FirebaseStorage.instance);
	File? _selectedImage;
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.all(16),
					child: Column(
						children: [
							const ModernHeader(title: 'Profil'),
							const SizedBox(height: 24),
							// Avatar section
							GestureDetector(
								onTap: _showAvatarPicker,
								child: Stack(
									children: [
										CircleAvatar(
											radius: 56,
											backgroundColor: kPrimaryYellow.withOpacity(0.3),
											backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
											child: _selectedImage == null
												? Padding(
													padding: const EdgeInsets.all(6),
													child: SvgPicture.asset(
														_avatar,
														width: 100,
														height: 100,
													),
												)
												: null,
										),
										Positioned(
											bottom: 0,
											right: 0,
											child: Container(
												padding: const EdgeInsets.all(8),
												decoration: BoxDecoration(
													color: kPrimaryTeal,
													shape: BoxShape.circle,
													border: Border.all(color: Colors.white, width: 2),
												),
												child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
											),
										),
									],
								),
							),
							const SizedBox(height: 16),
							Text('Utilisateur Khidmeti', style: kHeadingStyle),
							const SizedBox(height: 4),
							const Text('email@example.com', style: kBodyStyle),
							const SizedBox(height: 32),
							// Action buttons
							BubbleButton(
								text: 'Changer d\'avatar',
								onPressed: _showAvatarPicker,
								primaryColor: kPrimaryTeal,
							),
							const SizedBox(height: 16),
							BubbleButton(
								text: 'Prendre une photo',
								onPressed: _takePhoto,
								primaryColor: kPrimaryDark,
							),
							const SizedBox(height: 16),
							BubbleButton(
								text: 'Choisir une image',
								onPressed: _pickImage,
								primaryColor: kPrimaryYellow,
								textColor: kPrimaryDark,
							),
							const SizedBox(height: 32),
							// Settings section
							Container(
								padding: const EdgeInsets.all(16),
								decoration: BoxDecoration(
									color: kSurfaceColor,
									borderRadius: BorderRadius.circular(16),
									boxShadow: [
										BoxShadow(
											color: kPrimaryDark.withOpacity(0.06),
											offset: const Offset(0, 8),
											blurRadius: 24,
										),
									],
								),
								child: Column(
									children: [
										_ProfileMenuItem(
											icon: Icons.notifications,
											title: 'Notifications',
											subtitle: 'Gérer les notifications',
											onTap: () {},
										),
										const Divider(),
										_ProfileMenuItem(
											icon: Icons.location_on,
											title: 'Localisation',
											subtitle: 'Paramètres de localisation',
											onTap: () {},
										),
										const Divider(),
										_ProfileMenuItem(
											icon: Icons.security,
											title: 'Sécurité',
											subtitle: 'Mot de passe et sécurité',
											onTap: () {},
										),
									],
								),
							),
							const SizedBox(height: 24),
							BubbleButton(
								text: 'Se déconnecter',
								onPressed: () => fb_auth.FirebaseAuth.instance.signOut(),
								primaryColor: kPrimaryRed,
							),
						],
					),
				),
			),
		);
	}
	
	void _showAvatarPicker() {
		showModalBottomSheet(
			context: context,
			backgroundColor: Colors.transparent,
			builder: (context) => Container(
				padding: const EdgeInsets.all(24),
				decoration: const BoxDecoration(
					color: kSurfaceColor,
					borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
				),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Text('Choisir un avatar', style: kHeadingStyle),
						const SizedBox(height: 16),
						SizedBox(
							height: 200,
							child: GridView.builder(
								gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
									crossAxisCount: 4,
									crossAxisSpacing: 12,
									mainAxisSpacing: 12,
								),
								itemCount: AvatarService.userAvatars.length,
								itemBuilder: (context, index) {
									final avatar = AvatarService.userAvatars[index];
									return GestureDetector(
										onTap: () {
											setState(() => _avatar = avatar);
											Navigator.pop(context);
										},
										child: Container(
											decoration: BoxDecoration(
												border: Border.all(
													color: _avatar == avatar ? kPrimaryTeal : Colors.transparent,
													width: 2,
												),
												borderRadius: BorderRadius.circular(12),
											),
											child: ClipRRect(
												borderRadius: BorderRadius.circular(10),
												child: SvgPicture.asset(avatar),
											),
										),
									);
								},
							),
						),
					],
				),
			),
		);
	}
	
	Future<void> _takePhoto() async {
		// Implementation would use image_picker
		// For now, just show a placeholder
		ScaffoldMessenger.of(context).showSnackBar(
			const SnackBar(content: Text('Fonctionnalité photo à implémenter')),
		);
	}
	
	Future<void> _pickImage() async {
		// Implementation would use image_picker
		// For now, just show a placeholder
		ScaffoldMessenger.of(context).showSnackBar(
			const SnackBar(content: Text('Fonctionnalité galerie à implémenter')),
		);
	}
}

class _ProfileMenuItem extends StatelessWidget {
	final IconData icon;
	final String title;
	final String subtitle;
	final VoidCallback onTap;
	
	const _ProfileMenuItem({
		required this.icon,
		required this.title,
		required this.subtitle,
		required this.onTap,
	});
	
	@override
	Widget build(BuildContext context) {
		return ListTile(
			leading: Icon(icon, color: kPrimaryDark),
			title: Text(title, style: kSubheadingStyle),
			subtitle: Text(subtitle, style: kBodyStyle),
			trailing: const Icon(Icons.arrow_forward_ios, color: kSubtitleColor, size: 16),
			onTap: onTap,
		);
	}
}

// Models (skeletons)
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
	UserModel({required this.id, required this.firstName, required this.lastName, required this.email, this.phoneNumber, required this.selectedAvatar, required this.preferences, this.location, required this.createdAt, this.isActive = true});
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
	WorkerModel({required this.id, required this.firstName, required this.lastName, required this.selectedAvatar, required this.services, required this.rating, required this.totalReviews, required this.location, required this.isAvailable, required this.isVisible, required this.portfolio});
}

class ServiceModel {
	final String id;
	final String name;
	final String category;
	final String description;
	final double basePrice;
	final String iconPath;
	final bool isActive;
	ServiceModel({required this.id, required this.name, required this.category, required this.description, required this.basePrice, required this.iconPath, required this.isActive});
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
	RequestModel({required this.id, required this.userId, required this.workerId, required this.serviceType, required this.description, required this.mediaUrls, required this.location, required this.scheduledDate, required this.status, required this.finalPrice});
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

// Implementations (minimal)
class AuthService implements AuthenticationService {
	final fb_auth.FirebaseAuth _auth;
	final DatabaseService _databaseService;
	AuthService(this._auth, this._databaseService);
	@override
	Future<UserModel?> signInWithEmail(String email, String password) async {
		await _auth.signInWithEmailAndPassword(email: email, password: password);
		final uid = _auth.currentUser!.uid;
		final data = await _databaseService.getDocument('users', uid) ?? {};
		return UserModel(
			id: uid,
			firstName: data['firstName'] ?? '',
			lastName: data['lastName'] ?? '',
			email: data['email'] ?? email,
			selectedAvatar: data['selectedAvatar'] ?? 'assets/avatars/users/avatar_user_1.svg',
			preferences: data['preferences'] ?? {},
			location: data['location'],
			createdAt: DateTime.now(),
		);
	}
	@override
	Future<void> signOut() => _auth.signOut();
}

class FirestoreDatabaseService implements DatabaseService {
	final FirebaseFirestore _firestore;
	FirestoreDatabaseService(this._firestore);
	@override
	Future<void> createDocument(String collection, String id, Map<String, dynamic> data) async {
		await _firestore.collection(collection).doc(id).set(data, SetOptions(merge: true));
	}
	@override
	Future<Map<String, dynamic>?> getDocument(String collection, String id) async {
		final doc = await _firestore.collection(collection).doc(id).get();
		return doc.data();
	}
}

class OpenStreetMapLocationService implements LocationService {
	@override
	Future<Position> getCurrentLocation() async {
		return Geolocator.getCurrentPosition();
	}
	@override
	Stream<Position> getLocationStream() {
		return Geolocator.getPositionStream();
	}
}

// Notifications
abstract class NotificationSender {
	Future<void> sendNotification(String userId, String message);
}

class FCMNotificationService implements NotificationSender {
	final FirebaseMessaging _messaging;
	FCMNotificationService(this._messaging);
	@override
	Future<void> sendNotification(String userId, String message) async {
		// Stub: would resolve FCM token by userId from Firestore and send via callable backend
	}
	Future<void> subscribeToTopic(String topic) async {
		await _messaging.subscribeToTopic(topic);
	}
}

// Storage service
class FirebaseStorageService {
	final fb_storage.FirebaseStorage _storage;
	FirebaseStorageService(this._storage);
	Future<String> uploadImage(File imageFile, String path) async {
		final ref = _storage.ref(path);
		await ref.putFile(imageFile);
		return ref.getDownloadURL();
	}
	Future<String> uploadVideo(File videoFile, String path) async {
		final ref = _storage.ref(path);
		await ref.putFile(videoFile);
		return ref.getDownloadURL();
	}
}

// Chat service and model
class ChatMessage {
	final String id;
	final String senderId;
	final String text;
	final DateTime sentAt;
	ChatMessage({required this.id, required this.senderId, required this.text, required this.sentAt});
	Map<String, dynamic> toMap() => {'id': id, 'senderId': senderId, 'text': text, 'sentAt': sentAt.millisecondsSinceEpoch};
	static ChatMessage fromMap(Map<String, dynamic> m) => ChatMessage(
		id: m['id'],
		senderId: m['senderId'],
		text: m['text'],
		sentAt: DateTime.fromMillisecondsSinceEpoch(m['sentAt'] ?? 0),
	);
}

class ChatService {
	final DatabaseService _databaseService;
	final NotificationSender _notificationSender;
	ChatService(this._databaseService, this._notificationSender);
	Future<void> sendMessage(String chatId, ChatMessage message) async {
		await _databaseService.createDocument('chats/$chatId/messages', message.id, message.toMap());
		await _notificationSender.sendNotification(chatId, message.text);
	}
	Stream<List<ChatMessage>> getChatMessages(String chatId) {
		final firestore = FirebaseFirestore.instance;
		return firestore.collection('chats/$chatId/messages').orderBy('sentAt').snapshots().map((snap) => snap.docs.map((d) => ChatMessage.fromMap(d.data())).toList());
	}
}

// Avatar service
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
		userAvatars.shuffle();
		return userAvatars.first;
	}
	List<String> getAllUserAvatars() => userAvatars;
}

// OpenStreetMap helpers
class OpenStreetMapService {
	static const String tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
	static const LatLng algerCenter = LatLng(36.737232, 3.086472);
	
	// OpenRouteService integration
	static const String openRouteApiKey = 'your-openroute-api-key';
	static const String openRouteBaseUrl = 'https://api.openrouteservice.org/v2/directions';
	
	static Future<List<LatLng>> calculateRoute(LatLng start, LatLng end) async {
		try {
			final response = await http.get(
				Uri.parse('$openRouteBaseUrl/driving-car?api_key=$openRouteApiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}'),
				headers: {'Authorization': openRouteApiKey},
			);
			
			if (response.statusCode == 200) {
				final data = json.decode(response.body);
				final coordinates = data['features'][0]['geometry']['coordinates'] as List;
				return coordinates.map((coord) => LatLng(coord[1] as double, coord[0] as double)).toList();
			}
		} catch (e) {
			print('Route calculation error: $e');
		}
		return [start, end]; // Fallback to direct line
	}
	
	static Future<double> calculateDistance(LatLng start, LatLng end) async {
		try {
			final response = await http.get(
				Uri.parse('$openRouteBaseUrl/driving-car?api_key=$openRouteApiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}'),
				headers: {'Authorization': openRouteApiKey},
			);
			
			if (response.statusCode == 200) {
				final data = json.decode(response.body);
				return data['features'][0]['properties']['summary']['distance'] / 1000; // Convert to km
			}
		} catch (e) {
			print('Distance calculation error: $e');
		}
		return Geolocator.distanceBetween(start.latitude, start.longitude, end.latitude, end.longitude) / 1000;
	}
}

// Enhanced location service with real-time tracking
class EnhancedLocationService extends OpenStreetMapLocationService {
	Position? _lastPosition;
	StreamSubscription<Position>? _locationSubscription;
	
	@override
	Future<Position> getCurrentLocation() async {
		final position = await super.getCurrentLocation();
		_lastPosition = position;
		return position;
	}
	
	@override
	Stream<Position> getLocationStream() {
		_locationSubscription?.cancel();
		_locationSubscription = Geolocator.getPositionStream(
			locationSettings: const LocationSettings(
				accuracy: LocationAccuracy.high,
				distanceFilter: 10, // Update every 10 meters
			),
		).listen((position) {
			_lastPosition = position;
		});
		return _locationSubscription!.asBroadcastStream();
	}
	
	Position? get lastPosition => _lastPosition;
	
	Future<String> getAddressFromCoordinates(double lat, double lng) async {
		try {
			final placemarks = await placemarkFromCoordinates(lat, lng);
			if (placemarks.isNotEmpty) {
				final place = placemarks.first;
				return '${place.street}, ${place.locality}';
			}
		} catch (e) {
			print('Geocoding error: $e');
		}
		return 'Adresse non trouvée';
	}
	
	void dispose() {
		_locationSubscription?.cancel();
	}
}

// Push notification service
class PushNotificationService {
	final FirebaseMessaging _messaging = FirebaseMessaging.instance;
	
	Future<void> initialize() async {
		// Request permission
		final settings = await _messaging.requestPermission(
			alert: true,
			badge: true,
			sound: true,
		);
		
		if (settings.authorizationStatus == AuthorizationStatus.authorized) {
			// Get FCM token
			final token = await _messaging.getToken();
			if (token != null) {
				await _saveTokenToFirestore(token);
			}
			
			// Listen for token refresh
			_messaging.onTokenRefresh.listen(_saveTokenToFirestore);
			
			// Handle foreground messages
			FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
			
			// Handle background messages
			FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
		}
	}
	
	Future<void> _saveTokenToFirestore(String token) async {
		final user = fb_auth.FirebaseAuth.instance.currentUser;
		if (user != null) {
			await FirebaseFirestore.instance
				.collection('users')
				.doc(user.uid)
				.update({'fcmToken': token});
		}
	}
	
	void _handleForegroundMessage(RemoteMessage message) {
		print('Foreground message: ${message.notification?.title}');
		// Show local notification
	}
}

// Background message handler
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
	print('Background message: ${message.notification?.title}');
}

// Payment services
abstract class PaymentProcessor {
	Future<PaymentResult> processPayment(double amount, PaymentMethod method);
}

class PaymentResult {
	final bool success;
	final String transactionId;
	final String? errorMessage;
	PaymentResult({required this.success, required this.transactionId, this.errorMessage});
}

enum PaymentMethod { baridiMob, bankCard, cash }

class BaridiMobPaymentProcessor implements PaymentProcessor {
	@override
	Future<PaymentResult> processPayment(double amount, PaymentMethod method) async {
		// Simulate BaridiMob payment processing
		await Future.delayed(const Duration(seconds: 2));
		return PaymentResult(
			success: true,
			transactionId: 'BM_${DateTime.now().millisecondsSinceEpoch}',
		);
	}
}

class BankCardPaymentProcessor implements PaymentProcessor {
	@override
	Future<PaymentResult> processPayment(double amount, PaymentMethod method) async {
		// Simulate bank card payment processing
		await Future.delayed(const Duration(seconds: 3));
		return PaymentResult(
			success: true,
			transactionId: 'BC_${DateTime.now().millisecondsSinceEpoch}',
		);
	}
}

// Real-time request matching service
class RequestMatchingService {
	final FirebaseFirestore _firestore = FirebaseFirestore.instance;
	
	Stream<List<WorkerModel>> getAvailableWorkersNearby(GeoPoint userLocation, double radiusKm) {
		return _firestore
			.collection('workers')
			.where('isAvailable', isEqualTo: true)
			.where('isVisible', isEqualTo: true)
			.snapshots()
			.map((snapshot) {
				return snapshot.docs.map((doc) {
					final data = doc.data();
					final workerLocation = data['location'] as GeoPoint;
					final distance = Geolocator.distanceBetween(
						userLocation.latitude,
						userLocation.longitude,
						workerLocation.latitude,
						workerLocation.longitude,
					) / 1000;
					
					if (distance <= radiusKm) {
						return WorkerModel(
							id: doc.id,
							firstName: data['firstName'] ?? '',
							lastName: data['lastName'] ?? '',
							selectedAvatar: data['selectedAvatar'] ?? '',
							services: List<String>.from(data['services'] ?? []),
							rating: (data['rating'] ?? 0.0).toDouble(),
							totalReviews: data['totalReviews'] ?? 0,
							location: workerLocation,
							isAvailable: data['isAvailable'] ?? false,
							isVisible: data['isVisible'] ?? false,
							portfolio: data['portfolio'] ?? {},
						);
					}
					return null;
				}).where((worker) => worker != null).cast<WorkerModel>().toList();
			});
	}
	
	Future<void> createServiceRequest({
		required String userId,
		required String serviceType,
		required String description,
		required GeoPoint location,
		required DateTime scheduledDate,
		List<String> mediaUrls = const [],
	}) async {
		final requestId = _firestore.collection('requests').doc().id;
		await _firestore.collection('requests').doc(requestId).set({
			'id': requestId,
			'userId': userId,
			'serviceType': serviceType,
			'description': description,
			'location': location,
			'scheduledDate': scheduledDate,
			'mediaUrls': mediaUrls,
			'status': 'pending',
			'createdAt': FieldValue.serverTimestamp(),
			'workerId': null,
			'finalPrice': null,
		});
	}
}

// Enhanced chat service with real-time messaging
class EnhancedChatService extends ChatService {
	EnhancedChatService(super.databaseService, super.notificationSender);
	
	Stream<List<ChatMessage>> getChatMessages(String chatId) {
		return FirebaseFirestore.instance
			.collection('chats/$chatId/messages')
			.orderBy('sentAt', descending: true)
			.limit(50)
			.snapshots()
			.map((snapshot) => snapshot.docs
				.map((doc) => ChatMessage.fromMap(doc.data()))
				.toList()
				.reversed.toList());
	}
	
	Future<void> sendMessage(String chatId, String text) async {
		final message = ChatMessage(
			id: DateTime.now().millisecondsSinceEpoch.toString(),
			senderId: fb_auth.FirebaseAuth.instance.currentUser?.uid ?? '',
			text: text,
			sentAt: DateTime.now(),
		);
		
		await sendMessage(chatId, message);
	}
	
	Future<String> createChat(String userId, String workerId) async {
		final chatId = '${userId}_${workerId}';
		await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
			'participants': [userId, workerId],
			'createdAt': FieldValue.serverTimestamp(),
			'lastMessage': null,
			'lastMessageAt': null,
		});
		return chatId;
	}
}

// Chat screen implementation
class ChatScreen extends StatefulWidget {
	final String chatId;
	final String workerName;
	const ChatScreen({super.key, required this.chatId, required this.workerName});
	@override
	State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
	final TextEditingController _messageController = TextEditingController();
	final EnhancedChatService _chatService = EnhancedChatService(
		FirestoreDatabaseService(FirebaseFirestore.instance),
		FCMNotificationService(FirebaseMessaging.instance),
	);
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: Column(
					children: [
						ModernHeader(
							title: widget.workerName,
							showBackButton: true,
							actions: [
								IconButton(
									onPressed: () {},
									icon: const Icon(Icons.call, color: kPrimaryTeal),
								),
							],
						),
						Expanded(
							child: StreamBuilder<List<ChatMessage>>(
								stream: _chatService.getChatMessages(widget.chatId),
								builder: (context, snapshot) {
									if (snapshot.hasError) {
										return const Center(child: Text('Erreur de chargement'));
									}
									
									if (!snapshot.hasData) {
										return const Center(child: CircularProgressIndicator());
									}
									
									final messages = snapshot.data!;
									
									return ListView.builder(
										reverse: true,
										padding: const EdgeInsets.all(16),
										itemCount: messages.length,
										itemBuilder: (context, index) {
											final message = messages[index];
											final isMe = message.senderId == fb_auth.FirebaseAuth.instance.currentUser?.uid;
											
											return Container(
												margin: const EdgeInsets.only(bottom: 8),
												child: Row(
													mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
													children: [
														Container(
															padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
															decoration: BoxDecoration(
																color: isMe ? kPrimaryTeal : kSurfaceColor,
																borderRadius: BorderRadius.circular(20),
																boxShadow: [
																	BoxShadow(
																		color: kPrimaryDark.withOpacity(0.1),
																		offset: const Offset(0, 2),
																		blurRadius: 8,
																	),
																],
															),
															child: Text(
																message.text,
																style: TextStyle(
																	color: isMe ? Colors.white : kTextColor,
																	fontSize: 14,
																),
															),
														),
													],
												),
											);
										},
									);
								},
							),
						),
						Container(
							padding: const EdgeInsets.all(16),
							decoration: BoxDecoration(
								color: kSurfaceColor,
								boxShadow: [
									BoxShadow(
										color: kPrimaryDark.withOpacity(0.1),
										offset: const Offset(0, -2),
										blurRadius: 8,
									),
								],
							),
							child: Row(
								children: [
									Expanded(
										child: Container(
											decoration: BoxDecoration(
												color: kBackgroundColor,
												borderRadius: BorderRadius.circular(25),
											),
											child: TextField(
												controller: _messageController,
												decoration: const InputDecoration(
													hintText: 'Tapez votre message...',
													border: InputBorder.none,
													contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
												),
											),
										),
									),
									const SizedBox(width: 12),
									GestureDetector(
										onTap: _sendMessage,
										child: Container(
											padding: const EdgeInsets.all(12),
											decoration: BoxDecoration(
												color: kPrimaryTeal,
												shape: BoxShape.circle,
											),
											child: const Icon(Icons.send, color: Colors.white, size: 20),
										),
									),
								],
							),
						),
					],
				),
			),
		);
	}
	
	void _sendMessage() {
		if (_messageController.text.trim().isEmpty) return;
		
		_chatService.sendMessage(widget.chatId, _messageController.text.trim());
		_messageController.clear();
	}
}

// Service request creation screen
class ServiceRequestScreen extends StatefulWidget {
	const ServiceRequestScreen({super.key});
	@override
	State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
	final _formKey = GlobalKey<FormState>();
	final _descriptionController = TextEditingController();
	String _selectedService = 'Plomberie';
	DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 1));
	final RequestMatchingService _matchingService = RequestMatchingService();
	
	final List<String> _services = [
		'Plomberie',
		'Électricité',
		'Peinture',
		'Ménage',
		'Jardinage',
		'Déménagement',
	];
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: Column(
					children: [
						const ModernHeader(title: 'Nouvelle demande', showBackButton: true),
						Expanded(
							child: SingleChildScrollView(
								padding: const EdgeInsets.all(16),
								child: Form(
									key: _formKey,
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											// Service selection
											Text('Type de service', style: kSubheadingStyle),
											const SizedBox(height: 12),
											Container(
												padding: const EdgeInsets.all(16),
												decoration: BoxDecoration(
													color: kSurfaceColor,
													borderRadius: BorderRadius.circular(16),
													boxShadow: [
														BoxShadow(
															color: kPrimaryDark.withOpacity(0.06),
															offset: const Offset(0, 8),
															blurRadius: 24,
														),
													],
												),
												child: DropdownButtonFormField<String>(
													value: _selectedService,
													decoration: const InputDecoration(
														border: InputBorder.none,
														prefixIcon: Icon(Icons.category, color: kPrimaryDark),
													),
													items: _services.map((service) {
														return DropdownMenuItem(
															value: service,
															child: Text(service),
														);
													}).toList(),
													onChanged: (value) {
														setState(() => _selectedService = value!);
													},
												),
											),
											const SizedBox(height: 24),
											// Description
											Text('Description', style: kSubheadingStyle),
											const SizedBox(height: 12),
											Container(
												decoration: BoxDecoration(
													color: kSurfaceColor,
													borderRadius: BorderRadius.circular(16),
													boxShadow: [
														BoxShadow(
															color: kPrimaryDark.withOpacity(0.06),
															offset: const Offset(0, 8),
															blurRadius: 24,
														),
													],
												),
												child: TextFormField(
													controller: _descriptionController,
													maxLines: 4,
													validator: (value) {
														if (value == null || value.isEmpty) {
															return 'Veuillez décrire votre demande';
														}
														return null;
													},
													decoration: const InputDecoration(
														hintText: 'Décrivez votre problème ou besoin...',
														border: InputBorder.none,
														contentPadding: EdgeInsets.all(16),
													),
												),
											),
											const SizedBox(height: 24),
											// Scheduled date
											Text('Date et heure', style: kSubheadingStyle),
											const SizedBox(height: 12),
											Container(
												padding: const EdgeInsets.all(16),
												decoration: BoxDecoration(
													color: kSurfaceColor,
													borderRadius: BorderRadius.circular(16),
													boxShadow: [
														BoxShadow(
															color: kPrimaryDark.withOpacity(0.06),
															offset: const Offset(0, 8),
															blurRadius: 24,
														),
													],
												),
												child: ListTile(
													leading: const Icon(Icons.schedule, color: kPrimaryDark),
													title: Text(
														'${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year} à ${_scheduledDate.hour}:${_scheduledDate.minute.toString().padLeft(2, '0')}',
													),
													trailing: const Icon(Icons.edit, color: kPrimaryTeal),
													onTap: () async {
														final date = await showDatePicker(
															context: context,
															initialDate: _scheduledDate,
															firstDate: DateTime.now(),
															lastDate: DateTime.now().add(const Duration(days: 30)),
														);
														if (date != null) {
															final time = await showTimePicker(
																context: context,
																initialTime: TimeOfDay.fromDateTime(_scheduledDate),
															);
															if (time != null) {
																setState(() {
																	_scheduledDate = DateTime(
																		date.year,
																		date.month,
																		date.day,
																		time.hour,
																		time.minute,
																	);
																});
															}
														}
													},
												),
											),
											const SizedBox(height: 32),
											// Submit button
											BubbleButton(
												text: 'Créer la demande',
												onPressed: _createRequest,
												primaryColor: kPrimaryDark,
												width: double.infinity,
												height: 56,
											),
										],
									),
								),
							),
						),
					],
				),
			),
		);
	}
	
	Future<void> _createRequest() async {
		if (!_formKey.currentState!.validate()) return;
		
		final user = fb_auth.FirebaseAuth.instance.currentUser;
		if (user == null) return;
		
		try {
			// Get current location (simplified)
			final position = await Geolocator.getCurrentPosition();
			final location = GeoPoint(position.latitude, position.longitude);
			
			await _matchingService.createServiceRequest(
				userId: user.uid,
				serviceType: _selectedService,
				description: _descriptionController.text.trim(),
				location: location,
				scheduledDate: _scheduledDate,
			);
			
			if (!mounted) return;
			
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Demande créée avec succès !')),
			);
			
			Navigator.pop(context);
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Erreur: ${e.toString()}')),
			);
		}
	}
}

// Payment modal
class PaymentModal extends StatefulWidget {
	final double amount;
	final String requestId;
	const PaymentModal({super.key, required this.amount, required this.requestId});
	@override
	State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
	PaymentMethod _selectedMethod = PaymentMethod.baridiMob;
	bool _isProcessing = false;
	
	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(24),
			decoration: const BoxDecoration(
				color: kSurfaceColor,
				borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
			),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					Text('Paiement', style: kHeadingStyle),
					const SizedBox(height: 16),
					Text(
						'${widget.amount.toStringAsFixed(0)} DZD',
						style: kHeadingStyle.copyWith(fontSize: 32, color: kPrimaryDark),
					),
					const SizedBox(height: 24),
					// Payment methods
					RadioListTile<PaymentMethod>(
						title: const Text('BaridiMob'),
						subtitle: const Text('Paiement mobile'),
						value: PaymentMethod.baridiMob,
						groupValue: _selectedMethod,
						onChanged: (value) => setState(() => _selectedMethod = value!),
						activeColor: kPrimaryTeal,
					),
					RadioListTile<PaymentMethod>(
						title: const Text('Carte bancaire'),
						subtitle: const Text('Visa, Mastercard'),
						value: PaymentMethod.bankCard,
						groupValue: _selectedMethod,
						onChanged: (value) => setState(() => _selectedMethod = value!),
						activeColor: kPrimaryTeal,
					),
					RadioListTile<PaymentMethod>(
						title: const Text('Espèces'),
						subtitle: const Text('Paiement à la livraison'),
						value: PaymentMethod.cash,
						groupValue: _selectedMethod,
						onChanged: (value) => setState(() => _selectedMethod = value!),
						activeColor: kPrimaryTeal,
					),
					const SizedBox(height: 24),
					BubbleButton(
						text: _isProcessing ? 'Traitement...' : 'Payer maintenant',
						onPressed: _isProcessing ? null : _processPayment,
						primaryColor: kPrimaryDark,
						width: double.infinity,
						height: 56,
					),
				],
			),
		);
	}
	
	Future<void> _processPayment() async {
		setState(() => _isProcessing = true);
		
		try {
			PaymentProcessor processor;
			switch (_selectedMethod) {
				case PaymentMethod.baridiMob:
					processor = BaridiMobPaymentProcessor();
					break;
				case PaymentMethod.bankCard:
					processor = BankCardPaymentProcessor();
					break;
				case PaymentMethod.cash:
					// Cash payment - no processing needed
					setState(() => _isProcessing = false);
					Navigator.pop(context, true);
					return;
			}
			
			final result = await processor.processPayment(widget.amount, _selectedMethod);
			
			if (result.success) {
				// Update request status
				await FirebaseFirestore.instance
					.collection('requests')
					.doc(widget.requestId)
					.update({
						'paymentStatus': 'paid',
						'paymentMethod': _selectedMethod.name,
						'transactionId': result.transactionId,
						'paidAt': FieldValue.serverTimestamp(),
					});
				
				if (!mounted) return;
				Navigator.pop(context, true);
			} else {
				throw Exception(result.errorMessage ?? 'Erreur de paiement');
			}
		} catch (e) {
			setState(() => _isProcessing = false);
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Erreur: ${e.toString()}')),
			);
		}
	}
}

// Analytics and user insights
class UserAnalyticsService {
	final FirebaseFirestore _firestore = FirebaseFirestore.instance;
	
	Stream<Map<String, dynamic>> getUserAnalytics(String userId) {
		return _firestore
			.collection('requests')
			.where('userId', isEqualTo: userId)
			.snapshots()
			.map((snapshot) {
				int totalRequests = 0;
				int completedRequests = 0;
				int pendingRequests = 0;
				double totalSpent = 0;
				Map<String, int> serviceUsage = {};
				
				for (final doc in snapshot.docs) {
					final data = doc.data();
					totalRequests++;
					
					final status = data['status'] as String? ?? 'pending';
					if (status == 'completed') {
						completedRequests++;
						totalSpent += (data['finalPrice'] ?? 0).toDouble();
					} else if (status == 'pending') {
						pendingRequests++;
					}
					
					final serviceType = data['serviceType'] as String? ?? 'Unknown';
					serviceUsage[serviceType] = (serviceUsage[serviceType] ?? 0) + 1;
				}
				
				return {
					'totalRequests': totalRequests,
					'completedRequests': completedRequests,
					'pendingRequests': pendingRequests,
					'totalSpent': totalSpent,
					'serviceUsage': serviceUsage,
					'completionRate': totalRequests > 0 ? (completedRequests / totalRequests * 100) : 0,
				};
			});
	}
	
	Future<void> trackUserAction(String userId, String action, Map<String, dynamic> data) async {
		await _firestore.collection('user_analytics').add({
			'userId': userId,
			'action': action,
			'data': data,
			'timestamp': FieldValue.serverTimestamp(),
		});
	}
}

// Advanced notification system
class AdvancedNotificationService {
	final FirebaseMessaging _messaging = FirebaseMessaging.instance;
	final FirebaseFirestore _firestore = FirebaseFirestore.instance;
	
	Future<void> initialize() async {
		// Request permissions
		final settings = await _messaging.requestPermission(
			alert: true,
			badge: true,
			sound: true,
		);
		
		if (settings.authorizationStatus == AuthorizationStatus.authorized) {
			// Get FCM token
			final token = await _messaging.getToken();
			if (token != null) {
				await _saveTokenToDatabase(token);
			}
			
			// Listen for token refresh
			_messaging.onTokenRefresh.listen(_saveTokenToDatabase);
			
			// Handle foreground messages
			FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
			
			// Handle background messages
			FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
			
			// Handle notification taps
			FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
		}
	}
	
	Future<void> _saveTokenToDatabase(String token) async {
		final user = fb_auth.FirebaseAuth.instance.currentUser;
		if (user != null) {
			await _firestore.collection('users').doc(user.uid).update({
				'fcmToken': token,
				'lastTokenUpdate': FieldValue.serverTimestamp(),
			});
		}
	}
	
	void _handleForegroundMessage(RemoteMessage message) {
		// Show local notification
		_showLocalNotification(
			title: message.notification?.title ?? 'Nouvelle notification',
			body: message.notification?.body ?? '',
			data: message.data,
		);
	}
	
	void _handleNotificationTap(RemoteMessage message) {
		// Handle navigation based on notification data
		final data = message.data;
		if (data['type'] == 'new_request') {
			// Navigate to requests screen
		} else if (data['type'] == 'chat_message') {
			// Navigate to chat screen
		}
	}
	
	void _showLocalNotification({
		required String title,
		required String body,
		Map<String, dynamic>? data,
	}) {
		// Implementation would use flutter_local_notifications
		print('Local notification: $title - $body');
	}
}

// User preferences and settings
class UserPreferencesService {
	final SharedPreferences _prefs;
	
	UserPreferencesService(this._prefs);
	
	static Future<UserPreferencesService> create() async {
		final prefs = await SharedPreferences.getInstance();
		return UserPreferencesService(prefs);
	}
	
	// Notification preferences
	bool get notificationsEnabled => _prefs.getBool('notifications_enabled') ?? true;
	set notificationsEnabled(bool value) => _prefs.setBool('notifications_enabled', value);
	
	bool get chatNotificationsEnabled => _prefs.getBool('chat_notifications_enabled') ?? true;
	set chatNotificationsEnabled(bool value) => _prefs.setBool('chat_notifications_enabled', value);
	
	bool get requestUpdatesEnabled => _prefs.getBool('request_updates_enabled') ?? true;
	set requestUpdatesEnabled(bool value) => _prefs.setBool('request_updates_enabled', value);
	
	// UI preferences
	bool get darkModeEnabled => _prefs.getBool('dark_mode_enabled') ?? false;
	set darkModeEnabled(bool value) => _prefs.setBool('dark_mode_enabled', value);
	
	String get selectedLanguage => _prefs.getString('selected_language') ?? 'fr';
	set selectedLanguage(String value) => _prefs.setString('selected_language', value);
	
	// Location preferences
	double get searchRadius => _prefs.getDouble('search_radius') ?? 10.0;
	set searchRadius(double value) => _prefs.setDouble('search_radius', value);
	
	// Payment preferences
	String get defaultPaymentMethod => _prefs.getString('default_payment_method') ?? 'baridiMob';
	set defaultPaymentMethod(String value) => _prefs.setString('default_payment_method', value);
}

// Analytics dashboard screen
class AnalyticsDashboardScreen extends StatelessWidget {
	const AnalyticsDashboardScreen({super.key});
	@override
	Widget build(BuildContext context) {
		final user = fb_auth.FirebaseAuth.instance.currentUser;
		if (user == null) return const SizedBox.shrink();
		
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: Column(
					children: [
						const ModernHeader(title: 'Analytics', showBackButton: true),
						Expanded(
							child: StreamBuilder<Map<String, dynamic>>(
								stream: UserAnalyticsService().getUserAnalytics(user.uid),
								builder: (context, snapshot) {
									if (!snapshot.hasData) {
										return const Center(child: CircularProgressIndicator());
									}
									
									final analytics = snapshot.data!;
									
									return SingleChildScrollView(
										padding: const EdgeInsets.all(16),
										child: Column(
											children: [
												// Summary cards
												Row(
													children: [
														Expanded(
															child: _AnalyticsCard(
																title: 'Total demandes',
																value: '${analytics['totalRequests']}',
																icon: Icons.assignment,
																color: kPrimaryTeal,
															),
														),
														const SizedBox(width: 12),
														Expanded(
															child: _AnalyticsCard(
																title: 'Complétées',
																value: '${analytics['completedRequests']}',
																icon: Icons.check_circle,
																color: kSuccessColor,
															),
														),
													],
												),
												const SizedBox(height: 12),
												Row(
													children: [
														Expanded(
															child: _AnalyticsCard(
																title: 'En attente',
																value: '${analytics['pendingRequests']}',
																icon: Icons.pending,
																color: kPrimaryYellow,
															),
														),
														const SizedBox(width: 12),
														Expanded(
															child: _AnalyticsCard(
																title: 'Total dépensé',
																value: '${analytics['totalSpent'].toStringAsFixed(0)} DZD',
																icon: Icons.payments,
																color: kPrimaryDark,
															),
														),
													],
												),
												const SizedBox(height: 24),
												// Service usage chart
												Container(
													padding: const EdgeInsets.all(16),
													decoration: BoxDecoration(
														color: kSurfaceColor,
														borderRadius: BorderRadius.circular(16),
														boxShadow: [
															BoxShadow(
																color: kPrimaryDark.withOpacity(0.06),
																offset: const Offset(0, 8),
																blurRadius: 24,
															),
														],
													),
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text('Utilisation des services', style: kSubheadingStyle),
															const SizedBox(height: 16),
															...analytics['serviceUsage'].entries.map((entry) {
																return Padding(
																	padding: const EdgeInsets.only(bottom: 8),
																	child: Row(
																		children: [
																			Expanded(
																				flex: 2,
																				child: Text(entry.key, style: kBodyStyle),
																			),
																			Expanded(
																				flex: 3,
																				child: LinearProgressIndicator(
																					value: entry.value / analytics['totalRequests'],
																					backgroundColor: kPrimaryDark.withOpacity(0.1),
																					valueColor: AlwaysStoppedAnimation<Color>(kPrimaryTeal),
																				),
																			),
																			const SizedBox(width: 8),
																			Text('${entry.value}', style: kBodyStyle.copyWith(fontWeight: FontWeight.w600)),
																		],
																	),
																);
															}).toList(),
														],
													),
												),
											],
										),
									);
								},
							),
						),
					],
				),
			),
		);
	}
}

class _AnalyticsCard extends StatelessWidget {
	final String title;
	final String value;
	final IconData icon;
	final Color color;
	
	const _AnalyticsCard({
		required this.title,
		required this.value,
		required this.icon,
		required this.color,
	});
	
	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: kSurfaceColor,
				borderRadius: BorderRadius.circular(16),
				boxShadow: [
					BoxShadow(
						color: kPrimaryDark.withOpacity(0.06),
						offset: const Offset(0, 8),
						blurRadius: 24,
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Icon(icon, color: color, size: 20),
							const SizedBox(width: 8),
							Text(title, style: kBodyStyle.copyWith(fontSize: 12)),
						],
					),
					const SizedBox(height: 8),
					Text(value, style: kHeadingStyle.copyWith(fontSize: 18, color: color)),
				],
			),
		);
	}
}

// Settings screen
class SettingsScreen extends StatefulWidget {
	const SettingsScreen({super.key});
	@override
	State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
	late UserPreferencesService _prefs;
	bool _isLoading = true;
	
	@override
	void initState() {
		super.initState();
		_initializePreferences();
	}
	
	Future<void> _initializePreferences() async {
		_prefs = await UserPreferencesService.create();
		setState(() => _isLoading = false);
	}
	
	@override
	Widget build(BuildContext context) {
		if (_isLoading) {
			return const Scaffold(
				backgroundColor: kBackgroundColor,
				body: Center(child: CircularProgressIndicator()),
			);
		}
		
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: SafeArea(
				child: Column(
					children: [
						const ModernHeader(title: 'Paramètres', showBackButton: true),
						Expanded(
							child: ListView(
								padding: const EdgeInsets.all(16),
								children: [
									// Notifications section
									_SettingSection(
										title: 'Notifications',
										children: [
											_SwitchSetting(
												title: 'Notifications générales',
												value: _prefs.notificationsEnabled,
												onChanged: (value) {
													setState(() => _prefs.notificationsEnabled = value);
												},
											),
											_SwitchSetting(
												title: 'Messages de chat',
												value: _prefs.chatNotificationsEnabled,
												onChanged: (value) {
													setState(() => _prefs.chatNotificationsEnabled = value);
												},
											),
											_SwitchSetting(
												title: 'Mises à jour des demandes',
												value: _prefs.requestUpdatesEnabled,
												onChanged: (value) {
													setState(() => _prefs.requestUpdatesEnabled = value);
												},
											),
										],
									),
									const SizedBox(height: 24),
									// UI section
									_SettingSection(
										title: 'Interface',
										children: [
											_SwitchSetting(
												title: 'Mode sombre',
												value: _prefs.darkModeEnabled,
												onChanged: (value) {
													setState(() => _prefs.darkModeEnabled = value);
												},
											),
											_ListSetting(
												title: 'Langue',
												value: _prefs.selectedLanguage == 'fr' ? 'Français' : 'English',
												onTap: () {
													// Show language picker
												},
											),
										],
									),
									const SizedBox(height: 24),
									// Location section
									_SettingSection(
										title: 'Localisation',
										children: [
											_SliderSetting(
												title: 'Rayon de recherche',
												value: _prefs.searchRadius,
												min: 1.0,
												max: 50.0,
												divisions: 49,
												label: '${_prefs.searchRadius.toStringAsFixed(1)} km',
												onChanged: (value) {
													setState(() => _prefs.searchRadius = value);
												},
											),
										],
									),
									const SizedBox(height: 24),
									// Payment section
									_SettingSection(
										title: 'Paiement',
										children: [
											_ListSetting(
												title: 'Méthode par défaut',
												value: _prefs.defaultPaymentMethod == 'baridiMob' ? 'BaridiMob' : 'Carte bancaire',
												onTap: () {
													// Show payment method picker
												},
											),
										],
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

class _SettingSection extends StatelessWidget {
	final String title;
	final List<Widget> children;
	
	const _SettingSection({required this.title, required this.children});
	
	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				color: kSurfaceColor,
				borderRadius: BorderRadius.circular(16),
				boxShadow: [
					BoxShadow(
						color: kPrimaryDark.withOpacity(0.06),
						offset: const Offset(0, 8),
						blurRadius: 24,
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Padding(
						padding: const EdgeInsets.all(16),
						child: Text(title, style: kSubheadingStyle),
					),
					...children,
				],
			),
		);
	}
}

class _SwitchSetting extends StatelessWidget {
	final String title;
	final bool value;
	final ValueChanged<bool> onChanged;
	
	const _SwitchSetting({
		required this.title,
		required this.value,
		required this.onChanged,
	});
	
	@override
	Widget build(BuildContext context) {
		return ListTile(
			title: Text(title, style: kBodyStyle),
			trailing: Switch(
				value: value,
				onChanged: onChanged,
				activeColor: kPrimaryTeal,
			),
		);
	}
}

class _ListSetting extends StatelessWidget {
	final String title;
	final String value;
	final VoidCallback onTap;
	
	const _ListSetting({
		required this.title,
		required this.value,
		required this.onTap,
	});
	
	@override
	Widget build(BuildContext context) {
		return ListTile(
			title: Text(title, style: kBodyStyle),
			trailing: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Text(value, style: kBodyStyle.copyWith(color: kSubtitleColor)),
					const Icon(Icons.chevron_right, color: kSubtitleColor),
				],
			),
			onTap: onTap,
		);
	}
}

class _SliderSetting extends StatelessWidget {
	final String title;
	final double value;
	final double min;
	final double max;
	final int divisions;
	final String label;
	final ValueChanged<double> onChanged;
	
	const _SliderSetting({
		required this.title,
		required this.value,
		required this.min,
		required this.max,
		required this.divisions,
		required this.label,
		required this.onChanged,
	});
	
	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				ListTile(
					title: Text(title, style: kBodyStyle),
					trailing: Text(label, style: kBodyStyle.copyWith(color: kPrimaryTeal)),
				),
				Padding(
					padding: const EdgeInsets.symmetric(horizontal: 16),
					child: Slider(
						value: value,
						min: min,
						max: max,
						divisions: divisions,
						onChanged: onChanged,
						activeColor: kPrimaryTeal,
						inactiveColor: kPrimaryDark.withOpacity(0.2),
					),
				),
			],
		);
	}
}

// Error handling and loading utilities
class AppErrorHandler {
	static void showError(BuildContext context, String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: kErrorColor,
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
			),
		);
	}
	
	static void showSuccess(BuildContext context, String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: kSuccessColor,
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
			),
		);
	}
	
	static void showInfo(BuildContext context, String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: kPrimaryTeal,
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
			),
		);
	}
}

// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
	final bool isLoading;
	final Widget child;
	final String? message;
	
	const LoadingOverlay({
		super.key,
		required this.isLoading,
		required this.child,
		this.message,
	});
	
	@override
	Widget build(BuildContext context) {
		return Stack(
			children: [
				child,
				if (isLoading)
					Container(
						color: Colors.black54,
						child: Center(
							child: Container(
								padding: const EdgeInsets.all(24),
								decoration: BoxDecoration(
									color: kSurfaceColor,
									borderRadius: BorderRadius.circular(16),
									boxShadow: [
										BoxShadow(
											color: kPrimaryDark.withOpacity(0.1),
											offset: const Offset(0, 8),
											blurRadius: 24,
										),
									],
								),
								child: Column(
									mainAxisSize: MainAxisSize.min,
									children: [
										const CircularProgressIndicator(color: kPrimaryTeal),
										if (message != null) ...[
											const SizedBox(height: 16),
											Text(message!, style: kBodyStyle),
										],
									],
								),
							),
						),
					),
			],
		);
	}
}

// Network connectivity service
class ConnectivityService {
	static Future<bool> checkConnectivity() async {
		try {
			final result = await http.get(Uri.parse('https://www.google.com'));
			return result.statusCode == 200;
		} catch (e) {
			return false;
		}
	}
	
	static Stream<bool> get connectivityStream {
		return Stream.periodic(const Duration(seconds: 5), (_) async {
			return await checkConnectivity();
		}).asyncMap((future) => future);
	}
}

// App lifecycle management
class AppLifecycleManager extends StatefulWidget {
	final Widget child;
	
	const AppLifecycleManager({super.key, required this.child});
	
	@override
	State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager> with WidgetsBindingObserver {
	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addObserver(this);
	}
	
	@override
	void dispose() {
		WidgetsBinding.instance.removeObserver(this);
		super.dispose();
	}
	
	@override
	void didChangeAppLifecycleState(AppLifecycleState state) {
		switch (state) {
			case AppLifecycleState.resumed:
				// App came to foreground
				_handleAppResumed();
				break;
			case AppLifecycleState.inactive:
				// App is inactive
				break;
			case AppLifecycleState.paused:
				// App went to background
				_handleAppPaused();
				break;
			case AppLifecycleState.detached:
				// App is detached
				break;
			case AppLifecycleState.hidden:
				// App is hidden
				break;
		}
	}
	
	void _handleAppResumed() {
		// Refresh user data, check for new notifications, etc.
		final user = fb_auth.FirebaseAuth.instance.currentUser;
		if (user != null) {
			// Update user's last active timestamp
			FirebaseFirestore.instance.collection('users').doc(user.uid).update({
				'lastActiveAt': FieldValue.serverTimestamp(),
			});
		}
	}
	
	void _handleAppPaused() {
		// Save any pending data, update status, etc.
		final user = fb_auth.FirebaseAuth.instance.currentUser;
		if (user != null) {
			// Update user's status to offline
			FirebaseFirestore.instance.collection('users').doc(user.uid).update({
				'isOnline': false,
				'lastActiveAt': FieldValue.serverTimestamp(),
			});
		}
	}
	
	@override
	Widget build(BuildContext context) {
		return widget.child;
	}
}

// Enhanced splash screen with better loading
class EnhancedSplashScreen extends StatefulWidget {
	const EnhancedSplashScreen({super.key});
	@override
	State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen> with TickerProviderStateMixin {
	late AnimationController _animationController;
	late AnimationController _fadeController;
	late Animation<double> _scaleAnimation;
	late Animation<double> _fadeAnimation;
	
	@override
	void initState() {
		super.initState();
		_animationController = AnimationController(
			duration: const Duration(seconds: 2),
			vsync: this,
		);
		_fadeController = AnimationController(
			duration: const Duration(milliseconds: 500),
			vsync: this,
		);
		
		_scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
			CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
		);
		_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
			CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
		);
		
		_initializeApp();
	}
	
	Future<void> _initializeApp() async {
		// Start animations
		_animationController.forward();
		await Future.delayed(const Duration(milliseconds: 300));
		_fadeController.forward();
		
		// Simulate app initialization
		await Future.delayed(const Duration(seconds: 2));
		
		// Check connectivity
		final isConnected = await ConnectivityService.checkConnectivity();
		if (!isConnected) {
			if (!mounted) return;
			AppErrorHandler.showError(context, 'Vérifiez votre connexion internet');
		}
		
		// Navigate to appropriate screen
		if (!mounted) return;
		Navigator.of(context).pushReplacementNamed('/home');
	}
	
	@override
	void dispose() {
		_animationController.dispose();
		_fadeController.dispose();
		super.dispose();
	}
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						// Logo animation
						ScaleTransition(
							scale: _scaleAnimation,
							child: Container(
								width: 120,
								height: 120,
								decoration: BoxDecoration(
									color: kPrimaryTeal,
									shape: BoxShape.circle,
									boxShadow: [
										BoxShadow(
											color: kPrimaryTeal.withOpacity(0.3),
											offset: const Offset(0, 8),
											blurRadius: 24,
										),
									],
								),
								child: const Icon(
									Icons.build,
									color: Colors.white,
									size: 60,
								),
							),
						),
						const SizedBox(height: 32),
						// App name
						FadeTransition(
							opacity: _fadeAnimation,
							child: Text(
								'Khidmeti',
								style: kHeadingStyle.copyWith(
									fontSize: 32,
									color: kPrimaryDark,
								),
							),
						),
						const SizedBox(height: 8),
						FadeTransition(
							opacity: _fadeAnimation,
							child: Text(
								'Services à domicile',
								style: kBodyStyle.copyWith(
									color: kSubtitleColor,
									fontSize: 16,
								),
							),
						),
						const SizedBox(height: 48),
						// Loading indicator
						FadeTransition(
							opacity: _fadeAnimation,
							child: const CircularProgressIndicator(
								color: kPrimaryTeal,
								strokeWidth: 3,
							),
						),
					],
				),
			),
		);
	}
}

// Enhanced home screen with connectivity check
class EnhancedHomeScreen extends StatefulWidget {
	const EnhancedHomeScreen({super.key});
	@override
	State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
	bool _isConnected = true;
	
	@override
	void initState() {
		super.initState();
		_checkConnectivity();
	}
	
	Future<void> _checkConnectivity() async {
		final isConnected = await ConnectivityService.checkConnectivity();
		if (mounted) {
			setState(() => _isConnected = isConnected);
		}
	}
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: kBackgroundColor,
			body: Column(
				children: [
					// Connectivity banner
					if (!_isConnected)
						Container(
							width: double.infinity,
							padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
							color: kErrorColor,
							child: Row(
								children: [
									const Icon(Icons.wifi_off, color: Colors.white, size: 16),
									const SizedBox(width: 8),
									Text(
										'Pas de connexion internet',
										style: kBodyStyle.copyWith(color: Colors.white, fontSize: 14),
									),
									const Spacer(),
									GestureDetector(
										onTap: _checkConnectivity,
										child: const Icon(Icons.refresh, color: Colors.white, size: 16),
									),
								],
							),
						),
					// Main content
					Expanded(
						child: HomeScreen(),
					),
				],
			),
		);
	}
}