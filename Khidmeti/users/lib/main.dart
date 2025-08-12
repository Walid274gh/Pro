import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import des constantes
import 'constants/colors.dart';
import 'constants/text_styles.dart';

// Import des modèles
import 'models/user_model.dart';
import 'models/worker_model.dart';
import 'models/service_model.dart';
import 'models/request_model.dart';

// Import des services
import 'services/auth_service.dart';
import 'services/database_service.dart';

// Import des widgets
import 'widgets/modern_card.dart';

// Import des écrans
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(KhidmetiApp());
}

class KhidmetiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khidmeti Users',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Paytone One',
        scaffoldBackgroundColor: kBackgroundColor,
        textTheme: TextTheme(
          headline1: kHeadingLarge,
          headline2: kHeadingMedium,
          headline3: kHeadingSmall,
          subtitle1: kSubheadingLarge,
          subtitle2: kSubheadingMedium,
          bodyText1: kBodyLarge,
          bodyText2: kBodyMedium,
          button: kButtonMedium,
          caption: kCaptionMedium,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryTeal,
            foregroundColor: kTextInverse,
            textStyle: kButtonMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: kBorderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: kBorderFocus, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: kErrorColor),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardTheme(
          color: kSurfaceColor,
          elevation: 5,
          shadowColor: kShadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Provider pour la gestion d'état globale
class AppState extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Widget principal avec Provider
class KhidmetiAppWithProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: KhidmetiApp(),
    );
  }
}
