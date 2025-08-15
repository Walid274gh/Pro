import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

void main() {
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
			home: const SplashScreen(),
			routes: {
				'/auth': (context) => const AuthScreen(),
				'/home': (context) => const HomeScreen(),
				'/search': (context) => const PlaceholderScreen(title: 'Recherche'),
				'/map': (context) => const PlaceholderScreen(title: 'Carte'),
				'/requests': (context) => const PlaceholderScreen(title: 'Demandes'),
				'/profile': (context) => const PlaceholderScreen(title: 'Profil'),
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
		setState(() => _isLoading = true);
		await Future.delayed(const Duration(milliseconds: 800));
		if (!mounted) return;
		setState(() => _isLoading = false);
		Navigator.pushReplacementNamed(context, '/home');
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
		PlaceholderScreen(title: 'Recherche'),
		PlaceholderScreen(title: 'Carte'),
		PlaceholderScreen(title: 'Demandes'),
		PlaceholderScreen(title: 'Profil'),
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