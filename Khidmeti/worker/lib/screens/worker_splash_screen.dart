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
import '../models/worker_model.dart';
import '../models/dashboard_stats_model.dart';
import '../services/worker_auth_service.dart';
import '../services/worker_database_service.dart';
import '../services/worker_storage_service.dart';
import '../services/worker_location_service.dart';
import '../services/worker_notification_service.dart';
import '../services/payment_processor.dart';
import '../widgets/professional_dashboard_card.dart';
import '../providers/worker_app_state_provider.dart';
import '../utils/asset_loader.dart';
import '../utils/network_utils.dart';
import '../utils/analytics_service.dart';
import '../utils/error_handler.dart';
import '../utils/performance_monitor.dart';
import '../utils/worker_validation_utils.dart';
import '../utils/worker_security_utils.dart';
import '../utils/worker_biometric_utils.dart';
import '../utils/worker_permission_utils.dart';
import '../utils/worker_availability_utils.dart';
import '../extensions/context_extensions.dart';
import '../extensions/string_extensions.dart';
import '../extensions/color_extensions.dart';

class WorkerSplashScreen extends StatefulWidget {
  const WorkerSplashScreen({Key? key}) : super(key: key);

  @override
  State<WorkerSplashScreen> createState() => _WorkerSplashScreenState();
}

class _WorkerSplashScreenState extends State<WorkerSplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ===== ANIMATION CONTROLLERS =====
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late AnimationController _gearController;
  late AnimationController _toolController;

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
  late Animation<double> _gearRotationAnimation;
  late Animation<double> _toolBounceAnimation;

  // ===== STATE VARIABLES =====
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  double _progressValue = 0.0;
  int _currentStep = 0;
  List<String> _loadingSteps = [
    'Initialisation de l\'application...',
    'Connexion aux services professionnels...',
    'Vérification de l\'authentification...',
    'Chargement du profil professionnel...',
    'Vérification des permissions...',
    'Initialisation des outils de travail...',
    'Connexion aux services de paiement...',
    'Préparation du tableau de bord...',
    'Finalisation...'
  ];

  // ===== WORKER SPECIFIC STATE =====
  bool _isWorkerVerified = false;
  bool _isLocationEnabled = false;
  bool _isNotificationsEnabled = false;
  bool _isPaymentSetup = false;
  bool _isAvailabilitySet = false;
  String _workerStatus = 'En cours de vérification...';
  double _workerRating = 0.0;
  int _completedJobs = 0;
  double _totalEarnings = 0.0;

  // ===== SERVICES =====
  late WorkerAuthService _authService;
  late WorkerDatabaseService _databaseService;
  late WorkerStorageService _storageService;
  late WorkerLocationService _locationService;
  late WorkerNotificationService _notificationService;
  late PaymentProcessor _paymentProcessor;
  late AssetLoader _assetLoader;
  late NetworkUtils _networkUtils;
  late AnalyticsService _analyticsService;
  late ErrorHandler _errorHandler;
  late PerformanceMonitor _performanceMonitor;
  late WorkerValidationUtils _validationUtils;
  late WorkerSecurityUtils _securityUtils;
  late WorkerBiometricUtils _biometricUtils;
  late WorkerPermissionUtils _permissionUtils;
  late WorkerAvailabilityUtils _availabilityUtils;

  // ===== TIMERS =====
  Timer? _progressTimer;
  Timer? _stepTimer;
  Timer? _timeoutTimer;
  Timer? _statusUpdateTimer;

  // ===== PERFORMANCE TRACKING =====
  final Stopwatch _initializationTimer = Stopwatch();
  final List<double> _frameRates = [];
  int _frameCount = 0;
  DateTime? _lastFrameTime;

  // ===== WORKER DATA =====
  WorkerModel? _currentWorker;
  DashboardStats? _dashboardStats;
  List<String> _workerSkills = [];
  List<String> _workerCertifications = [];
  Map<String, dynamic> _workerPreferences = {};
  Map<String, dynamic> _workerSettings = {};

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
    _authService = WorkerAuthService();
    _databaseService = WorkerFirestoreService();
    _storageService = WorkerStorageServiceImpl();
    _locationService = WorkerLocationServiceImpl();
    _notificationService = WorkerNotificationServiceImpl();
    _paymentProcessor = BaridiMobPaymentProcessor();
    _assetLoader = AssetLoader();
    _networkUtils = NetworkUtils();
    _analyticsService = AnalyticsService();
    _errorHandler = ErrorHandler();
    _performanceMonitor = PerformanceMonitor();
    _validationUtils = WorkerValidationUtils();
    _securityUtils = WorkerSecurityUtils();
    _biometricUtils = WorkerBiometricUtils();
    _permissionUtils = WorkerPermissionUtils();
    _availabilityUtils = WorkerAvailabilityUtils();
  }

  // ===== ANIMATION INITIALIZATION =====
  void _initializeAnimations() {
    // Logo Controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Background Controller
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // Particle Controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Text Controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Progress Controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Fade Controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Gear Controller
    _gearController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Tool Controller
    _toolController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

    // Gear Animation
    _gearRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _gearController,
      curve: Curves.linear,
    ));

    // Tool Animation
    _toolBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _toolController,
      curve: Curves.bounceOut,
    ));
  }

  // ===== INITIALIZATION PROCESS =====
  void _startInitialization() async {
    _initializationTimer.start();
    _analyticsService.logEvent('worker_splash_screen_started');

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
        await _storageService.initialize();
        await _notificationService.initialize();
      });

      // Step 3: Check authentication status
      await _initializeStep(2, () async {
        final currentUser = _authService.getCurrentUser();
        if (currentUser != null) {
          await _loadWorkerData(currentUser.uid);
        }
      });

      // Step 4: Load worker profile and preferences
      await _initializeStep(3, () async {
        final currentUser = _authService.getCurrentUser();
        if (currentUser != null) {
          await _loadWorkerProfile(currentUser.uid);
          await _loadWorkerPreferences();
          await _loadWorkerSettings();
        }
      });

      // Step 5: Check permissions
      await _initializeStep(4, () async {
        await _checkWorkerPermissions();
      });

      // Step 6: Initialize work tools
      await _initializeStep(5, () async {
        await _initializeWorkTools();
      });

      // Step 7: Setup payment system
      await _initializeStep(6, () async {
        await _setupPaymentSystem();
      });

      // Step 8: Prepare dashboard
      await _initializeStep(7, () async {
        await _prepareDashboard();
      });

      // Step 9: Finalize initialization
      await _initializeStep(8, () async {
        await _finalizeWorkerInitialization();
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
      await Future.delayed(Duration(milliseconds: 400 + (stepIndex * 120)));
    } catch (error) {
      _errorHandler.handleError(error, 'Worker initialization step $stepIndex failed');
      rethrow;
    }
  }

  Future<void> _loadWorkerData(String workerId) async {
    try {
      final workerData = await _databaseService.getWorker(workerId);
      if (workerData != null) {
        setState(() {
          _currentWorker = workerData;
          _workerRating = workerData.rating;
          _completedJobs = workerData.completedJobs;
        });
        context.read<WorkerAppStateProvider>().setWorker(workerData);
      }
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to load worker data');
    }
  }

  Future<void> _loadWorkerProfile(String workerId) async {
    try {
      final profile = await _databaseService.getWorkerProfile(workerId);
      if (profile != null) {
        setState(() {
          _workerSkills = profile['skills'] ?? [];
          _workerCertifications = profile['certifications'] ?? [];
          _isWorkerVerified = profile['isVerified'] ?? false;
        });
      }
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to load worker profile');
    }
  }

  Future<void> _loadWorkerPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeMode = prefs.getString('worker_theme_mode') ?? 'system';
      final language = prefs.getString('worker_language') ?? 'fr';
      final autoAcceptJobs = prefs.getBool('auto_accept_jobs') ?? false;
      final maxDistance = prefs.getDouble('max_distance') ?? 10.0;
      
      setState(() {
        _workerPreferences = {
          'themeMode': themeMode,
          'language': language,
          'autoAcceptJobs': autoAcceptJobs,
          'maxDistance': maxDistance,
        };
      });
      
      context.read<WorkerAppStateProvider>().setWorkerPreferences(_workerPreferences);
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to load worker preferences');
    }
  }

  Future<void> _loadWorkerSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('worker_notifications_enabled') ?? true;
      final locationEnabled = prefs.getBool('worker_location_enabled') ?? false;
      final soundEnabled = prefs.getBool('worker_sound_enabled') ?? true;
      final vibrationEnabled = prefs.getBool('worker_vibration_enabled') ?? true;
      
      setState(() {
        _workerSettings = {
          'notificationsEnabled': notificationsEnabled,
          'locationEnabled': locationEnabled,
          'soundEnabled': soundEnabled,
          'vibrationEnabled': vibrationEnabled,
        };
        _isNotificationsEnabled = notificationsEnabled;
        _isLocationEnabled = locationEnabled;
      });
      
      context.read<WorkerAppStateProvider>().setWorkerSettings(_workerSettings);
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to load worker settings');
    }
  }

  Future<void> _checkWorkerPermissions() async {
    try {
      final locationPermission = await _permissionUtils.checkLocationPermission();
      final notificationPermission = await _permissionUtils.checkNotificationPermission();
      final cameraPermission = await _permissionUtils.checkCameraPermission();
      
      setState(() {
        _isLocationEnabled = locationPermission;
        _isNotificationsEnabled = notificationPermission;
      });
      
      if (!locationPermission) {
        _workerStatus = 'Permission de localisation requise';
      } else if (!notificationPermission) {
        _workerStatus = 'Permission de notification requise';
      } else {
        _workerStatus = 'Permissions vérifiées';
      }
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to check worker permissions');
    }
  }

  Future<void> _initializeWorkTools() async {
    try {
      // Initialize location service
      if (_isLocationEnabled) {
        await _locationService.initialize();
        final currentLocation = await _locationService.getCurrentLocation();
        if (currentLocation != null) {
          await _databaseService.updateWorkerLocation(
            _currentWorker!.id,
            currentLocation,
          );
        }
      }
      
      // Initialize notification service
      if (_isNotificationsEnabled) {
        await _notificationService.initialize();
        await _notificationService.subscribeToWorkerTopics(_currentWorker!.id);
      }
      
      // Initialize availability
      final availability = await _availabilityUtils.getWorkerAvailability(_currentWorker!.id);
      setState(() {
        _isAvailabilitySet = availability != null;
      });
      
      _workerStatus = 'Outils de travail initialisés';
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to initialize work tools');
    }
  }

  Future<void> _setupPaymentSystem() async {
    try {
      final paymentSetup = await _paymentProcessor.checkWorkerPaymentSetup(_currentWorker!.id);
      setState(() {
        _isPaymentSetup = paymentSetup;
      });
      
      if (paymentSetup) {
        final earnings = await _paymentProcessor.getWorkerEarnings(_currentWorker!.id);
        setState(() {
          _totalEarnings = earnings;
        });
      }
      
      _workerStatus = 'Système de paiement configuré';
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to setup payment system');
    }
  }

  Future<void> _prepareDashboard() async {
    try {
      // Load dashboard statistics
      final stats = await _databaseService.getWorkerDashboardStats(_currentWorker!.id);
      if (stats != null) {
        setState(() {
          _dashboardStats = stats;
        });
        context.read<WorkerAppStateProvider>().setDashboardStats(stats);
      }
      
      // Preload worker-specific assets
      await _assetLoader.preloadWorkerAssets();
      
      _workerStatus = 'Tableau de bord préparé';
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to prepare dashboard');
    }
  }

  Future<void> _finalizeWorkerInitialization() async {
    try {
      _analyticsService.logEvent('worker_splash_screen_completed', {
        'initialization_time': _initializationTimer.elapsedMilliseconds,
        'worker_id': _currentWorker?.id,
        'worker_verified': _isWorkerVerified,
        'location_enabled': _isLocationEnabled,
        'notifications_enabled': _isNotificationsEnabled,
        'payment_setup': _isPaymentSetup,
        'availability_set': _isAvailabilitySet,
        'frame_rate_average': _calculateAverageFrameRate(),
      });
      
      _performanceMonitor.recordMetric('worker_splash_initialization_time', 
        _initializationTimer.elapsedMilliseconds);
      
      _workerStatus = 'Initialisation terminée';
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to finalize worker initialization');
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

    _analyticsService.logEvent('worker_splash_screen_success');
    
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

    _analyticsService.logEvent('worker_splash_screen_error', {
      'error': error.toString(),
      'initialization_time': _initializationTimer.elapsedMilliseconds,
    });
  }

  // ===== NAVIGATION =====
  void _navigateToNextScreen() {
    final currentUser = _authService.getCurrentUser();
    
    if (currentUser != null) {
      if (_isWorkerVerified) {
        Navigator.of(context).pushReplacementNamed('/worker_home');
      } else {
        Navigator.of(context).pushReplacementNamed('/worker_verification');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/worker_auth');
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
    _gearController.dispose();
    _toolController.dispose();
  }

  void _disposeTimers() {
    _progressTimer?.cancel();
    _stepTimer?.cancel();
    _timeoutTimer?.cancel();
    _statusUpdateTimer?.cancel();
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
                    kPrimaryDark.withOpacity(0.1),
                    kPrimaryTeal.withOpacity(0.1),
                    kPrimaryYellow.withOpacity(0.1),
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
            painter: WorkerParticlePainter(
              animation: _particleScaleAnimation.value,
              colors: [kPrimaryDark, kPrimaryTeal, kPrimaryYellow],
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
          
          SizedBox(height: 30),
          
          // Worker Status Section
          _buildWorkerStatusSection(),
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main Logo
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: kPrimaryDark,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryDark.withOpacity(0.3),
                            blurRadius: 25,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.engineering,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                    
                    // Rotating Gear
                    Positioned(
                      top: 10,
                      right: 10,
                      child: AnimatedBuilder(
                        animation: _gearController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _gearRotationAnimation.value,
                            child: Icon(
                              Icons.settings,
                              color: kPrimaryTeal,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Bouncing Tool
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: AnimatedBuilder(
                        animation: _toolController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.8 + (_toolBounceAnimation.value * 0.4),
                            child: Icon(
                              Icons.build,
                              color: kPrimaryYellow,
                              size: 25,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
                  'KHIDMETI WORKERS',
                  style: kHeadingLarge.copyWith(
                    color: kPrimaryDark,
                    fontSize: 28,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Votre plateforme professionnelle',
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
              width: 250,
              height: 6,
              decoration: BoxDecoration(
                color: kBorderLight,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryDark, kPrimaryTeal],
                    ),
                    borderRadius: BorderRadius.circular(3),
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

  // ===== WORKER STATUS SECTION =====
  Widget _buildWorkerStatusSection() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Column(
          children: [
            // Worker Rating
            if (_workerRating > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: kPrimaryYellow, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '${_workerRating.toStringAsFixed(1)}',
                    style: kBodyMedium.copyWith(
                      color: kPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            
            SizedBox(height: 8),
            
            // Completed Jobs
            if (_completedJobs > 0)
              Text(
                '${_completedJobs} missions accomplies',
                style: kBodySmall.copyWith(
                  color: kSubtitleColor,
                ),
              ),
            
            SizedBox(height: 16),
            
            // Worker Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: kPrimaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: kPrimaryTeal.withOpacity(0.3),
                ),
              ),
              child: Text(
                _workerStatus,
                style: kCaptionMedium.copyWith(
                  color: kPrimaryTeal,
                ),
                textAlign: TextAlign.center,
              ),
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
          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryDark),
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

// ===== CUSTOM PAINTER FOR WORKER PARTICLES =====
class WorkerParticlePainter extends CustomPainter {
  final double animation;
  final List<Color> colors;

  WorkerParticlePainter({
    required this.animation,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent particles
    
    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = (3 + random.nextDouble() * 4) * animation;
      final color = colors[random.nextInt(colors.length)];
      
      paint.color = color.withOpacity(0.4 * animation);
      
      // Draw different shapes for variety
      if (i % 3 == 0) {
        // Circle
        canvas.drawCircle(
          Offset(x, y),
          radius,
          paint,
        );
      } else if (i % 3 == 1) {
        // Square
        final rect = Rect.fromCenter(
          center: Offset(x, y),
          width: radius * 2,
          height: radius * 2,
        );
        canvas.drawRect(rect, paint);
      } else {
        // Triangle
        final path = Path();
        path.moveTo(x, y - radius);
        path.lineTo(x - radius, y + radius);
        path.lineTo(x + radius, y + radius);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(WorkerParticlePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}