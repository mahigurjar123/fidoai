import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF060614);
  static const bgCard = Color(0xFF0C0C24);
  static const purple = Color(0xFF7B2FFF);
  static const purpleLight = Color(0xFFAA6FFF);
  static const blue = Color(0xFF2F8FFF);
  static const cyan = Color(0xFF00F5FF);
  static const pink = Color(0xFFFF2FBE);
  static const gold = Color(0xFFFFD700);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF9090B8);
  static const textMuted = Color(0xFF50506A);
  static const border = Color(0xFF1E1E4A);

  static const LinearGradient primaryGrad = LinearGradient(
    colors: [purple, blue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient purpleGrad = LinearGradient(
    colors: [Color(0xFF7B2FFF), Color(0xFF4A1FB8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGrad = LinearGradient(
    colors: [Color(0xFF2F8FFF), Color(0xFF1A5FCC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGrad = LinearGradient(
    colors: [Color(0xFF00C9FF), Color(0xFF0070FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGrad = LinearGradient(
    colors: [Color(0xFFFF2FBE), Color(0xFFCC007A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Responsive utility — centralises breakpoint logic.
class R {
  R._();

  /// True when viewport width < 600 px (mobile).
  static bool mobile(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width < 600;

  /// True when viewport width is 600–1024 px (tablet).
  static bool tablet(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    return w >= 600 && w <= 1024;
  }

  /// True when viewport width > 1024 px (desktop).
  static bool desktop(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width > 1024;

  /// Horizontal page padding: 16 mobile / 32 tablet / 64 desktop.
  static double hp(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w < 600) return 16;
    if (w <= 1024) return 32;
    return 64;
  }

  /// Fluid font size between [mobileSz] and [desktopSz].
  static double fs(BuildContext ctx, double mobileSz, double desktopSz) {
    final w = MediaQuery.of(ctx).size.width;
    if (w < 600) return mobileSz;
    if (w > 1024) return desktopSz;
    // Linearly interpolate for tablet range
    return mobileSz + (desktopSz - mobileSz) * ((w - 600) / (1024 - 600));
  }

  /// Grid cross-axis count: 1 / 2 / 3 for mobile / tablet / desktop.
  static int gridCols(BuildContext ctx) {
    if (mobile(ctx)) return 1;
    if (tablet(ctx)) return 2;
    return 3;
  }
}

class AppTextStyles {
  static TextStyle display(BuildContext ctx) => GoogleFonts.inter(
        fontSize: R.fs(ctx, 48, 80),
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -2,
        height: 1.1,
      );

  static TextStyle h1(BuildContext ctx) => GoogleFonts.inter(
        fontSize: R.fs(ctx, 32, 56),
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -1.5,
      );

  static TextStyle h2(BuildContext ctx) => GoogleFonts.inter(
        fontSize: R.fs(ctx, 22, 32),
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
      );

  static TextStyle body(BuildContext ctx) => GoogleFonts.inter(
        fontSize: R.fs(ctx, 14, 17),
        color: AppColors.textSecondary,
        height: 1.7,
      );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 2.5,
  );
}

ThemeData buildTheme() => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purple,
        secondary: AppColors.cyan,
        surface: AppColors.bgCard,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      scrollbarTheme: const ScrollbarThemeData(
        thumbVisibility: WidgetStatePropertyAll(false),
      ),
    );
