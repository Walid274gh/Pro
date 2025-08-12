import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

final TextStyle kBodyStyle = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kSubtitleColor,
  height: 1.4,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  runApp(const WorkerApp());
}

class WorkerApp extends StatelessWidget {
  const WorkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: kPrimaryDark,
      background: kBackgroundColor,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khidmeti Workers',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: kBackgroundColor,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const WorkerSplash(),
      routes: {
        '/home': (_) => const WorkerHome(),
      },
    );
  }
}

class WorkerSplash extends StatefulWidget {
  const WorkerSplash({super.key});

  @override
  State<WorkerSplash> createState() => _WorkerSplashState();
}

class _WorkerSplashState extends State<WorkerSplash>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this);
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
        child: Lottie.asset(
          'assets/animations/splash_animation.json',
          controller: _logoController,
          width: 200,
          height: 200,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }
}

class WorkerHome extends StatefulWidget {
  const WorkerHome({super.key});

  @override
  State<WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  int _index = 0;

  final List<Widget> _tabs = const [
    _DashboardView(),
    MapScreen(),
    _Placeholder('Demandes'),
    _Placeholder('Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _tabs[_index],
      bottomNavigationBar: Container(
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
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Demandes'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ModernHeader(title: 'Tableau de bord'),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _DashboardContent(),
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _StatsRow(),
        SizedBox(height: 16),
        _SectionTitle('Demandes récentes'),
        SizedBox(height: 8),
        _RequestCard(),
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

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Tableau de bord', style: kHeadingStyle.copyWith(fontSize: 28)),
        const Spacer(),
        CircleAvatar(backgroundColor: kPrimaryDark, child: const Icon(Icons.person, color: Colors.white)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: ProfessionalDashboardCard(
            title: 'Revenus',
            value: '48,2k DA',
            icon: Icons.payments,
            trend: '+12%',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ProfessionalDashboardCard(
            title: 'Demandes',
            value: '23',
            icon: Icons.list_alt,
            trend: '+3',
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: kHeadingStyle.copyWith(fontSize: 20));
  }
}

class ProfessionalDashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String trend;
  final VoidCallback? onTap;

  const ProfessionalDashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.accentColor = kPrimaryTeal,
    required this.trend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
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
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accentColor, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 12,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: kHeadingStyle.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: kBodyStyle.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      color: kSurfaceColor,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryDark.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.cleaning_services, color: kPrimaryDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nettoyage appartement', style: kHeadingStyle.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Aujourd\'hui • 14:00 • Hydra', style: kBodyStyle),
                ],
              ),
            ),
            BubbleButton(
              text: 'Accepter',
              onPressed: () {},
              primaryColor: kPrimaryTeal,
              height: 40,
              width: 110,
            ),
          ],
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
  static const LatLng initialCenter = LatLng(36.737232, 3.086472);

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
                TileLayer(urlTemplate: tileUrl, userAgentPackageName: 'khidmeti.worker'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}