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
  static const pink = Color(0xFFF43F5E); // Hot Magenta / Audio Track Accent
  static const orange = Color(0xFFFB923C); // Studio Gold / FX Accent

  // Obsidian Dark Surfaces & Glass Layers
  static const bgDark = Color(0xFF070A10); // Ultra Deep Obsidian Void
  static const surfaceDark = Color(0xFF0D111A); // Studio Panel Surface
  static const cardDark = Color(0xFF131824); // Glass Card Dark
  static const cardElevated = Color(0xFF1A2132); // Elevated Modal & Tool Surface
  static const surfaceDark2 = Color(0xFF222B3F); // Input & Tool Surface
  static const surfaceDark3 = Color(0xFF2D3953); // Active Selection / Highlight
  static const borderDark = Color(0xFF243048); // Standard Border
  static const borderSubtle = Color(0x1AFFFFFF); // 10% Specular Glass Edge
  static const borderSubtleGlow = Color(0x336366F1); // Indigo Specular Glow
  static const borderCyanGlow = Color(0x3306B6D4); // Cyan Specular Glow

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

  static const pinkGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkCardGradient = LinearGradient(
    colors: [Color(0xFF161E2E), Color(0xFF0E131F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroBannerGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF0F172A), Color(0xFF070A10)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const glassOverlayGradient = LinearGradient(
    colors: [Color(0x1FFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Box Shadows & Ambient Glows
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

  static const shadowLg = [
    BoxShadow(
      color: Color(0x80000000),
      offset: Offset(0, 8),
      blurRadius: 24,
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

  static const shadowGlowEmerald = [
    BoxShadow(
      color: Color(0x3310B981),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  // Common Reusable Glass Decorations
  static BoxDecoration get glassCardDecoration => BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
        boxShadow: shadowSm,
      );

  static BoxDecoration get glassElevatedDecoration => BoxDecoration(
        color: cardElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderDark),
        boxShadow: shadowMd,
      );

  static BoxDecoration get neonIndigoCardDecoration => BoxDecoration(
        gradient: darkCardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderSubtleGlow, width: 1.2),
        boxShadow: shadowGlowPrimary,
      );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      tertiary: cyan,
      surface: surfaceDark,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      outline: borderDark,
    ),
    scaffoldBackgroundColor: bgDark,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
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
      backgroundColor: cardElevated,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: borderDark, width: 1.2),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: cardElevated,
      modalBackgroundColor: cardElevated,
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: borderSubtle),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark2,
      hintStyle: const TextStyle(color: Color(0xFF8899B0), fontSize: 13),
      labelStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: error, width: 1.2),
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
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.25);
          }
          return surfaceDark2;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return const Color(0xFF94A3B8);
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const BorderSide(color: primary, width: 1.2);
          }
          return const BorderSide(color: borderSubtle, width: 1);
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceDark2,
      disabledColor: surfaceDark,
      selectedColor: primary.withValues(alpha: 0.2),
      secondarySelectedColor: primary,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      secondaryLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: borderSubtle),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: borderDark, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderSubtle,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardElevated,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderDark),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Typography Tokens
  static const heroXL = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.8,
    color: Colors.white,
    height: 1.15,
  );

  static const headingXL = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: Colors.white,
    height: 1.2,
  );

  static const headingLg = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: Colors.white,
    height: 1.25,
  );

  static const headingMd = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: Colors.white,
    height: 1.3,
  );

  static const headingSm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
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

  static const labelLg = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const labelMd = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const labelSm = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
  );

  static const monospaceCode = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: cyan,
    letterSpacing: 0.2,
  );

  static const timecodeLarge = TextStyle(
    fontFamily: 'monospace',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: cyan,
    letterSpacing: 0.5,
  );
}
