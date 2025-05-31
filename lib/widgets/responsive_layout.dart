import 'package:flutter/material.dart';
import '../services/platform_service.dart';

/// Widget, das plattformspezifische Anpassungen für verschiedene Geräte vornimmt.
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final bool allowLandscape;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.allowLandscape = true,
  });

  @override
  Widget build(BuildContext context) {
    // Setze die bevorzugten Orientierungen
    PlatformService.setPreferredOrientations(allowLandscape: allowLandscape);

    // Setze die Statusleistenfarbe basierend auf dem aktuellen Theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    PlatformService.setStatusBarStyle(darkMode: isDarkMode);

    // Berücksichtige die Safe Area für verschiedene Geräte
    return SafeArea(
      child: child,
    );
  }
}
