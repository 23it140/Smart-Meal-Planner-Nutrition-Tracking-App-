import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C94FF);
  static const Color primaryDark = Color(0xFF3D35CC);
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentOrange = Color(0xFFFF7043);
  static const Color accentYellow = Color(0xFFFFCA28);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // Nutrient Colors
  static const Color proteinColor = Color(0xFF5C6BC0);
  static const Color carbsColor = Color(0xFFFF7043);
  static const Color fatsColor = Color(0xFFFFCA28);
  static const Color calorieColor = Color(0xFF26A69A);

  // Removed static const backgrounds to use dynamic context methods

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF3D35CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF0097A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dynamic Colors based on Brightness
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color bgDark(BuildContext context) => isDark(context) ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6F9);
  static Color bgCard(BuildContext context) => isDark(context) ? const Color(0xFF1A1A2E) : Colors.white;
  static Color bgCardLight(BuildContext context) => isDark(context) ? const Color(0xFF16213E) : const Color(0xFFF8FAFC);
  static Color bgSurface(BuildContext context) => isDark(context) ? const Color(0xFF0F3460) : const Color(0xFFE5E9F2);
  static Color divider(BuildContext context) => isDark(context) ? const Color(0xFF2A2A4A) : const Color(0xFFE2E8F0);

  static Color textMain(BuildContext context) => isDark(context) ? Colors.white : const Color(0xFF1E293B);
  static Color textMuted(BuildContext context) => isDark(context) ? Colors.white70 : const Color(0xFF475569);
  static Color textFaint(BuildContext context) => isDark(context) ? Colors.white38 : const Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        tertiary: accentOrange,
        surface: Colors.white,
        error: error,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
        displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
        headlineLarge: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
        headlineMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
        titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
        titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B)),
        bodyLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xFF334155)),
        bodyMedium: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF475569)),
        labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        titleTextStyle: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: error, width: 1.5)),
        hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 14),
        labelStyle: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: primary.withOpacity(0.15),
        labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0), thickness: 1),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: accent,
        tertiary: accentOrange,
        surface: bgCard,
        error: error,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFCCCCDD),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFAAAAAA),
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(color: const Color(0xFF666688), fontSize: 14),
        labelStyle: GoogleFonts.outfit(color: const Color(0xFF8888AA), fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF666688),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgCard,
        selectedColor: primary.withOpacity(0.3),
        labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: divider),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgCardLight,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
