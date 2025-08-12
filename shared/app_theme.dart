import 'package:flutter/material.dart';

/// Classe de thème partagée entre les applications KHIDMETI Users et Workers
/// Respecte le principe Single Responsibility en gérant uniquement l'apparence
class AppTheme {
  // Couleurs principales
  static const Color kPrimaryYellow = Color(0xFFFCCBF0);   // Rose clair
  static const Color kPrimaryRed = Color(0xFFFF5A57);      // Rouge orangé
  static const Color kPrimaryDark = Color(0xFF6700A3);     // Violet foncé
  static const Color kPrimaryTeal = Color(0xFFE02F75);     // Rose fuchsia
  static const Color kBackgroundColor = Color(0xFF1B2062); // Bleu nuit
  static const Color kSurfaceColor = Color(0xFFFFFFFF);    // Blanc
  static const Color kTextColor = Color(0xFF050C38);       // Bleu très foncé
  static const Color kSubtitleColor = Color(0xFF6B7280);   // Texte secondaire
  static const Color kSuccessColor = Color(0xFF10B981);    // Vert succès
  static const Color kErrorColor = Color(0xFFFF5A57);      // Rouge orangé
  static const Color kButton3DLight = Color(0xFFFCCBF0);   // Rose clair
  static const Color kButton3DShadow = Color(0xFF050C38);  // Bleu très foncé
  static const Color kButtonGradient1 = Color(0xFFE02F75); // Dégradé début (fuchsia)
  static const Color kButtonGradient2 = Color(0xFF6700A3); // Dégradé fin (violet foncé)

  // Styles de texte
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

  // Styles de boutons
  static BoxDecoration get kButton3DStyle => BoxDecoration(
    borderRadius: BorderRadius.circular(25),
    gradient: const LinearGradient(
      colors: [kButtonGradient1, kButtonGradient2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: kButton3DShadow.withOpacity(0.3),
        offset: const Offset(0, 4),
        blurRadius: 8,
      ),
      BoxShadow(
        color: kButton3DLight.withOpacity(0.2),
        offset: const Offset(0, -2),
        blurRadius: 4,
      ),
    ],
  );

  // Styles de cartes
  static BoxDecoration get kCardStyle => BoxDecoration(
    color: kSurfaceColor,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: kBackgroundColor.withOpacity(0.1),
        offset: const Offset(0, 8),
        blurRadius: 24,
      ),
      BoxShadow(
        color: kBackgroundColor.withOpacity(0.05),
        offset: const Offset(0, 2),
        blurRadius: 8,
      ),
    ],
  );

  // Thème principal
  static ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.purple,
    primaryColor: kPrimaryDark,
    scaffoldBackgroundColor: kBackgroundColor,
    cardTheme: CardTheme(
      color: kSurfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kPrimaryDark,
      foregroundColor: kSurfaceColor,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryTeal,
        foregroundColor: kSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: kHeadingStyle,
      headlineMedium: kSubheadingStyle,
      bodyLarge: kBodyStyle,
    ),
    colorScheme: const ColorScheme.light(
      primary: kPrimaryDark,
      secondary: kPrimaryTeal,
      surface: kSurfaceColor,
      background: kBackgroundColor,
      error: kErrorColor,
    ),
  );
}