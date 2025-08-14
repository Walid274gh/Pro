import 'package:flutter/material.dart';

class AppColors {
	static const Color white = Color(0xFFFFFFFF);
	static const Color black = Color(0xFF050C38);
	static const Color gray50 = Color(0xFFFAFAFA);
	static const Color gray100 = Color(0xFFF5F5F5);
	static const Color gray200 = Color(0xFFEEEEEE);
	static const Color gray300 = Color(0xFFE0E0E0);
	static const Color gray400 = Color(0xFFBDBDBD);
	static const Color gray500 = Color(0xFF9E9E9E);
	static const Color gray600 = Color(0xFF757575);
	static const Color gray700 = Color(0xFF616161);
	static const Color gray800 = Color(0xFF424242);
	static const Color gray900 = Color(0xFF212121);

	static const Color pinkPastel = Color(0xFFFCCBF0);
	static const Color coral = Color(0xFFFF5A57);
	static const Color magenta = Color(0xFFE02F75);
	static const Color violetDeep = Color(0xFF6700A3);
	static const Color blueNight = Color(0xFF1B2062);
	static const Color blueNavy = Color(0xFF050C38);
}

class AppGradients {
	static const Gradient primary = LinearGradient(
		colors: [AppColors.pinkPastel, AppColors.coral],
		begin: Alignment.topLeft,
		end: Alignment.bottomRight,
	);
	static const Gradient secondary = LinearGradient(
		colors: [AppColors.coral, AppColors.magenta],
		begin: Alignment.topLeft,
		end: Alignment.bottomRight,
	);
	static const Gradient accent = LinearGradient(
		colors: [AppColors.violetDeep, AppColors.blueNight],
		begin: Alignment.topLeft,
		end: Alignment.bottomRight,
	);
	static const Gradient tertiary = LinearGradient(
		colors: [AppColors.magenta, AppColors.blueNavy],
		begin: Alignment.topLeft,
		end: Alignment.bottomRight,
	);
}