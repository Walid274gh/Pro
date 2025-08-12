import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;

import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/modern_card.dart';
import '../providers/app_state_provider.dart';
import '../utils/asset_loader.dart';
import '../utils/network_utils.dart';
import '../utils/analytics_service.dart';
import '../utils/error_handler.dart';
import '../utils/performance_monitor.dart';
import '../extensions/context_extensions.dart';
import '../extensions/string_extensions.dart';
import '../extensions/color_extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ===== ANIMATION CONTROLLERS =====
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _fadeController;

  // ===== ANIMATIONS =====
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _backgroundScaleAnimation;
  late Animation<double> _backgroundOpacityAnimation;
  late Animation<double> _particleOpacityAnimation;
  late Animation<double> _particleScaleAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  // ===== STATE VARIABLES =====
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  double _progressValue = 0.0;
  int _currentStep = 0;
  List<String> _loadingSteps = [
    'Initialisation de l\'application...',
    'Connexion aux services...',
    'Vérification de l\'authentification...',
    'Chargement des données utilisateur...',
    'Préparation de l\'interface...',
    'Finalisation...'
  ];

  // ===== SERVICES =====
  late AuthService _authService;
  late DatabaseService _databaseService;
  late AssetLoader _assetLoader;
  late NetworkUtils _networkUtils;
  late AnalyticsService _analyticsService;
  late ErrorHandler _errorHandler;
  late PerformanceMonitor _performanceMonitor;

  // ===== TIMERS =====
  Timer? _progressTimer;
  Timer? _stepTimer;
  Timer? _timeoutTimer;

  // ===== PERFORMANCE TRACKING =====
  final Stopwatch _initializationTimer = Stopwatch();
  final List<double> _frameRates = [];
  int _frameCount = 0;
  DateTime? _lastFrameTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
    _initializeAnimations();
    _startInitialization();
    _performanceMonitor.startTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeControllers();
    _disposeTimers();
    _performanceMonitor.stopTracking();
    super.dispose();
  }

  // ===== SERVICE INITIALIZATION =====
  void _initializeServices() {
    _authService = AuthService();
    _databaseService = FirestoreDatabaseService();
    _assetLoader = AssetLoader();
    _networkUtils = NetworkUtils();
    _analyticsService = AnalyticsService();
    _errorHandler = ErrorHandler();
    _performanceMonitor = PerformanceMonitor();
  }

  // ===== ANIMATION INITIALIZATION =====
  void _initializeAnimations() {
    // Logo Controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Background Controller
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Particle Controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text Controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Progress Controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Fade Controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo Animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    ));

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    // Background Animations
    _backgroundScaleAnimation = Tween<double>(
      begin: 1.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeOutCubic,
    ));

    _backgroundOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeIn,
    ));

    // Particle Animations
    _particleOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));

    _particleScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.elasticOut,
    ));

    // Text Animations
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Progress Animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Fade Animation
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  // ===== INITIALIZATION PROCESS =====
  void _startInitialization() async {
    _initializationTimer.start();
    _analyticsService.logEvent('splash_screen_started');

    try {
      // Step 1: Check network connectivity
      await _initializeStep(0, () async {
        final isConnected = await _networkUtils.checkConnectivity();
        if (!isConnected) {
          throw Exception('Aucune connexion internet détectée');
        }
      });

      // Step 2: Initialize Firebase services
      await _initializeStep(1, () async {
        await _authService.initialize();
        await _databaseService.initialize();
      });

      // Step 3: Check authentication status
      await _initializeStep(2, () async {
        final currentUser = _authService.getCurrentUser();
        if (currentUser != null) {
          await _loadUserData(currentUser.uid);
        }
      });

      // Step 4: Load user data if authenticated
      await _initializeStep(3, () async {
        final currentUser = _authService.getCurrentUser();
        if (currentUser != null) {
          await _loadUserPreferences();
          await _loadUserSettings();
        }
      });

      // Step 5: Prepare UI components
      await _initializeStep(4, () async {
        await _assetLoader.preloadAssets();
        await _prepareUIComponents();
      });

      // Step 6: Finalize initialization
      await _initializeStep(5, () async {
        await _finalizeInitialization();
      });

      _onInitializationComplete();
    } catch (error) {
      _onInitializationError(error);
    }
  }

  Future<void> _initializeStep(int stepIndex, Future<void> Function() stepFunction) async {
    if (!mounted) return;

    setState(() {
      _currentStep = stepIndex;
      _isLoading = true;
    });

    try {
      await stepFunction();
      
      // Update progress
      final progress = (stepIndex + 1) / _loadingSteps.length;
      _updateProgress(progress);
      
      // Add delay for smooth animation
      await Future.delayed(Duration(milliseconds: 300 + (stepIndex * 100)));
    } catch (error) {
      _errorHandler.handleError(error, 'Initialization step $stepIndex failed');
      rethrow;
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final userData = await _databaseService.getUser(userId);
      if (userData != null) {
        context.read<AppStateProvider>().setUser(userData);
      }
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to load user data');
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeMode = prefs.getString('theme_mode') ?? 'system';
      final language = prefs.getString('language') ?? 'fr';
      
      context.read<AppStateProvider>().setThemeMode(themeMode);
      context.read<AppStateProvider>().setLanguage(language);
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to load user preferences');
    }
  }

  Future<void> _loadUserSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      final locationEnabled = prefs.getBool('location_enabled') ?? false;
      
      context.read<AppStateProvider>().setNotificationsEnabled(notificationsEnabled);
      context.read<AppStateProvider>().setLocationEnabled(locationEnabled);
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to load user settings');
    }
  }

  Future<void> _prepareUIComponents() async {
    try {
      // Preload animations
      await _assetLoader.preloadAnimation('assets/animations/splash_animation.json');
      await _assetLoader.preloadAnimation('assets/animations/login_animation.json');
      await _assetLoader.preloadAnimation('assets/animations/success_animation.json');
      
      // Preload images
      await _assetLoader.preloadImage('assets/images/logo.png');
      await _assetLoader.preloadImage('assets/images/background.jpg');
      
      // Preload SVGs
      await _assetLoader.preloadSvg('assets/avatars/users/avatar_user_1.svg');
      await _assetLoader.preloadSvg('assets/avatars/users/avatar_user_2.svg');
      await _assetLoader.preloadSvg('assets/avatars/users/avatar_user_3.svg');
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to prepare UI components');
    }
  }

  Future<void> _finalizeInitialization() async {
    try {
      _analyticsService.logEvent('splash_screen_completed', {
        'initialization_time': _initializationTimer.elapsedMilliseconds,
        'frame_rate_average': _calculateAverageFrameRate(),
      });
      
      _performanceMonitor.recordMetric('splash_initialization_time', 
        _initializationTimer.elapsedMilliseconds);
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to finalize initialization');
    }
  }

  // ===== PROGRESS MANAGEMENT =====
  void _updateProgress(double progress) {
    if (!mounted) return;
    
    setState(() {
      _progressValue = progress;
    });
    
    _progressController.animateTo(progress);
  }

  // ===== COMPLETION HANDLERS =====
  void _onInitializationComplete() {
    if (!mounted) return;

    setState(() {
      _isInitialized = true;
      _isLoading = false;
    });

    _analyticsService.logEvent('splash_screen_success');
    
    // Start fade out animation
    _fadeController.forward().then((_) {
      _navigateToNextScreen();
    });
  }

  void _onInitializationError(dynamic error) {
    if (!mounted) return;

    setState(() {
      _hasError = true;
      _isLoading = false;
      _errorMessage = error.toString();
    });

    _analyticsService.logEvent('splash_screen_error', {
      'error': error.toString(),
      'initialization_time': _initializationTimer.elapsedMilliseconds,
    });
  }

  // ===== NAVIGATION =====
  void _navigateToNextScreen() {
    final currentUser = _authService.getCurrentUser();
    
    if (currentUser != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  // ===== PERFORMANCE MONITORING =====
  double _calculateAverageFrameRate() {
    if (_frameRates.isEmpty) return 0.0;
    return _frameRates.reduce((a, b) => a + b) / _frameRates.length;
  }

  void _recordFrameRate() {
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!).inMicroseconds;
      final frameRate = 1000000 / frameTime;
      _frameRates.add(frameRate);
      
      // Keep only last 60 frames
      if (_frameRates.length > 60) {
        _frameRates.removeAt(0);
      }
    }
    _lastFrameTime = now;
    _frameCount++;
  }

  // ===== DISPOSAL =====
  void _disposeControllers() {
    _logoController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
  }

  void _disposeTimers() {
    _progressTimer?.cancel();
    _stepTimer?.cancel();
    _timeoutTimer?.cancel();
  }

  // ===== WIDGET LIFECYCLE =====
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
        _performanceMonitor.pauseTracking();
        break;
      case AppLifecycleState.resumed:
        _performanceMonitor.resumeTracking();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _recordFrameRate();
    
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Background Layer
            _buildBackgroundLayer(),
            
            // Particle Layer
            _buildParticleLayer(),
            
            // Content Layer
            _buildContentLayer(),
            
            // Loading Layer
            if (_isLoading) _buildLoadingLayer(),
            
            // Error Layer
            if (_hasError) _buildErrorLayer(),
          ],
        ),
      ),
    );
  }

  // ===== BACKGROUND LAYER =====
  Widget _buildBackgroundLayer() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Transform.scale(
          scale: _backgroundScaleAnimation.value,
          child: Opacity(
            opacity: _backgroundOpacityAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kPrimaryYellow.withOpacity(0.1),
                    kPrimaryTeal.withOpacity(0.1),
                    kPrimaryRed.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== PARTICLE LAYER =====
  Widget _buildParticleLayer() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Opacity(
          opacity: _particleOpacityAnimation.value,
          child: CustomPaint(
            painter: ParticlePainter(
              animation: _particleScaleAnimation.value,
              colors: [kPrimaryYellow, kPrimaryTeal, kPrimaryRed],
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  // ===== CONTENT LAYER =====
  Widget _buildContentLayer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Section
          _buildLogoSection(),
          
          SizedBox(height: 40),
          
          // Text Section
          _buildTextSection(),
          
          SizedBox(height: 60),
          
          // Progress Section
          _buildProgressSection(),
        ],
      ),
    );
  }

  // ===== LOGO SECTION =====
  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value,
            child: Opacity(
              opacity: _logoOpacityAnimation.value,
              child: SlideTransition(
                position: _logoSlideAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: kPrimaryTeal,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryTeal.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home_repair_service,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== TEXT SECTION =====
  Widget _buildTextSection() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlideAnimation,
          child: Opacity(
            opacity: _textOpacityAnimation.value,
            child: Column(
              children: [
                Text(
                  'KHIDMETI',
                  style: kHeadingLarge.copyWith(
                    color: kPrimaryDark,
                    fontSize: 32,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Vos services à portée de main',
                  style: kSubheadingMedium.copyWith(
                    color: kSubtitleColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== PROGRESS SECTION =====
  Widget _buildProgressSection() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Column(
          children: [
            // Progress Bar
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: kBorderLight,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryTeal, kPrimaryDark],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Loading Text
            if (_isLoading)
              Text(
                _loadingSteps[_currentStep],
                style: kBodySmall.copyWith(
                  color: kSubtitleColor,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        );
      },
    );
  }

  // ===== LOADING LAYER =====
  Widget _buildLoadingLayer() {
    return Container(
      color: Colors.black.withOpacity(0.1),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryTeal),
        ),
      ),
    );
  }

  // ===== ERROR LAYER =====
  Widget _buildErrorLayer() {
    return Container(
      color: kErrorColor.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: kErrorColor,
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              'Erreur d\'initialisation',
              style: kSubheadingMedium.copyWith(
                color: kErrorColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: kBodySmall.copyWith(
                color: kSubtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = '';
                });
                _startInitialization();
              },
              child: Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== CUSTOM PAINTER FOR PARTICLES =====
class ParticlePainter extends CustomPainter {
  final double animation;
  final List<Color> colors;

  ParticlePainter({
    required this.animation,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent particles
    
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = (2 + random.nextDouble() * 3) * animation;
      final color = colors[random.nextInt(colors.length)];
      
      paint.color = color.withOpacity(0.3 * animation);
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}