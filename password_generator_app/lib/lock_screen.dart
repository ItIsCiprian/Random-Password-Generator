import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_settings.dart';

/// Blurred full-screen lock shown whenever the app lock is enabled and the
/// user has not unlocked yet.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _errorText = '';
  bool _bioTried = false;

  static const int _pinLength = 6;

  @override
  void initState() {
    super.initState();
    // Auto prompt for biometrics shortly after the frame is laid out.
    if (appSettings.biometricsEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometrics());
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometrics() async {
    if (_bioTried) return;
    setState(() => _bioTried = true);
    final result = await appSettings.authenticateBiometrics();
    if (!mounted) return;
    if (result == AuthResult.granted) {
      appSettings.forceUnlockFromPin();
    } else if (result == AuthResult.unavailable) {
      setState(() => _errorText = 'Biometrics are not available. Use your PIN.');
      HapticFeedback.vibrate();
    }
  }

  Future<void> _submitPin() async {
    FocusScope.of(context).unfocus();
    final pin = _pinController.text;
    if (pin.length < _pinLength) {
      setState(() => _errorText = 'PIN must be $_pinLength digits.');
      return;
    }
    final error = await appSettings.verifyPin(pin);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _errorText = error;
        _pinController.clear();
      });
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 44,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cipher Generator',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your PIN to continue',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    if (appSettings.biometricsEnabled) ...[
                      FilledButton.tonalIcon(
                        onPressed: _tryBiometrics,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Unlock with biometrics'),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (appSettings.hasPin) ...[
                      TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: _pinLength,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, letterSpacing: 8),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _submitPin(),
                        onChanged: (_) {
                          if (_pinController.text.length == _pinLength) {
                            _submitPin();
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_errorText.isNotEmpty)
                        Text(
                          _errorText,
                          style: TextStyle(color: scheme.error, fontSize: 13),
                        )
                      else
                        const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _submitPin,
                          child: const Text('Unlock'),
                        ),
                      ),
                    ] else if (!appSettings.biometricsEnabled) ...[
                      Text(
                        'You have not set up a PIN. Reset the app lock in Settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.error),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}