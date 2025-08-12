import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
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
import '../utils/validation_utils.dart';
import '../utils/security_utils.dart';
import '../utils/biometric_utils.dart';
import '../extensions/context_extensions.dart';
import '../extensions/string_extensions.dart';
import '../extensions/color_extensions.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ===== FORM CONTROLLERS =====
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();

  // ===== ANIMATION CONTROLLERS =====
  late AnimationController _backgroundController;
  late AnimationController _formController;
  late AnimationController _logoController;
  late AnimationController _socialController;
  late AnimationController _errorController;
  late AnimationController _successController;
  late AnimationController _loadingController;

  // ===== ANIMATIONS =====
  late Animation<double> _backgroundScaleAnimation;
  late Animation<double> _backgroundOpacityAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formOpacityAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<Offset> _socialSlideAnimation;
  late Animation<double> _socialOpacityAnimation;
  late Animation<double> _errorShakeAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _loadingRotationAnimation;

  // ===== STATE VARIABLES =====
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isSocialLoginLoading = false;
  bool _isRegistrationMode = false;
  bool _hasError = false;
  bool _hasSuccess = false;
  String _errorMessage = '';
  String _successMessage = '';
  String _selectedAvatar = 'assets/avatars/users/avatar_user_1.svg';
  int _currentStep = 0;
  double _formProgress = 0.0;

  // ===== VALIDATION STATE =====
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _isFirstNameValid = false;
  bool _isLastNameValid = false;
  bool _isPhoneValid = false;
  Map<String, String> _validationErrors = {};

  // ===== SERVICES =====
  late AuthService _authService;
  late DatabaseService _databaseService;
  late AssetLoader _assetLoader;
  late NetworkUtils _networkUtils;
  late AnalyticsService _analyticsService;
  late ErrorHandler _errorHandler;
  late PerformanceMonitor _performanceMonitor;
  late ValidationUtils _validationUtils;
  late SecurityUtils _securityUtils;
  late BiometricUtils _biometricUtils;

  // ===== TIMERS =====
  Timer? _debounceTimer;
  Timer? _autoSaveTimer;
  Timer? _sessionTimer;
  Timer? _validationTimer;

  // ===== PERFORMANCE TRACKING =====
  final Stopwatch _authTimer = Stopwatch();
  final List<double> _frameRates = [];
  int _frameCount = 0;
  DateTime? _lastFrameTime;

  // ===== SECURITY =====
  int _failedAttempts = 0;
  DateTime? _lastFailedAttempt;
  bool _isAccountLocked = false;
  String? _sessionToken;

  // ===== UI STATE =====
  bool _isFormDirty = false;
  bool _isAutoSaving = false;
  bool _isRememberMe = false;
  bool _isTermsAccepted = false;
  bool _isPrivacyAccepted = false;
  bool _isMarketingAccepted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
    _initializeAnimations();
    _setupFormListeners();
    _checkBiometricAvailability();
    _loadSavedCredentials();
    _performanceMonitor.startTracking();
    _startBackgroundAnimation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeControllers();
    _disposeTimers();
    _disposeControllers();
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
    _validationUtils = ValidationUtils();
    _securityUtils = SecurityUtils();
    _biometricUtils = BiometricUtils();
  }

  // ===== ANIMATION INITIALIZATION =====
  void _initializeAnimations() {
    // Background Controller
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Form Controller
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Logo Controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Social Controller
    _socialController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Error Controller
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Success Controller
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Loading Controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Background Animations
    _backgroundScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _backgroundOpacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    // Form Animations
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _formOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeIn,
    ));

    // Logo Animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
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

    // Social Animations
    _socialSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _socialController,
      curve: Curves.easeOutCubic,
    ));

    _socialOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _socialController,
      curve: Curves.easeIn,
    ));

    // Error Animations
    _errorShakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: Curves.elasticIn,
    ));

    // Success Animations
    _successScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    // Loading Animations
    _loadingRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));
  }

  // ===== FORM SETUP =====
  void _setupFormListeners() {
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);
    _firstNameController.addListener(_onFirstNameChanged);
    _lastNameController.addListener(_onLastNameChanged);
    _phoneController.addListener(_onPhoneChanged);
  }

  // ===== BIOMETRIC CHECK =====
  Future<void> _checkBiometricAvailability() async {
    try {
      _isBiometricAvailable = await _biometricUtils.isBiometricAvailable();
      _isBiometricEnabled = await _biometricUtils.isBiometricEnabled();
      
      if (_isBiometricAvailable && _isBiometricEnabled) {
        _attemptBiometricLogin();
      }
    } catch (error) {
      _errorHandler.handleError(error, 'Biometric check failed');
    }
  }

  // ===== CREDENTIALS LOADING =====
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final savedPassword = prefs.getString('saved_password');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (rememberMe && savedEmail != null && savedPassword != null) {
        setState(() {
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
          _isRememberMe = true;
        });
      }
    } catch (error) {
      _errorHandler.handleError(error, 'Failed to load saved credentials');
    }
  }

  // ===== BACKGROUND ANIMATION =====
  void _startBackgroundAnimation() {
    _backgroundController.repeat(reverse: true);
    _logoController.repeat();
  }

  // ===== FORM VALIDATION =====
  void _onEmailChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _validateEmail();
    });
  }

  void _onPasswordChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _validatePassword();
    });
  }

  void _onConfirmPasswordChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _validateConfirmPassword();
    });
  }

  void _onFirstNameChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _validateFirstName();
    });
  }

  void _onLastNameChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _validateLastName();
    });
  }

  void _onPhoneChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _validatePhone();
    });
  }

  // ===== VALIDATION METHODS =====
  void _validateEmail() {
    final email = _emailController.text;
    final isValid = _validationUtils.isValidEmail(email);
    final error = isValid ? null : 'Veuillez entrer un email valide';

    setState(() {
      _isEmailValid = isValid;
      _validationErrors['email'] = error ?? '';
    });

    _updateFormProgress();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final validation = _validationUtils.validatePassword(password);
    
    setState(() {
      _isPasswordValid = validation.isValid;
      _validationErrors['password'] = validation.error ?? '';
    });

    if (_isRegistrationMode) {
      _validateConfirmPassword();
    }
    
    _updateFormProgress();
  }

  void _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final isValid = password == confirmPassword && password.isNotEmpty;
    final error = isValid ? null : 'Les mots de passe ne correspondent pas';

    setState(() {
      _isConfirmPasswordValid = isValid;
      _validationErrors['confirmPassword'] = error ?? '';
    });

    _updateFormProgress();
  }

  void _validateFirstName() {
    final firstName = _firstNameController.text;
    final isValid = firstName.length >= 2;
    final error = isValid ? null : 'Le prénom doit contenir au moins 2 caractères';

    setState(() {
      _isFirstNameValid = isValid;
      _validationErrors['firstName'] = error ?? '';
    });

    _updateFormProgress();
  }

  void _validateLastName() {
    final lastName = _lastNameController.text;
    final isValid = lastName.length >= 2;
    final error = isValid ? null : 'Le nom doit contenir au moins 2 caractères';

    setState(() {
      _isLastNameValid = isValid;
      _validationErrors['lastName'] = error ?? '';
    });

    _updateFormProgress();
  }

  void _validatePhone() {
    final phone = _phoneController.text;
    final isValid = _validationUtils.isValidPhone(phone);
    final error = isValid ? null : 'Veuillez entrer un numéro de téléphone valide';

    setState(() {
      _isPhoneValid = isValid;
      _validationErrors['phone'] = error ?? '';
    });

    _updateFormProgress();
  }

  void _updateFormProgress() {
    if (!_isRegistrationMode) {
      // Login mode: only email and password required
      final progress = (_isEmailValid ? 0.5 : 0.0) + (_isPasswordValid ? 0.5 : 0.0);
      setState(() {
        _formProgress = progress;
      });
    } else {
      // Registration mode: all fields required
      final totalFields = 6.0;
      final validFields = [
        _isEmailValid,
        _isPasswordValid,
        _isConfirmPasswordValid,
        _isFirstNameValid,
        _isLastNameValid,
        _isPhoneValid,
      ].where((valid) => valid).length;
      
      setState(() {
        _formProgress = validFields / totalFields;
      });
    }
  }

  // ===== AUTHENTICATION METHODS =====
  Future<void> _handleAuthentication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isAccountLocked) {
      _showError('Compte temporairement verrouillé. Veuillez réessayer plus tard.');
      return;
    }

    _authTimer.start();
    _analyticsService.logEvent('auth_attempt', {
      'mode': _isLogin ? 'login' : 'register',
      'method': 'email_password',
    });

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      if (_isLogin) {
        await _handleLogin();
      } else {
        await _handleRegistration();
      }
    } catch (error) {
      _handleAuthError(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
      _authTimer.stop();
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await _authService.signInWithEmailAndPassword(email, password);
    
    if (result != null) {
      await _saveCredentials();
      await _loadUserData(result.user!.uid);
      _showSuccess('Connexion réussie !');
      _navigateToHome();
    } else {
      _incrementFailedAttempts();
      throw Exception('Email ou mot de passe incorrect');
    }
  }

  Future<void> _handleRegistration() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    // Create user account
    final result = await _authService.createUserWithEmailAndPassword(email, password);
    
    if (result != null) {
      // Create user profile
      final user = UserModel(
        id: result.user!.uid,
        name: '$firstName $lastName',
        email: email,
        phone: phone,
        avatarUrl: _selectedAvatar,
        favoriteServices: [],
        completedRequests: [],
        rating: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.createUser(user);
      await _saveCredentials();
      _showSuccess('Compte créé avec succès !');
      _navigateToHome();
    } else {
      throw Exception('Erreur lors de la création du compte');
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isSocialLoginLoading = true;
    });

    try {
      UserCredential? result;
      
      switch (provider) {
        case 'google':
          result = await _authService.signInWithGoogle();
          break;
        case 'facebook':
          result = await _authService.signInWithFacebook();
          break;
        case 'apple':
          result = await _authService.signInWithApple();
          break;
      }

      if (result != null) {
        await _loadUserData(result.user!.uid);
        _showSuccess('Connexion réussie avec $provider !');
        _navigateToHome();
      }
    } catch (error) {
      _handleAuthError(error);
    } finally {
      setState(() {
        _isSocialLoginLoading = false;
      });
    }
  }

  Future<void> _attemptBiometricLogin() async {
    try {
      final credentials = await _biometricUtils.getStoredCredentials();
      if (credentials != null) {
        final result = await _authService.signInWithEmailAndPassword(
          credentials['email']!,
          credentials['password']!,
        );
        
        if (result != null) {
          await _loadUserData(result.user!.uid);
          _showSuccess('Connexion biométrique réussie !');
          _navigateToHome();
        }
      }
    } catch (error) {
      _errorHandler.handleError(error, 'Biometric login failed');
    }
  }

  // ===== ERROR HANDLING =====
  void _handleAuthError(dynamic error) {
    _incrementFailedAttempts();
    
    String errorMessage = 'Une erreur inattendue s\'est produite';
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'Aucun compte trouvé avec cet email';
          break;
        case 'wrong-password':
          errorMessage = 'Mot de passe incorrect';
          break;
        case 'email-already-in-use':
          errorMessage = 'Cet email est déjà utilisé';
          break;
        case 'weak-password':
          errorMessage = 'Le mot de passe est trop faible';
          break;
        case 'invalid-email':
          errorMessage = 'Adresse email invalide';
          break;
        case 'user-disabled':
          errorMessage = 'Ce compte a été désactivé';
          break;
        case 'too-many-requests':
          errorMessage = 'Trop de tentatives. Veuillez réessayer plus tard';
          break;
        default:
          errorMessage = error.message ?? errorMessage;
      }
    }

    _showError(errorMessage);
  }

  void _incrementFailedAttempts() {
    _failedAttempts++;
    _lastFailedAttempt = DateTime.now();
    
    if (_failedAttempts >= 5) {
      _isAccountLocked = true;
      _sessionTimer = Timer(const Duration(minutes: 15), () {
        setState(() {
          _isAccountLocked = false;
          _failedAttempts = 0;
        });
      });
    }
  }

  // ===== SUCCESS/ERROR DISPLAY =====
  void _showSuccess(String message) {
    setState(() {
      _hasSuccess = true;
      _successMessage = message;
    });
    
    _successController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _hasSuccess = false;
            _successMessage = '';
          });
          _successController.reset();
        }
      });
    });
  }

  void _showError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
    
    _errorController.forward().then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _hasError = false;
            _errorMessage = '';
          });
          _errorController.reset();
        }
      });
    });
  }

  // ===== UTILITY METHODS =====
  Future<void> _saveCredentials() async {
    if (_isRememberMe) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', _emailController.text);
        await prefs.setString('saved_password', _passwordController.text);
        await prefs.setBool('remember_me', true);
      } catch (error) {
        _errorHandler.handleError(error, 'Failed to save credentials');
      }
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

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _isRegistrationMode = !_isLogin;
      _hasError = false;
      _hasSuccess = false;
      _errorMessage = '';
      _successMessage = '';
      _formProgress = 0.0;
    });

    if (_isRegistrationMode) {
      _formController.forward();
      _socialController.forward();
    } else {
      _formController.reverse();
      _socialController.reverse();
    }
  }

  void _selectAvatar(String avatarPath) {
    setState(() {
      _selectedAvatar = avatarPath;
    });
  }

  // ===== DISPOSAL =====
  void _disposeControllers() {
    _backgroundController.dispose();
    _formController.dispose();
    _logoController.dispose();
    _socialController.dispose();
    _errorController.dispose();
    _successController.dispose();
    _loadingController.dispose();
  }

  void _disposeTimers() {
    _debounceTimer?.cancel();
    _autoSaveTimer?.cancel();
    _sessionTimer?.cancel();
    _validationTimer?.cancel();
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
      body: Stack(
        children: [
          // Background Layer
          _buildBackgroundLayer(),
          
          // Content Layer
          _buildContentLayer(),
          
          // Loading Overlay
          if (_isLoading) _buildLoadingOverlay(),
          
          // Success Overlay
          if (_hasSuccess) _buildSuccessOverlay(),
          
          // Error Overlay
          if (_hasError) _buildErrorOverlay(),
        ],
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

  // ===== CONTENT LAYER =====
  Widget _buildContentLayer() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 40),
            
            // Logo Section
            _buildLogoSection(),
            
            SizedBox(height: 40),
            
            // Form Section
            _buildFormSection(),
            
            SizedBox(height: 30),
            
            // Social Login Section
            if (!_isSocialLoginLoading) _buildSocialLoginSection(),
            
            SizedBox(height: 20),
            
            // Mode Toggle Section
            _buildModeToggleSection(),
          ],
        ),
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
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kPrimaryTeal,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryTeal.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.home_repair_service,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== FORM SECTION =====
  Widget _buildFormSection() {
    return SlideTransition(
      position: _formSlideAnimation,
      child: FadeTransition(
        opacity: _formOpacityAnimation,
        child: ModernCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  _isLogin ? 'Connexion' : 'Inscription',
                  style: kHeadingMedium,
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 8),
                
                Text(
                  _isLogin 
                    ? 'Accédez à votre compte'
                    : 'Créez votre compte utilisateur',
                  style: kBodyMedium.copyWith(color: kSubtitleColor),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 30),
                
                // Registration Fields
                if (_isRegistrationMode) ...[
                  _buildNameFields(),
                  SizedBox(height: 16),
                  _buildPhoneField(),
                  SizedBox(height: 16),
                  _buildAvatarSelector(),
                  SizedBox(height: 16),
                ],
                
                // Email Field
                _buildEmailField(),
                
                SizedBox(height: 16),
                
                // Password Field
                _buildPasswordField(),
                
                SizedBox(height: 16),
                
                // Confirm Password Field (Registration only)
                if (_isRegistrationMode) ...[
                  _buildConfirmPasswordField(),
                  SizedBox(height: 16),
                ],
                
                // Remember Me (Login only)
                if (_isLogin) ...[
                  _buildRememberMeCheckbox(),
                  SizedBox(height: 16),
                ],
                
                // Terms (Registration only)
                if (_isRegistrationMode) ...[
                  _buildTermsCheckboxes(),
                  SizedBox(height: 16),
                ],
                
                // Progress Indicator
                _buildProgressIndicator(),
                
                SizedBox(height: 20),
                
                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== FORM FIELDS =====
  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _firstNameController,
            label: 'Prénom',
            icon: Icons.person,
            validator: (value) => _validationErrors['firstName'],
            isValid: _isFirstNameValid,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: _lastNameController,
            label: 'Nom',
            icon: Icons.person,
            validator: (value) => _validationErrors['lastName'],
            isValid: _isLastNameValid,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: 'Téléphone',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      validator: (value) => _validationErrors['phone'],
      isValid: _isPhoneValid,
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      label: 'Email',
      icon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      validator: (value) => _validationErrors['email'],
      isValid: _isEmailValid,
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _passwordController,
      label: 'Mot de passe',
      icon: Icons.lock,
      isPassword: true,
      isPasswordVisible: _isPasswordVisible,
      onPasswordVisibilityChanged: (visible) {
        setState(() {
          _isPasswordVisible = visible;
        });
      },
      validator: (value) => _validationErrors['password'],
      isValid: _isPasswordValid,
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildTextField(
      controller: _confirmPasswordController,
      label: 'Confirmer le mot de passe',
      icon: Icons.lock,
      isPassword: true,
      isPasswordVisible: _isConfirmPasswordVisible,
      onPasswordVisibilityChanged: (visible) {
        setState(() {
          _isConfirmPasswordVisible = visible;
        });
      },
      validator: (value) => _validationErrors['confirmPassword'],
      isValid: _isConfirmPasswordValid,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    Function(bool)? onPasswordVisibilityChanged,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool? isValid,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isValid == true ? kSuccessColor : 
                 isValid == false ? kErrorColor : kBorderLight,
          width: isValid != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryDark.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: kPrimaryDark),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: kSubtitleColor,
                  ),
                  onPressed: () {
                    onPasswordVisibilityChanged?.call(!isPasswordVisible);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  // ===== AVATAR SELECTOR =====
  Widget _buildAvatarSelector() {
    final avatars = [
      'assets/avatars/users/avatar_user_1.svg',
      'assets/avatars/users/avatar_user_2.svg',
      'assets/avatars/users/avatar_user_3.svg',
      'assets/avatars/users/avatar_user_4.svg',
      'assets/avatars/users/avatar_user_5.svg',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez votre avatar',
          style: kLabelMedium,
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: avatars.map((avatar) {
            final isSelected = _selectedAvatar == avatar;
            return GestureDetector(
              onTap: () => _selectAvatar(avatar),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? kPrimaryTeal : kBorderLight,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: ClipOval(
                  child: SvgPicture.asset(
                    avatar,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ===== CHECKBOXES =====
  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isRememberMe,
          onChanged: (value) {
            setState(() {
              _isRememberMe = value ?? false;
            });
          },
          activeColor: kPrimaryTeal,
        ),
        Text(
          'Se souvenir de moi',
          style: kBodySmall,
        ),
      ],
    );
  }

  Widget _buildTermsCheckboxes() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: _isTermsAccepted,
              onChanged: (value) {
                setState(() {
                  _isTermsAccepted = value ?? false;
                });
              },
              activeColor: kPrimaryTeal,
            ),
            Expanded(
              child: Text(
                'J\'accepte les conditions d\'utilisation',
                style: kBodySmall,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: _isPrivacyAccepted,
              onChanged: (value) {
                setState(() {
                  _isPrivacyAccepted = value ?? false;
                });
              },
              activeColor: kPrimaryTeal,
            ),
            Expanded(
              child: Text(
                'J\'accepte la politique de confidentialité',
                style: kBodySmall,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: _isMarketingAccepted,
              onChanged: (value) {
                setState(() {
                  _isMarketingAccepted = value ?? false;
                });
              },
              activeColor: kPrimaryTeal,
            ),
            Expanded(
              child: Text(
                'J\'accepte de recevoir des communications marketing',
                style: kBodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== PROGRESS INDICATOR =====
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _formProgress,
          backgroundColor: kBorderLight,
          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryTeal),
        ),
        SizedBox(height: 8),
        Text(
          '${(_formProgress * 100).toInt()}% complété',
          style: kCaptionSmall,
        ),
      ],
    );
  }

  // ===== SUBMIT BUTTON =====
  Widget _buildSubmitButton() {
    final isFormValid = _isLogin 
        ? (_isEmailValid && _isPasswordValid)
        : (_isEmailValid && _isPasswordValid && _isConfirmPasswordValid && 
           _isFirstNameValid && _isLastNameValid && _isPhoneValid &&
           _isTermsAccepted && _isPrivacyAccepted);

    return ElevatedButton(
      onPressed: isFormValid && !_isLoading ? _handleAuthentication : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryTeal,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              _isLogin ? 'Se connecter' : 'S\'inscrire',
              style: kButtonMedium,
            ),
    );
  }

  // ===== SOCIAL LOGIN SECTION =====
  Widget _buildSocialLoginSection() {
    return SlideTransition(
      position: _socialSlideAnimation,
      child: FadeTransition(
        opacity: _socialOpacityAnimation,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Divider(color: kBorderLight)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ou continuer avec',
                    style: kBodySmall.copyWith(color: kSubtitleColor),
                  ),
                ),
                Expanded(child: Divider(color: kBorderLight)),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  'Google',
                  Icons.g_mobiledata,
                  kPrimaryRed,
                  () => _handleSocialLogin('google'),
                ),
                _buildSocialButton(
                  'Facebook',
                  Icons.facebook,
                  kPrimaryTeal,
                  () => _handleSocialLogin('facebook'),
                ),
                if (_isBiometricAvailable)
                  _buildSocialButton(
                    'Biométrie',
                    Icons.fingerprint,
                    kPrimaryDark,
                    _attemptBiometricLogin,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  // ===== MODE TOGGLE SECTION =====
  Widget _buildModeToggleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin 
              ? 'Pas encore de compte ? '
              : 'Déjà un compte ? ',
          style: kBodyMedium.copyWith(color: kSubtitleColor),
        ),
        GestureDetector(
          onTap: _toggleMode,
          child: Text(
            _isLogin ? 'S\'inscrire' : 'Se connecter',
            style: kLinkMedium,
          ),
        ),
      ],
    );
  }

  // ===== OVERLAYS =====
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: AnimatedBuilder(
          animation: _loadingController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _loadingRotationAnimation.value,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryTeal),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return AnimatedBuilder(
      animation: _successController,
      builder: (context, child) {
        return Transform.scale(
          scale: _successScaleAnimation.value,
          child: Container(
            color: kSuccessColor.withOpacity(0.1),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: kSuccessColor,
                    size: 80,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _successMessage,
                    style: kSubheadingMedium.copyWith(color: kSuccessColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorOverlay() {
    return AnimatedBuilder(
      animation: _errorController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_errorShakeAnimation.value * 10, 0),
          child: Container(
            color: kErrorColor.withOpacity(0.1),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: kErrorColor,
                    size: 80,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: kSubheadingMedium.copyWith(color: kErrorColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== PERFORMANCE MONITORING =====
  void _recordFrameRate() {
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!).inMicroseconds;
      final frameRate = 1000000 / frameTime;
      _frameRates.add(frameRate);
      
      if (_frameRates.length > 60) {
        _frameRates.removeAt(0);
      }
    }
    _lastFrameTime = now;
    _frameCount++;
  }
}