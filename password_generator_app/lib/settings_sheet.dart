import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_settings.dart';
import 'about_page.dart';
import 'theme.dart';

/// Full-screen settings, reachable from the home screen toolbar.
class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _bioAvailable = false;
  bool _testingBio = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await appSettings.canUseBiometrics();
    if (mounted) setState(() => _bioAvailable = available);
  }

  Future<void> _setupPin() async {
    final pin = await _showPinDialog(
      title: 'Set a PIN',
      confirmTitle: 'Confirm PIN',
      existing: appSettings.hasPin,
    );
    if (pin == null || !mounted) return;
    await appSettings.setPin(pin);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN saved.')),
      );
      setState(() {});
    }
  }

  Future<void> _toggleLock(bool value) async {
    if (value) {
      // Enabling lock: require a PIN and/or biometrics. We enable the lock
      // only once a usable method exists (PIN set or biometrics confirmed),
      // otherwise the user would be locked out.
      bool useBio = false;
      if (_bioAvailable) {
        final choice = await _confirmBiometrics();
        if (choice == null) return; // cancelled
        if (choice) useBio = true;
      }

      String? pin;
      if (!useBio) {
        pin = await _showPinDialog(
          title: 'Set a PIN',
          confirmTitle: 'Confirm PIN',
        );
        if (pin == null) return; // cancelled — lock not enabled
      }

      await appSettings.enableLock(biometrics: useBio);
      if (pin != null) await appSettings.setPin(pin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App lock enabled.')),
        );
      }
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Disable app lock?'),
          content: const Text(
            'Your passwords will no longer be protected by a PIN or biometrics.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Disable'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await appSettings.disableLock();
      }
    }
    if (mounted) setState(() {});
  }

  Future<bool?> _confirmBiometrics() async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Use biometric unlock?'),
        content: const Text(
          'Allow unlocking Cipher Generator with your fingerprint or Face ID.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, use PIN'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showPinDialog({
    required String title,
    required String confirmTitle,
    bool existing = false,
  }) {
    final controller = TextEditingController();
    final confirm = TextEditingController();
    String? error;

    return showDialog<String>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          final scheme = Theme.of(context).colorScheme;
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'PIN (6 digits)',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirm,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Repeat PIN',
                    counterText: '',
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error!,
                      style: TextStyle(color: scheme.error, fontSize: 12),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final pin = controller.text;
                  if (pin.length != 6) {
                    setDialogState(() => error = 'PIN must be exactly 6 digits.');
                    return;
                  }
                  if (pin != confirm.text) {
                    setDialogState(() => error = 'PINs do not match.');
                    return;
                  }
                  Navigator.pop(context, pin);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionHeader('Appearance'),
              _buildThemeMode(),
              const SizedBox(height: 12),
              _buildDynamicColor(),
              const SizedBox(height: 12),
              _buildAccentPicker(),
              const SizedBox(height: 24),
              const _SectionHeader('Security'),
              _buildLockToggle(),
              if (appSettings.lockEnabled) ...[
                const SizedBox(height: 12),
                _buildPinRow(),
                if (_bioAvailable) ...[
                  const SizedBox(height: 12),
                  _buildBiometricsRow(),
                ],
              ],
              const SizedBox(height: 24),
              const _SectionHeader('Privacy'),
              _buildAutoClear(),
              const SizedBox(height: 24),
              const _SectionHeader('About'),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Cipher Generator'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showAppAboutDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeMode() {
    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined),
      title: const Text('Theme'),
      subtitle: Text(
        appSettings.themeMode == ThemeMode.system
            ? 'Follow system'
            : appSettings.themeMode == ThemeMode.light
                ? 'Light'
                : 'Dark',
      ),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto),
            label: Text('Auto'),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode),
            label: Text('Light'),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode),
            label: Text('Dark'),
          ),
        ],
        selected: {appSettings.themeMode},
        onSelectionChanged: (selection) {
          appSettings.setThemeMode(selection.first);
        },
      ),
    );
  }

  Widget _buildDynamicColor() {
    return SwitchListTile(
      secondary: const Icon(Icons.palette_outlined),
      title: const Text('Dynamic color'),
      subtitle: const Text('Match your wallpaper where supported'),
      value: appSettings.useDynamicColor,
      onChanged: appSettings.setUseDynamicColor,
    );
  }

  Widget _buildAccentPicker() {
    return ListTile(
      leading: const Icon(Icons.color_lens_outlined),
      title: const Text('Accent color'),
      subtitle: Wrap(
        spacing: 8,
        children: [
          for (final accent in AccentColor.all.where((a) => a.name != 'auto'))
            GestureDetector(
              onTap: () => appSettings.setAccent(accent),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accent.seed,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appSettings.accent == accent
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLockToggle() {
    return SwitchListTile(
      secondary: const Icon(Icons.lock_outline),
      title: const Text('App lock'),
      subtitle: Text(
        appSettings.lockEnabled
            ? 'Protected with ${appSettings.hasPin ? 'PIN' : ''}${appSettings.hasPin && appSettings.biometricsEnabled ? ' + ' : ''}${appSettings.biometricsEnabled ? 'biometrics' : ''}'
            : 'Require a PIN or biometrics to open',
      ),
      value: appSettings.lockEnabled,
      onChanged: _toggleLock,
    );
  }

  Widget _buildPinRow() {
    return ListTile(
      leading: const Icon(Icons.pin_outlined),
      title: const Text('Change PIN'),
      subtitle: const Text('Use numbers on your keypad'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _setupPin,
    );
  }

  Widget _buildBiometricsRow() {
    return SwitchListTile(
      secondary: const Icon(Icons.fingerprint),
      title: const Text('Unlock with biometrics'),
      subtitle: Text(
        _testingBio ? 'Verifying…' : 'Use Face ID, Touch ID, or fingerprint',
      ),
      value: appSettings.biometricsEnabled && !_testingBio,
      onChanged: (value) async {
        if (value) {
          setState(() => _testingBio = true);
          final result = await appSettings.authenticateBiometrics(
            reason: 'Verify your identity to enable biometric unlock',
          );
          if (!mounted) return;
          setState(() => _testingBio = false);
          if (result == AuthResult.granted) {
            await appSettings.setBiometricsEnabled(true);
          } else if (result == AuthResult.unavailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Biometrics are not available.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Biometric verification failed.')),
            );
          }
        } else {
          await appSettings.setBiometricsEnabled(false);
        }
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildAutoClear() {
    return SwitchListTile(
      secondary: const Icon(Icons.content_copy),
      title: const Text('Auto-clear clipboard'),
      subtitle: const Text('Erase copied passwords after 60 seconds'),
      value: appSettings.autoClearClipboard,
      onChanged: (value) {
        appSettings.setAutoClearClipboard(value);
        HapticFeedback.selectionClick();
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}