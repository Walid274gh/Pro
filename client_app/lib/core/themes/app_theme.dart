import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
	static ThemeData light() {
		final base = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.coral), useMaterial3: true);
		return base.copyWith(
			textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
			appBarTheme: const AppBarTheme(centerTitle: true),
			elevatedButtonTheme: ElevatedButtonThemeData(
				style: ElevatedButton.styleFrom(
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
					padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
				),
			),
			cardTheme: CardTheme(
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
				elevation: 0,
				margin: EdgeInsets.zero,
				color: Colors.white,
			),
			inputDecorationTheme: InputDecorationTheme(
				filled: true,
				fillColor: Colors.white,
				border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
			),
		);
	}
}