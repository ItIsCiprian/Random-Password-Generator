import 'package:flutter/material.dart';

/// User-selectable accent colors. `auto` means "use the system's dynamic
/// color palette (Material You) when the platform supports it".
class AccentColor {
  const AccentColor(this.name, this.seedValue);

  final String name;
  final int seedValue;

  Color get seed => Color(seedValue);

  static const List<AccentColor> all = [
    AccentColor('auto', 0xFF6750A4),
    AccentColor('purple', 0xFF6750A4),
    AccentColor('coral', 0xFFE12B2B),
    AccentColor('blue', 0xFF1E5BC8),
    AccentColor('teal', 0xFF00897B),
    AccentColor('green', 0xFF2E7D32),
    AccentColor('amber', 0xFFB26A00),
    AccentColor('pink', 0xFFC2185B),
  ];

  static AccentColor byName(String? name) {
    for (final accent in all) {
      if (accent.name == name) return accent;
    }
    return all.first;
  }
}

ColorScheme _seedScheme(Brightness brightness, AccentColor accent) {
  return ColorScheme.fromSeed(
    seedColor: accent.seed,
    brightness: brightness,
  );
}

ThemeData buildAppTheme(Brightness brightness) {
  final scheme = _seedScheme(brightness, AccentColor.all.first);
  return _themeFromScheme(brightness, scheme);
}

ThemeData buildAppThemeWithAccent(Brightness brightness, AccentColor accent) {
  final scheme = _seedScheme(brightness, accent);
  return _themeFromScheme(brightness, scheme);
}

ThemeData buildAppThemeWithScheme(Brightness brightness, ColorScheme scheme) {
  return _themeFromScheme(brightness, scheme);
}

ThemeData _themeFromScheme(Brightness brightness, ColorScheme scheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF121212)
        : const Color(0xFFF6F5FB),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}