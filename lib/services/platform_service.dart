import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Hilfsdienst für plattformspezifische Anpassungen.
class PlatformService {
  /// Überprüft, ob die App auf iOS läuft.
  static bool isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  /// Überprüft, ob die App auf Android läuft.
  static bool isAndroid(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.android;
  }

  /// Passt die Statusleiste an die aktuelle Plattform an.
  static void setStatusBarStyle({required bool darkMode}) {
    SystemChrome.setSystemUIOverlayStyle(
      darkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
            ),
    );
  }

  /// Passt die Orientierung an die aktuelle Plattform an.
  static void setPreferredOrientations({required bool allowLandscape}) {
    if (allowLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  /// Gibt plattformspezifische Anpassungen für Widgets zurück.
  static EdgeInsets getSafePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Gibt plattformspezifische Anpassungen für die Tastatur zurück.
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Gibt plattformspezifische Anpassungen für die Schriftgröße zurück.
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }
}
