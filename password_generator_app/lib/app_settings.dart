import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';

/// Outcome of an unlock attempt.
enum AuthResult { granted, grantedWithoutBiometrics, denied, unavailable }

/// Single, shared instance of app settings and the lock service.
final appSettings = AppSettings._();

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static const _prefsThemeMode = 'theme_mode';
  static const _prefsAccent = 'accent_color';
  static const _prefsUseDynamicColor = 'use_dynamic_color';
  static const _prefsLockEnabled = 'lock_enabled';
  static const _prefsBiometricsEnabled = 'biometrics_enabled';
  static const _prefsAutoClearClipboard = 'auto_clear_clipboard';

  static const _lockHasPin = 'app_lock_has_pin';
  static const _lockPinSalt = 'app_lock_pin_salt';
  static const _lockPinHash = 'app_lock_pin_hash';

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ThemeMode _themeMode = ThemeMode.system;
  AccentColor _accent = AccentColor.all.first;
  bool _useDynamicColor = true;
  bool _lockEnabled = false;
  bool _biometricsEnabled = false;
  bool _autoClearClipboard = false;
  bool _locked = false;
  bool _hasPin = false;

  ThemeMode get themeMode => _themeMode;
  AccentColor get accent => _accent;
  bool get useDynamicColor => _useDynamicColor;
  bool get lockEnabled => _lockEnabled;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get autoClearClipboard => _autoClearClipboard;
  bool get isLocked => _locked;
  bool get hasPin => _hasPin;
  bool get lockConfigured => _hasPin || _biometricsEnabled;

  /// Load persisted settings. Safe to call before runApp; never throws.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeMode = _parseThemeMode(prefs.getString(_prefsThemeMode));
      _accent = AccentColor.byName(prefs.getString(_prefsAccent));
      _useDynamicColor = prefs.getBool(_prefsUseDynamicColor) ?? true;
      _lockEnabled = prefs.getBool(_prefsLockEnabled) ?? false;
      _biometricsEnabled = prefs.getBool(_prefsBiometricsEnabled) ?? false;
      _autoClearClipboard = prefs.getBool(_prefsAutoClearClipboard) ?? false;
      _hasPin = await _read(_lockHasPin) == 'true';
      _locked = _lockEnabled;
      notifyListeners();
    } catch (_) {
      // Keep defaults when storage is unavailable (e.g. running in tests).
    }
  }

  ThemeMode _parseThemeMode(String? raw) {
    for (final mode in ThemeMode.values) {
      if (mode.name == raw) return mode;
    }
    return ThemeMode.system;
  }

  Future<String?> _read(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _save(_prefsThemeMode, mode.name);
  }

  Future<void> setAccent(AccentColor accent) async {
    _accent = accent;
    notifyListeners();
    await _save(_prefsAccent, accent.name);
  }

  Future<void> setUseDynamicColor(bool enabled) async {
    _useDynamicColor = enabled;
    notifyListeners();
    await _save(_prefsUseDynamicColor, enabled);
  }

  Future<void> setAutoClearClipboard(bool enabled) async {
    _autoClearClipboard = enabled;
    notifyListeners();
    await _save(_prefsAutoClearClipboard, enabled);
  }

  Future<void> _save(String key, Object value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else {
        await prefs.setString(key, value.toString());
      }
    } catch (_) {}
  }

  // ---- Biometrics ---------------------------------------------------------

  /// Returns true when device biometrics (Face ID / fingerprint) are
  /// available and authorized.
  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<AuthResult> authenticateBiometrics({String? reason}) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason:
            reason ?? 'Unlock Cipher Generator to view your passwords',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (ok && !_biometricsEnabled) {
        return AuthResult.grantedWithoutBiometrics;
      }
      return ok ? AuthResult.granted : AuthResult.denied;
    } on PlatformException {
      return AuthResult.unavailable;
    }
  }

  // ---- Lock service -------------------------------------------------------

  void lock() {
    if (!_lockEnabled) return;
    _locked = true;
    notifyListeners();
  }

  void _unlock() {
    _locked = false;
    notifyListeners();
  }

  Future<void> enableLock({required bool biometrics}) async {
    _lockEnabled = true;
    if (biometrics) _biometricsEnabled = true;
    _locked = true;
    notifyListeners();
    await _save(_prefsLockEnabled, true);
    if (biometrics) await _save(_prefsBiometricsEnabled, true);
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    _biometricsEnabled = enabled;
    notifyListeners();
    await _save(_prefsBiometricsEnabled, enabled);
  }

  Future<void> disableLock() async {
    _lockEnabled = false;
    _biometricsEnabled = false;
    _locked = false;
    notifyListeners();
    await _save(_prefsLockEnabled, false);
    await _save(_prefsBiometricsEnabled, false);
    await _write(_lockHasPin, 'false');
    await _secureStorage.delete(key: _lockPinSalt).catchError((_) => null);
    await _secureStorage.delete(key: _lockPinHash).catchError((_) => null);
  }

  /// Store a new PIN (hashing it with a random salt).
  Future<void> setPin(String pin) async {
    final salt = _randomString(24);
    final hash = _hashPin(pin, salt);
    await _write(_lockHasPin, 'true');
    await _write(_lockPinSalt, salt);
    await _write(_lockPinHash, hash);
    _hasPin = true;
    notifyListeners();
  }

  /// Returns null when the PIN is correct, otherwise an error message.
  Future<String?> verifyPin(String pin) async {
    final salt = await _read(_lockPinSalt);
    final expected = await _read(_lockPinHash);
    if (salt == null || expected == null) return 'No PIN is set yet.';
    if (_hashPin(pin, salt) != expected) return 'Incorrect PIN. Try again.';
    _unlock();
    return null;
  }

  /// Try to unlock. Returns true when the app should be unlocked.
  Future<AuthResult> tryUnlock() async {
    if (_biometricsEnabled) {
      final result = await authenticateBiometrics();
      if (result == AuthResult.granted) {
        _unlock();
        return AuthResult.granted;
      }
      // Fall through: user can also use a PIN when configured.
    }
    if (!_hasPin) {
      return _biometricsEnabled ? AuthResult.denied : AuthResult.unavailable;
    }
    return AuthResult.denied;
  }

  void forceUnlockFromPin() => _unlock();

  String _hashPin(String pin, String salt) {
    var bytes = utf8.encode('$salt::$pin');
    var digest = sha256.convert(bytes).bytes;
    for (var i = 0; i < 5000; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64.encode(digest);
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
}