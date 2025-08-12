import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

// ===== TYPOGRAPHIE PAYTONE ONE =====
final TextStyle kHeadingStyle = GoogleFonts.paytoneOne(
  fontSize: 28,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: -0.5,
);

final TextStyle kSubheadingStyle = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kTextColor,
  letterSpacing: -0.2,
);

final TextStyle kBodyStyle = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: 0.1,
);

// ===== STYLES DE TITRES =====
final TextStyle kHeadingLarge = GoogleFonts.paytoneOne(
  fontSize: 32,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: -0.8,
);

final TextStyle kHeadingMedium = GoogleFonts.paytoneOne(
  fontSize: 24,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: -0.5,
);

final TextStyle kHeadingSmall = GoogleFonts.paytoneOne(
  fontSize: 20,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: -0.3,
);

// ===== STYLES DE SOUS-TITRES =====
final TextStyle kSubheadingLarge = GoogleFonts.inter(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: kTextColor,
  letterSpacing: -0.2,
);

final TextStyle kSubheadingMedium = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: kTextColor,
  letterSpacing: -0.1,
);

final TextStyle kSubheadingSmall = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: kTextColor,
  letterSpacing: 0.0,
);

// ===== STYLES DE CORPS DE TEXTE =====
final TextStyle kBodyLarge = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: 0.1,
);

final TextStyle kBodyMedium = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: 0.1,
);

final TextStyle kBodySmall = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: 0.1,
);

final TextStyle kBodyXSmall = GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: 0.1,
);

// ===== STYLES DE CAPTION =====
final TextStyle kCaptionLarge = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: kSubtitleColor,
  letterSpacing: 0.2,
);

final TextStyle kCaptionMedium = GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: kSubtitleColor,
  letterSpacing: 0.2,
);

final TextStyle kCaptionSmall = GoogleFonts.inter(
  fontSize: 10,
  fontWeight: FontWeight.w500,
  color: kSubtitleColor,
  letterSpacing: 0.2,
);

// ===== STYLES DE BOUTONS =====
final TextStyle kButtonLarge = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kTextInverse,
  letterSpacing: 0.2,
);

final TextStyle kButtonMedium = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: kTextInverse,
  letterSpacing: 0.2,
);

final TextStyle kButtonSmall = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: kTextInverse,
  letterSpacing: 0.2,
);

// ===== STYLES DE LIENS =====
final TextStyle kLinkLarge = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: kPrimaryTeal,
  letterSpacing: 0.1,
  decoration: TextDecoration.underline,
);

final TextStyle kLinkMedium = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: kPrimaryTeal,
  letterSpacing: 0.1,
  decoration: TextDecoration.underline,
);

final TextStyle kLinkSmall = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: kPrimaryTeal,
  letterSpacing: 0.1,
  decoration: TextDecoration.underline,
);

// ===== STYLES DE LABELS =====
final TextStyle kLabelLarge = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: kTextColor,
  letterSpacing: 0.1,
);

final TextStyle kLabelMedium = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: kTextColor,
  letterSpacing: 0.1,
);

final TextStyle kLabelSmall = GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: kTextColor,
  letterSpacing: 0.1,
);

// ===== STYLES DE CHAMPS DE TEXTE =====
final TextStyle kInputLarge = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: 0.1,
);

final TextStyle kInputMedium = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: 0.1,
);

final TextStyle kInputSmall = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: 0.1,
);

// ===== STYLES DE NOTIFICATIONS =====
final TextStyle kNotificationTitle = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: kTextColor,
  letterSpacing: 0.1,
);

final TextStyle kNotificationBody = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kSubtitleColor,
  letterSpacing: 0.1,
);

// ===== STYLES DE CARTE =====
final TextStyle kCardTitle = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kTextColor,
  letterSpacing: -0.1,
);

final TextStyle kCardSubtitle = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: kSubtitleColor,
  letterSpacing: 0.1,
);

final TextStyle kCardBody = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: 0.1,
);

// ===== STYLES DE RATING =====
final TextStyle kRatingText = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: kTextColor,
  letterSpacing: 0.1,
);

// ===== STYLES DE PRIX =====
final TextStyle kPriceLarge = GoogleFonts.inter(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: kSuccessColor,
  letterSpacing: -0.2,
);

final TextStyle kPriceMedium = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w700,
  color: kSuccessColor,
  letterSpacing: -0.1,
);

final TextStyle kPriceSmall = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: kSuccessColor,
  letterSpacing: 0.0,
);

// ===== STYLES DE STATUS =====
final TextStyle kStatusText = GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: kTextInverse,
  letterSpacing: 0.2,
);

// ===== STYLES DE BADGES =====
final TextStyle kBadgeText = GoogleFonts.inter(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  color: kTextInverse,
  letterSpacing: 0.2,
);

// ===== STYLES DE NAVIGATION =====
final TextStyle kNavItemActive = GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: kPrimaryDark,
  letterSpacing: 0.1,
);

final TextStyle kNavItemInactive = GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: kSubtitleColor,
  letterSpacing: 0.1,
);

// ===== STYLES DE CHAT =====
final TextStyle kChatMessage = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kTextColor,
  letterSpacing: 0.1,
);

final TextStyle kChatTimestamp = GoogleFonts.inter(
  fontSize: 10,
  fontWeight: FontWeight.w400,
  color: kSubtitleColor,
  letterSpacing: 0.2,
);

// ===== MÉTHODES UTILITAIRES =====
class TextStyleUtils {
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }

  static TextStyle withDecoration(TextStyle style, TextDecoration decoration) {
    return style.copyWith(decoration: decoration);
  }

  static TextStyle withShadow(TextStyle style, List<Shadow> shadows) {
    return style.copyWith(shadows: shadows);
  }

  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }

  static TextStyle withOverflow(TextStyle style, TextOverflow overflow) {
    return style.copyWith(overflow: overflow);
  }

  static TextStyle withMaxLines(TextStyle style, int maxLines) {
    return style.copyWith(overflow: TextOverflow.ellipsis);
  }

  // Méthodes pour créer des styles avec des couleurs spécifiques
  static TextStyle success(TextStyle baseStyle) {
    return baseStyle.copyWith(color: kSuccessColor);
  }

  static TextStyle error(TextStyle baseStyle) {
    return baseStyle.copyWith(color: kErrorColor);
  }

  static TextStyle warning(TextStyle baseStyle) {
    return baseStyle.copyWith(color: kWarningDark);
  }

  static TextStyle info(TextStyle baseStyle) {
    return baseStyle.copyWith(color: kInfoDark);
  }

  static TextStyle primary(TextStyle baseStyle) {
    return baseStyle.copyWith(color: kPrimaryTeal);
  }

  static TextStyle secondary(TextStyle baseStyle) {
    return baseStyle.copyWith(color: kSubtitleColor);
  }

  // Méthodes pour créer des styles avec des tailles spécifiques
  static TextStyle large(TextStyle baseStyle) {
    return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.25);
  }

  static TextStyle small(TextStyle baseStyle) {
    return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 0.875);
  }

  static TextStyle xSmall(TextStyle baseStyle) {
    return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 0.75);
  }

  // Méthodes pour créer des styles avec des poids spécifiques
  static TextStyle bold(TextStyle baseStyle) {
    return baseStyle.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle semiBold(TextStyle baseStyle) {
    return baseStyle.copyWith(fontWeight: FontWeight.w600);
  }

  static TextStyle medium(TextStyle baseStyle) {
    return baseStyle.copyWith(fontWeight: FontWeight.w500);
  }

  static TextStyle light(TextStyle baseStyle) {
    return baseStyle.copyWith(fontWeight: FontWeight.w300);
  }
}