import 'package:flutter/material.dart';

// ===== PALETTE DE COULEURS PAYTONE ONE =====
const Color kPrimaryYellow = Color(0xFFFCDC73);
const Color kPrimaryRed = Color(0xFFE76268);
const Color kPrimaryDark = Color(0xFF193948);
const Color kPrimaryTeal = Color(0xFF4FADCD);
const Color kBackgroundColor = Color(0xFFFEF7E6);
const Color kSurfaceColor = Color(0xFFFFFFFF);
const Color kTextColor = Color(0xFF193948);
const Color kSubtitleColor = Color(0xFF6B7280);
const Color kSuccessColor = Color(0xFF28A745);
const Color kErrorColor = Color(0xFFDC3545);
const Color kButton3DLight = Color(0xFFFFFFFF);
const Color kButton3DShadow = Color(0xFFD1D5DB);
const Color kButtonGradient1 = Color(0xFF193948);
const Color kButtonGradient2 = Color(0xFF4FADCD);

// ===== COULEURS DÉRIVÉES =====
const Color kPrimaryYellowLight = Color(0xFFFDE68A);
const Color kPrimaryYellowDark = Color(0xFFF59E0B);
const Color kPrimaryRedLight = Color(0xFFEF4444);
const Color kPrimaryRedDark = Color(0xFFDC2626);
const Color kPrimaryDarkLight = Color(0xFF374151);
const Color kPrimaryDarkDark = Color(0xFF111827);
const Color kPrimaryTealLight = Color(0xFF67E8F9);
const Color kPrimaryTealDark = Color(0xFF0891B2);

// ===== COULEURS DE FOND =====
const Color kBackgroundLight = Color(0xFFFEF7E6);
const Color kBackgroundDark = Color(0xFF1F2937);
const Color kSurfaceLight = Color(0xFFFFFFFF);
const Color kSurfaceDark = Color(0xFF374151);

// ===== COULEURS DE TEXTE =====
const Color kTextPrimary = Color(0xFF193948);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextTertiary = Color(0xFF9CA3AF);
const Color kTextInverse = Color(0xFFFFFFFF);

// ===== COULEURS D'ÉTAT =====
const Color kSuccessLight = Color(0xFFD1FAE5);
const Color kSuccessDark = Color(0xFF059669);
const Color kErrorLight = Color(0xFFFEE2E2);
const Color kErrorDark = Color(0xFFDC2626);
const Color kWarningLight = Color(0xFFFEF3C7);
const Color kWarningDark = Color(0xFFD97706);
const Color kInfoLight = Color(0xFFDBEAFE);
const Color kInfoDark = Color(0xFF2563EB);

// ===== COULEURS DE BORDURE =====
const Color kBorderLight = Color(0xFFE5E7EB);
const Color kBorderDark = Color(0xFF374151);
const Color kBorderFocus = Color(0xFF4FADCD);

// ===== COULEURS DE SHADOW =====
const Color kShadowLight = Color(0x1A000000);
const Color kShadowMedium = Color(0x33000000);
const Color kShadowDark = Color(0x4D000000);

// ===== COULEURS DE GRADIENT =====
const List<Color> kGradientPrimary = [kButtonGradient1, kButtonGradient2];
const List<Color> kGradientSuccess = [kSuccessColor, kSuccessDark];
const List<Color> kGradientError = [kErrorColor, kErrorDark];
const List<Color> kGradientWarning = [kPrimaryYellow, kPrimaryYellowDark];

// ===== COULEURS DE TRANSPARENCE =====
const Color kTransparent = Colors.transparent;
const Color kPrimaryYellowTransparent = Color(0x1AFCDC73);
const Color kPrimaryRedTransparent = Color(0x1AE76268);
const Color kPrimaryDarkTransparent = Color(0x1A193948);
const Color kPrimaryTealTransparent = Color(0x1A4FADCD);

// ===== COULEURS DE RATING =====
const Color kRatingStar = Color(0xFFFFD700);
const Color kRatingStarEmpty = Color(0xFFE5E7EB);

// ===== COULEURS DE PROGRESS =====
const Color kProgressBackground = Color(0xFFE5E7EB);
const Color kProgressFill = Color(0xFF4FADCD);

// ===== COULEURS DE NOTIFICATION =====
const Color kNotificationSuccess = Color(0xFF10B981);
const Color kNotificationError = Color(0xFFEF4444);
const Color kNotificationWarning = Color(0xFFF59E0B);
const Color kNotificationInfo = Color(0xFF3B82F6);

// ===== COULEURS DE CARTE =====
const Color kMapBackground = Color(0xFFF8FAFC);
const Color kMapWater = Color(0xFFE0F2FE);
const Color kMapLand = Color(0xFFF0FDF4);

// ===== COULEURS DE CHAT =====
const Color kChatBubbleUser = Color(0xFF4FADCD);
const Color kChatBubbleOther = Color(0xFFE5E7EB);
const Color kChatBackground = Color(0xFFF9FAFB);

// ===== COULEURS DE PAYMENT =====
const Color kPaymentSuccess = Color(0xFF10B981);
const Color kPaymentPending = Color(0xFFF59E0B);
const Color kPaymentFailed = Color(0xFFEF4444);

// ===== COULEURS DE STATUS =====
const Color kStatusOnline = Color(0xFF10B981);
const Color kStatusOffline = Color(0xFF6B7280);
const Color kStatusBusy = Color(0xFFEF4444);
const Color kStatusAway = Color(0xFFF59E0B);

// ===== COULEURS DE CATÉGORIES =====
const Color kCategoryPlomberie = Color(0xFF3B82F6);
const Color kCategoryElectricite = Color(0xFFF59E0B);
const Color kCategoryMenage = Color(0xFF10B981);
const Color kCategoryJardinage = Color(0xFF059669);
const Color kCategoryPeinture = Color(0xFF8B5CF6);
const Color kCategoryReparation = Color(0xFFEF4444);
const Color kCategoryTransport = Color(0xFF06B6D4);
const Color kCategoryCuisine = Color(0xFFF97316);

// ===== MÉTHODES UTILITAIRES =====
class ColorUtils {
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color blend(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio)!;
  }

  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  static Color getContrastColor(Color backgroundColor) {
    return isDark(backgroundColor) ? Colors.white : Colors.black;
  }

  static Color getShade(Color color, double shade) {
    return HSLColor.fromColor(color).withLightness(
      (HSLColor.fromColor(color).lightness * shade).clamp(0.0, 1.0)
    ).toColor();
  }

  static List<Color> generateGradient(Color startColor, Color endColor, int steps) {
    List<Color> colors = [];
    for (int i = 0; i < steps; i++) {
      colors.add(blend(startColor, endColor, i / (steps - 1)));
    }
    return colors;
  }
}