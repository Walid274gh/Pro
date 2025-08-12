import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KHIDMETI Users',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: const Locale('fr'),
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBackgroundColor,
      appBar: AppBar(
        title: const Text('KHIDMETI Users'),
        backgroundColor: AppTheme.kPrimaryYellow,
        foregroundColor: AppTheme.kPrimaryDark,
        elevation: 4,
      ),
      body: Center(
        child: Text('Bienvenue', style: AppTheme.kHeadingStyle),
      ),
    );
  }
}

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<void> initialize() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final String? token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM token (Users): $token');
  }
}

class AuthService {
  AuthService({fb.FirebaseAuth? auth}) : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  fb.User? get currentUser => _auth.currentUser;

  Future<fb.UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    final fb.UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName('$firstName $lastName');
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Optionally store phone in user profile via custom claims or Firestore later
    }
    return cred;
  }

  Future<fb.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendEmailVerification() async {
    final fb.User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> startPhoneNumberVerification({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String verificationId, int? forceResendingToken) onTimeout,
    required void Function(fb.PhoneAuthCredential credential) onVerified,
    required void Function(fb.FirebaseAuthException error) onFailed,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerified,
      verificationFailed: onFailed,
      codeSent: (String verificationId, int? resendToken) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (String verificationId) => onTimeout(verificationId, forceResendingToken),
      forceResendingToken: forceResendingToken,
    );
  }

  Future<fb.UserCredential> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final fb.PhoneAuthCredential credential = fb.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }
}

class AppTheme {
  // Couleurs
  static const Color kPrimaryYellow = Color(0xFFFCDC73);
  static const Color kPrimaryRed = Color(0xFFE76268);
  static const Color kPrimaryDark = Color(0xFF193948);
  static const Color kPrimaryTeal = Color(0xFF4FADCD);
  static const Color kBackgroundColor = Color(0xFFFFF8E7);
  static const Color kSurfaceColor = Color(0xFFFFFFFF);
  static const Color kTextColor = Color(0xFF193948);
  static const Color kSubtitleColor = Color(0xFF6B7280);
  static const Color kSuccessColor = Color(0xFF10B981);
  static const Color kErrorColor = Color(0xFFE76268);
  static const Color kButton3DLight = Color(0xFFFEF3C7);
  static const Color kButton3DShadow = Color(0xFF92400E);
  static const Color kButtonGradient1 = Color(0xFFFCDC73);
  static const Color kButtonGradient2 = Color(0xFFF59E0B);

  // Typographies
  static const TextStyle kHeadingStyle = TextStyle(
    fontFamily: 'Paytone One',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: kPrimaryDark,
    letterSpacing: -0.5,
  );
  static const TextStyle kSubheadingStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: kTextColor,
  );
  static const TextStyle kBodyStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: kSubtitleColor,
    height: 1.4,
  );

  static ThemeData light() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: kPrimaryYellow,
      brightness: Brightness.light,
    ).copyWith(
      primary: kPrimaryYellow,
      onPrimary: kPrimaryDark,
      secondary: kPrimaryTeal,
      onSecondary: kPrimaryDark,
      error: kErrorColor,
      surface: kSurfaceColor,
      onSurface: kTextColor,
    );

    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: kBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimaryYellow,
        foregroundColor: kPrimaryDark,
        elevation: 4,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineSmall: kHeadingStyle,
        titleMedium: kSubheadingStyle,
        bodyMedium: kBodyStyle,
        bodySmall: kBodyStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(kPrimaryYellow),
          foregroundColor: const WidgetStatePropertyAll(kPrimaryDark),
          elevation: const WidgetStatePropertyAll(4),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}
