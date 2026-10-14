import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AgriIntel Design Tokens - Handcrafted Paper & Eco-Premium Palette
class AppColors {
  // Surfaces & Parchment Canvas
  static const Color parchment = Color(0xFFFAF6EC);       // Warm handcrafted paper background
  static const Color cardCream = Color(0xFFFFFDF7);        // Card cream surface
  static const Color cardCreamElevated = Color(0xFFFFFFFC);
  static const Color border = Color(0xFFE6DFCC);           // Subtle warm kraft border
  static const Color borderWarm = Color(0xFFE6DFCC);       // Warm border alias
  static const Color borderSubtle = Color(0xFFF0EBE0);
  static const Color borderFocus = Color(0xFF1F4D3A);

  // Core Brand Greens
  static const Color primaryForest = Color(0xFF1F4D3A);    // Deep Forest Green
  static const Color forestGreen = Color(0xFF1F4D3A);      // Alias
  static const Color fernGreen = Color(0xFF4F8A5B);       // Vibrant Fern Green
  static const Color deepSectionDark = Color(0xFF12281F);  // Deep Dark Section Green
  static const Color deepDarkGreen = Color(0xFF12281F);    // Alias
  static const Color sageBg = Color(0xFFEBF3EB);          // Soft Botanical Sage Container
  static const Color emeraldGlow = Color(0xFF2E7D32);     // Eco Accent Green
  static const Color mintLeaf = Color(0xFF70A87D);        // Soft Mint Frond

  // Accents & Earth Warmth
  static const Color diwaliGold = Color(0xFFE8A33D);      // Festive Diwali Gold / Amber
  static const Color gold = Color(0xFFE8A33D);            // Alias
  static const Color goldLight = Color(0xFFFDF4E3);       // Soft Gold Tint
  static const Color terracotta = Color(0xFFC8643C);      // Earthy Terracotta Red-Orange
  static const Color terracottaLight = Color(0xFFFBECE8); // Light Terracotta Tint
  static const Color washiTape = Color(0xFFEADBBE);       // Washi tape Kraft tint
  static const Color washiTapeGreen = Color(0xFFD6E3D4);  // Green Washi tape

  // Text & Typography
  static const Color textPrimary = Color(0xFF1E2A24);     // Deep Organic Charcoal
  static const Color textMain = Color(0xFF1E2A24);        // Alias
  static const Color textSecondary = Color(0xFF5C6B62);   // Muted Botanical Slate
  static const Color textMuted = Color(0xFF5C6B62);       // Soft Subtitle Mute
  static const Color textOnDark = Color(0xFFFAF6EC);      // Parchment text on dark cards

  // Semantic Spray Gatekeeper & Agronomic Statuses
  static const Color sprayGood = Color(0xFF2E7D32);       // Optimal Green
  static const Color sprayGoodBg = Color(0xFFEDF7ED);
  static const Color sprayGoodBorder = Color(0xFFB7D9BF);

  static const Color sprayCaution = Color(0xFFD97706);    // Caution Amber
  static const Color sprayCautionBg = Color(0xFFFEF3E2);
  static const Color sprayCautionBorder = Color(0xFFF5D399);

  static const Color sprayStop = Color(0xFFC8433C);       // Do Not Spray Red
  static const Color sprayStopBg = Color(0xFFFDECEB);
  static const Color sprayStopBorder = Color(0xFFF5B8B4);

  static const Color sprayInfo = Color(0xFF1976D2);       // Info Blue
  static const Color sprayInfoBg = Color(0xFFE8F1FC);
  static const Color sprayInfoBorder = Color(0xFFB8D5F7);

  // Disease Severity Chips
  static const Color severityMild = Color(0xFF2E7D32);
  static const Color severityMildBg = Color(0xFFEDF7ED);
  static const Color severityModerate = Color(0xFFD97706);
  static const Color severityModerateBg = Color(0xFFFEF3E2);
  static const Color severitySevere = Color(0xFFC8433C);
  static const Color severitySevereBg = Color(0xFFFDECEB);

  // Statutory Toxicity Bands (CIB&RC India Regulations)
  static const Color toxicityGreen = Color(0xFF2E7D32);   // Caution / Slightly Toxic
  static const Color toxicityBlue = Color(0xFF1565C0);    // Danger / Moderately Toxic
  static const Color toxicityYellow = Color(0xFFF59E0B);  // Highly Toxic
  static const Color toxicityRed = Color(0xFFD32F2F);     // Extremely Toxic

  // Demo Badge
  static const Color demoBadgeBg = Color(0xFFFEF3E2);
  static const Color demoBadgeText = Color(0xFFB45309);
}

/// Spacing Scale
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border Radii
class AppRadius {
  static const double sm = 8.0;
  static const double md = 14.0;
  static const double lg = 18.0;
  static const double xl = 24.0;
  static const double pill = 999.0;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}

/// Warm Organic Shadows
class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF1F4D3A).withValues(alpha: 0.05),
          blurRadius: 14,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: const Color(0xFF4F8A5B).withValues(alpha: 0.03),
          blurRadius: 2,
          offset: const Offset(0, 1),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: const Color(0xFF1F4D3A).withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: const Color(0xFF1F4D3A).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: const Color(0xFFE8A33D).withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get seal => [
        BoxShadow(
          color: const Color(0xFFC8643C).withValues(alpha: 0.22),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowSun => [
        BoxShadow(
          color: const Color(0xFFE8A33D).withValues(alpha: 0.25),
          blurRadius: 40,
          spreadRadius: 10,
        ),
      ];
}

/// Typography Tokens with Playfair / Fraunces Serifs & Inter Body + Devanagari fallbacks
class AppTextStyles {
  // Eyebrow Headers
  static TextStyle eyebrow({Color color = AppColors.diwaliGold}) {
    try {
      return GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
        color: color,
      );
    } catch (_) {
      return TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
        color: color,
      );
    }
  }

  // Serif Titles
  static TextStyle get serifHeading1 => serifTitle(fontSize: 28);
  static TextStyle get serifHeading2 => serifTitle(fontSize: 22);
  static TextStyle get serifHeading3 => serifTitle(fontSize: 17);

  static TextStyle serifTitle({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.3,
  }) {
    try {
      return GoogleFonts.fraunces(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      try {
        return GoogleFonts.playfairDisplay(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      } catch (_) {
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      }
    }
  }

  // Body Text
  static TextStyle get bodyLarge => body(fontSize: 15);
  static TextStyle get bodyMedium => body(fontSize: 13.5);
  static TextStyle get bodySmall => body(fontSize: 12, color: AppColors.textSecondary);
  static TextStyle get caption => body(fontSize: 11, color: AppColors.textSecondary);

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double height = 1.45,
  }) {
    try {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
    } catch (_) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
    }
  }
}

/// Main App Theme Configurator
class AppTheme {
  // Backwards compatible aliases for existing code references
  static const Color primaryGreen = AppColors.primaryForest;
  static const Color primaryGreenDark = AppColors.deepSectionDark;
  static const Color primaryGreenLight = AppColors.fernGreen;
  static const Color primaryGreenMint = AppColors.mintLeaf;
  static const Color accentGreen = AppColors.emeraldGlow;
  static const Color emeraldGlow = AppColors.emeraldGlow;
  static const Color secondaryAmber = AppColors.diwaliGold;
  static const Color harvestGold = AppColors.diwaliGold;
  static const Color earthSoil = Color(0xFF5D4037);
  static const Color earthClay = AppColors.terracotta;

  static const Color surfaceDark = AppColors.deepSectionDark;
  static const Color cardBg = AppColors.cardCream;
  static const Color cardBorder = AppColors.border;
  static const Color bgLight = AppColors.parchment;
  static const Color bgWarmLight = AppColors.parchment;
  static const Color sageBg = AppColors.sageBg;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;

  static const Color sprayGood = AppColors.sprayGood;
  static const Color sprayGoodBg = AppColors.sprayGoodBg;
  static const Color sprayGoodBorder = AppColors.sprayGoodBorder;

  static const Color sprayCaution = AppColors.sprayCaution;
  static const Color sprayCautionBg = AppColors.sprayCautionBg;
  static const Color sprayCautionBorder = AppColors.sprayCautionBorder;

  static const Color sprayStop = AppColors.sprayStop;
  static const Color sprayStopBg = AppColors.sprayStopBg;
  static const Color sprayStopBorder = AppColors.sprayStopBorder;

  static const Color sprayInfo = AppColors.sprayInfo;
  static const Color sprayInfoBg = AppColors.sprayInfoBg;
  static const Color sprayInfoBorder = AppColors.sprayInfoBorder;

  static const Color demoBadgeBg = AppColors.demoBadgeBg;
  static const Color demoBadgeText = AppColors.demoBadgeText;

  static ThemeData get lightTheme {
    final baseTextTheme = Typography.material2021().black;
    TextTheme appTextTheme;
    try {
      appTextTheme = GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 28),
        displaySmall: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
        headlineMedium: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        headlineSmall: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        titleLarge: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 17),
        titleMedium: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
        titleSmall: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w400, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w400, fontSize: 13.5),
        bodySmall: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w400, fontSize: 12),
        labelLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
      );
    } catch (_) {
      appTextTheme = baseTextTheme;
    }

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.parchment,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryForest,
        primary: AppColors.primaryForest,
        onPrimary: AppColors.parchment,
        primaryContainer: AppColors.sageBg,
        onPrimaryContainer: AppColors.primaryForest,
        secondary: AppColors.diwaliGold,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.goldLight,
        onSecondaryContainer: const Color(0xFF5D3B00),
        tertiary: AppColors.terracotta,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.terracottaLight,
        surface: AppColors.cardCream,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryForest,
        foregroundColor: AppColors.parchment,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          color: AppColors.parchment,
          fontSize: 19,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
        iconTheme: const IconThemeData(color: AppColors.parchment),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        color: AppColors.cardCream,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryForest,
          foregroundColor: AppColors.parchment,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
          shadowColor: AppColors.primaryForest.withValues(alpha: 0.35),
          textStyle: GoogleFonts.inter(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryForest,
          side: const BorderSide(color: AppColors.primaryForest, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardCream,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: const TextStyle(color: Color(0xFF9EAFA3), fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryForest, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.sprayStop, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardCream,
        indicatorColor: AppColors.fernGreen.withValues(alpha: 0.16),
        elevation: 6,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryForest, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 22);
        }),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColors.diwaliGold,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.parchment,
        unselectedLabelColor: AppColors.parchment.withValues(alpha: 0.72),
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardCream,
        selectedColor: AppColors.primaryForest,
        disabledColor: const Color(0xFFE8E2D2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        secondaryLabelStyle: GoogleFonts.inter(color: AppColors.parchment, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 20,
      ),
    );
  }
}
