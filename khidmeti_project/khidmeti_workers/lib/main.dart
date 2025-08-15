import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

void main() {
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
			home: const SplashScreen(),
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

class WorkerMapScreen extends StatelessWidget {
	const WorkerMapScreen({super.key});
	static const LatLng algerCenter = LatLng(36.737232, 3.086472);
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
								options: const MapOptions(initialCenter: algerCenter, initialZoom: 13),
								children: const [
									TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'khidmeti.workers'),
								],
							),
						),
						Positioned(
							left: 16,
							right: 16,
							bottom: 24,
							child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.near_me), label: const Text('Aller à une intervention')),
						),
					],
				),
			),
		);
	}
}

class WorkersHomeShell extends StatefulWidget {
	const WorkersHomeShell({super.key});
	@override
	State<WorkersHomeShell> createState() => _WorkersHomeShellState();
}

class _WorkersHomeShellState extends State<WorkersHomeShell> {
	int _index = 0;
	final List<Widget> _screens = const [DashboardScreen(), WorkerMapScreen()];
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
					],
				),
			),
		);
	}
}