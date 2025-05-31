import 'package:flutter/material.dart';

/// Klasse für UI-Konstanten und Themes
class UIConstants {
  // Primäre Farbpalette
  static const Color primaryColor = Color(0xFF8B4513); // Braun
  static const Color primaryLightColor = Color(0xFFD2B48C); // Hellbraun
  static const Color primaryDarkColor = Color(0xFF5D2906); // Dunkelbraun

  // Akzentfarben
  static const Color accentColor = Color(0xFF4CAF50); // Grün
  static const Color accentLightColor = Color(0xFF80E27E); // Hellgrün
  static const Color accentDarkColor = Color(0xFF087F23); // Dunkelgrün

  // Schachbrett-Farben
  static const Color lightSquareColor = Color(0xFFF0D9B5); // Helles Beige
  static const Color darkSquareColor = Color(0xFFB58863); // Dunkles Beige
  static const Color selectedSquareColor = Color(0xFFBFD48B); // Hellgrün
  static const Color validMoveColor = Color(0x4082C26E); // Transparentes Grün

  // Text-Farben
  static const Color primaryTextColor = Color(0xFF212121); // Fast Schwarz
  static const Color secondaryTextColor = Color(0xFF757575); // Grau
  static const Color lightTextColor = Color(0xFFFFFFFF); // Weiß

  // Status-Farben
  static const Color successColor = Color(0xFF4CAF50); // Grün
  static const Color errorColor = Color(0xFFF44336); // Rot
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color infoColor = Color(0xFF2196F3); // Blau

  // Schatten
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Color(0x29000000),
      offset: Offset(0, 3),
      blurRadius: 6,
    ),
  ];

  // Abstände
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Rundungen
  static const double defaultBorderRadius = 8.0;
  static const double smallBorderRadius = 4.0;
  static const double largeBorderRadius = 16.0;

  // Animationen
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Schriftgrößen
  static const double smallFontSize = 12.0;
  static const double defaultFontSize = 16.0;
  static const double mediumFontSize = 18.0;
  static const double largeFontSize = 24.0;
  static const double extraLargeFontSize = 32.0;

  // Schriftarten
  static const String defaultFontFamily = 'Roboto';
  static const String titleFontFamily = 'Playfair Display';

  // Erstellt das Haupt-Theme für die App
  static ThemeData getLightTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      primaryColorLight: primaryLightColor,
      primaryColorDark: primaryDarkColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: lightTextColor,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: titleFontFamily,
          fontSize: extraLargeFontSize,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        displayMedium: TextStyle(
          fontFamily: titleFontFamily,
          fontSize: largeFontSize,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        displaySmall: TextStyle(
          fontFamily: titleFontFamily,
          fontSize: mediumFontSize,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: defaultFontFamily,
          fontSize: defaultFontSize,
          color: primaryTextColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: defaultFontFamily,
          fontSize: defaultFontSize,
          color: secondaryTextColor,
        ),
        bodySmall: TextStyle(
          fontFamily: defaultFontFamily,
          fontSize: smallFontSize,
          color: secondaryTextColor,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: smallPadding,
          horizontal: defaultPadding,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: lightTextColor,
          padding: const EdgeInsets.symmetric(
            vertical: smallPadding,
            horizontal: defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(
            vertical: smallPadding,
            horizontal: defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            vertical: smallPadding,
            horizontal: defaultPadding,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        margin: const EdgeInsets.all(smallPadding),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: smallPadding,
          horizontal: defaultPadding,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: primaryLightColor,
        thickness: 1,
        space: defaultPadding,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryDarkColor,
        contentTextStyle: const TextStyle(color: lightTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Erstellt das dunkle Theme für die App
  static ThemeData getDarkTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      primaryColorLight: primaryLightColor,
      primaryColorDark: primaryDarkColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryLightColor,
        secondary: accentLightColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: lightTextColor,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: titleFontFamily,
          fontSize: extraLargeFontSize,
          fontWeight: FontWeight.bold,
          color: lightTextColor,
        ),
        displayMedium: TextStyle(
          fontFamily: titleFontFamily,
          fontSize: largeFontSize,
          fontWeight: FontWeight.bold,
          color: lightTextColor,
        ),
        displaySmall: TextStyle(
          fontFamily: titleFontFamily,
          fontSize: mediumFontSize,
          fontWeight: FontWeight.bold,
          color: lightTextColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: defaultFontFamily,
          fontSize: defaultFontSize,
          color: lightTextColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: defaultFontFamily,
          fontSize: defaultFontSize,
          color: Color(0xFFBBBBBB),
        ),
        bodySmall: TextStyle(
          fontFamily: defaultFontFamily,
          fontSize: smallFontSize,
          color: Color(0xFFBBBBBB),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: smallPadding,
          horizontal: defaultPadding,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLightColor,
          foregroundColor: primaryTextColor,
          padding: const EdgeInsets.symmetric(
            vertical: smallPadding,
            horizontal: defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLightColor,
          side: const BorderSide(color: primaryLightColor),
          padding: const EdgeInsets.symmetric(
            vertical: smallPadding,
            horizontal: defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLightColor,
          padding: const EdgeInsets.symmetric(
            vertical: smallPadding,
            horizontal: defaultPadding,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        margin: const EdgeInsets.all(smallPadding),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: smallPadding,
          horizontal: defaultPadding,
        ),
        fillColor: const Color(0xFF2C2C2C),
        filled: true,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3E3E3E),
        thickness: 1,
        space: defaultPadding,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2C2C2C),
        contentTextStyle: const TextStyle(color: lightTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
