import 'package:flutter/material.dart';

class AppTheme {
  // Cosmic Midnight Palette (inspired by Luna AI reference)
  static const Color backgroundDark = Color(0xFF0B0E23); // Deep cosmic navy/black
  static const Color surfaceDark = Color(0xFF141838);    // Deep card surface
  static const Color surfaceTile = Color(0xFF1B2048);    // Tile surface
  static const Color borderSubtle = Color(0xFF2C3368);   // Card border stroke

  // Reference Card Gradient Colors
  static const Color cardPurple = Color(0xFF6453ED);     // Vibrant Lavender / Purple card
  static const Color cardLilac = Color(0xFF9E77F7);      // Pastel Lilac card
  static const Color cardCoral = Color(0xFFF08C65);      // Warm Peach / Sunset Terracotta
  static const Color cardDeepViolet = Color(0xFF2E2462); // Top tile accent

  // Functional Accents
  static const Color accentCyan = Color(0xFF38EF7D);     // Active / Online indicator
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9CA3AF);      // Soft secondary text
  static const Color textPurpleLight = Color(0xFFD6D1FD);// Light lavender text for subtitles

  // Curved Radii according to reference UI
  static final BorderRadius cardRadius = BorderRadius.circular(26);
  static final BorderRadius tileRadius = BorderRadius.circular(22);
  static final BorderRadius buttonRadius = BorderRadius.circular(20);
  static final BorderRadius inputRadius = BorderRadius.circular(18);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: cardPurple,
      colorScheme: const ColorScheme.dark(
        primary: cardPurple,
        secondary: cardCoral,
        surface: surfaceDark,
        error: Color(0xFFEF4444),
        onPrimary: textWhite,
        onSurface: textWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: textWhite),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: const BorderSide(color: borderSubtle, width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cardPurple,
          foregroundColor: textWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: buttonRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textWhite,
          side: const BorderSide(color: borderSubtle, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: buttonRadius,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceTile,
        selectedColor: cardPurple,
        side: const BorderSide(color: borderSubtle, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelStyle: const TextStyle(
          color: textWhite,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: cardLilac, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: borderSubtle, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: borderSubtle, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: cardLilac, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F122B),
        selectedItemColor: cardLilac,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
      ),
    );
  }
}
