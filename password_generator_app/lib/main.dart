import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'home_page.dart';
import 'lock_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appSettings.load();
  runApp(const PasswordGeneratorApp());
}

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            final accent = appSettings.accent;
            final useSystemDynamic =
                appSettings.useDynamicColor && accent.name == 'auto';
            return MaterialApp(
              title: 'Cipher Generator',
              debugShowCheckedModeBanner: false,
              theme: _resolveTheme(
                Brightness.light,
                lightDynamic,
                useSystemDynamic,
                accent,
              ),
              darkTheme: _resolveTheme(
                Brightness.dark,
                darkDynamic,
                useSystemDynamic,
                accent,
              ),
              themeMode: appSettings.themeMode,
              home: appSettings.lockEnabled && appSettings.isLocked
                  ? const LockScreen()
                  : const PasswordGeneratorHomePage(),
            );
          },
        );
      },
    );
  }

  ThemeData _resolveTheme(
    Brightness brightness,
    ColorScheme? dynamicScheme,
    bool useSystemDynamic,
    AccentColor accent,
  ) {
    if (useSystemDynamic && dynamicScheme != null) {
      return buildAppThemeWithScheme(brightness, dynamicScheme);
    }
    if (accent.name != 'auto') {
      return buildAppThemeWithAccent(brightness, accent);
    }
    return buildAppTheme(brightness);
  }
}