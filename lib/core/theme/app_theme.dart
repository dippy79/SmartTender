import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Backward compat aliases
  static const Color primaryViolet = goldPrimary;
  static const Color secondaryCyan = accentBlue;
  static const Color accentCoral = accentRed;
  static const Color successGreen = accentGreen;
  static const Color warningAmber = accentRed;
  static const Color textOffWhite = textPrimary;
  static const LinearGradient tenderGradient = blueGradient;
  static const LinearGradient boqGradient = greenGradient;
  static const LinearGradient aiGradient = purpleGradient;
  static const Color surfaceDarkHover = surfaceElevated;
  // Exact Design System Colors from Spec
  static const Color backgroundDeep = Color(0xFF14202E);   // --navy
  static const Color surfaceDark = Color(0xFF1C2D3F);     // --navy2 cards
  static const Color surfaceElevated = Color(0xFF243549); // --navy3 elevated
  static const Color surfaceSlate = Color(0xFF304259);    // --slate

  static const Color goldPrimary = Color(0xFFC4A054);     // --gold CTA
  static const Color goldLight = Color(0xFFD4B06A);       // --gold2 hover
  static const Color goldSubtle = Color(0x1FC4A054);            // --goldlt 12%

  static const Color accentBlue = Color(0xFF4A8FC4);      // --blue
  static const Color accentGreen = Color(0xFF4E9B72);     // --green  
  static const Color accentRed = Color(0xFFA85060);       // --red
  static const Color accentPurple = Color(0xFF7B6DBF);    // --purple

  static const Color textPrimary = Color(0xFFF4F8FC);     // --white headings
  static const Color textSecondary = Color(0xFFD0DBE8);   // --text body
  static const Color textMuted = Color(0xFF6B82A0);       // --muted labels
  static const Color textDim = Color(0xFF4A5F78);         // --dim placeholders

  static const Color borderSubtle = Color(0x12FFFFFF);    // --border 7% white
  static const Color borderGold = Color(0x33C4A054);      // --border2 20% gold

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldPrimary, goldLight],
    begin: Alignment.topLeft, 
    end: Alignment.bottomRight,
  );
  static const LinearGradient blueGradient = LinearGradient(
    colors: [accentBlue, Color.fromRGBO(74, 143, 196, 0.7)],
    begin: Alignment.topLeft, 
    end: Alignment.bottomRight,
  );
  static const LinearGradient greenGradient = LinearGradient(
    colors: [accentGreen, Color.fromRGBO(78, 155, 114, 0.7)],
    begin: Alignment.topLeft, 
    end: Alignment.bottomRight,
  );
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [accentPurple, Color.fromRGBO(123, 109, 191, 0.7)],
    begin: Alignment.topLeft, 
    end: Alignment.bottomRight,
  );

  // Sidebar Constants
  static const double sidebarWidth = 200.0;
  static const Color sidebarBg = surfaceDark;
  static const Color sidebarBorder = borderSubtle;

  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(fontSize: 56, fontWeight: FontWeight.w700, color: textPrimary),
    headlineLarge: GoogleFonts.playfairDisplay(fontSize: 38, fontWeight: FontWeight.w700, color: textPrimary),
    headlineMedium: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary),
    titleLarge: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
    titleMedium: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
    bodyLarge: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: textSecondary),
    bodyMedium: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
    labelSmall: GoogleFonts.dmSans(
      fontSize: 10, 
      fontWeight: FontWeight.w700, 
      letterSpacing: 1.6, 
      color: textMuted
    ),
    bodySmall: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: goldPrimary,
      secondary: accentBlue,
      surface: surfaceDark,
      onSurface: textPrimary,
      onPrimary: Color(0xFF1A1000),
    ),
    scaffoldBackgroundColor: backgroundDeep,
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceElevated.withValues(alpha: 0.85),
      foregroundColor: goldPrimary,
      elevation: 0,
      titleTextStyle: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: goldPrimary,
        foregroundColor: Color(0xFF1A1000),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 14),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        shadowColor: goldPrimary.withValues(alpha: 0.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textSecondary,
        side: BorderSide(color: borderGold, width: 1),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceElevated.withValues(alpha: 0.5),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderSubtle)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderSubtle)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderGold, width: 2)),
      hintStyle: GoogleFonts.dmSans(color: textDim, fontSize: 13),
    ),
  );

  // Card convenience builder
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceDark,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: borderSubtle, width: 1),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16, offset: Offset(0, 6))
    ],
  );
}
