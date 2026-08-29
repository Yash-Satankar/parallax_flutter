import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors — Electric Studio Palette
  static const primary = Color(0xFF6366F1); // Electric Indigo
  static const secondary = Color(0xFF8B5CF6); // Cyber Violet
  static const accent = Color(0xFFA855F7); // Neon Purple
  static const cyan = Color(0xFF06B6D4); // Cyber Cyan
  static const blue = Color(0xFF3B82F6); // Cobalt Blue
  static const success = Color(0xFF10B981); // Emerald Green
  static const warning = Color(0xFFF59E0B); // Amber Flame
  static const error = Color(0xFFEF4444); // Crimson Rose
  static const pink = Color(0xFFEC4899); // Hot Pink / Audio Accent

  // Obsidian Dark Surfaces
  static const bgDark = Color(0xFF080B11); // Deep Obsidian
  static const surfaceDark = Color(0xFF0F1420); // Studio Surface
  static const cardDark = Color(0xFF151B2B); // Glass Card Dark
  static const cardElevated = Color(0xFF1C2438); // Elevated Card
  static const surfaceDark2 = Color(0xFF232D45); // Input & Tool Surface
  static const borderDark = Color(0xFF28344E); // Standard Border
  static const borderSubtle = Color(0x1AFFFFFF); // 10% Specular Glass Edge
  static const borderSubtleGlow = Color(0x336366F1); // Indigo Specular Glow

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cyanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const amberGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkCardGradient = LinearGradient(
    colors: [Color(0xFF171E30), Color(0xFF0E1321)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const glassOverlayGradient = LinearGradient(
    colors: [Color(0x1FFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Box Shadows
  static const shadowSm = [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  static const shadowMd = [
    BoxShadow(
      color: Color(0x60000000),
      offset: Offset(0, 4),
      blurRadius: 14,
    ),
  ];

  static const shadowGlowPrimary = [
    BoxShadow(
      color: Color(0x406366F1),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static const shadowGlowCyan = [
    BoxShadow(
      color: Color(0x4006B6D4),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surfaceDark,
      error: error,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: bgDark,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderSubtle, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: borderDark, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark2,
      hintStyle: const TextStyle(color: Color(0xFF8899B0), fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFF64748B),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: primary,
      labelColor: primary,
      unselectedLabelColor: Color(0xFF94A3B8),
      dividerColor: Colors.transparent,
      labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: -0.1),
      ),
    ),
  );

  // Typography
  static const headingXL = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: Colors.white,
    height: 1.2,
  );

  static const headingLg = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: Colors.white,
    height: 1.25,
  );

  static const headingMd = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: Colors.white,
    height: 1.3,
  );

  static const headingSm = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: Colors.white,
  );

  static const bodyLg = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFE2E8F0),
    height: 1.45,
  );

  static const bodyMd = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFFCBD5E1),
    height: 1.4,
  );

  static const bodySm = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Color(0xFF94A3B8),
    height: 1.3,
  );

  static const labelMd = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const labelSm = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  static const monospaceCode = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: cyan,
    letterSpacing: 0.2,
  );
}
