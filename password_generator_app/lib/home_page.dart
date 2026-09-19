import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';
import 'about_page.dart';
import 'password_core.dart';
import 'settings_sheet.dart';

class PasswordGeneratorHomePage extends StatefulWidget {
  const PasswordGeneratorHomePage({super.key});

  @override
  State<PasswordGeneratorHomePage> createState() =>
      _PasswordGeneratorHomePageState();
}

class _PasswordGeneratorHomePageState extends State<PasswordGeneratorHomePage>
    with WidgetsBindingObserver {
  // Character-mode options
  double _passwordLength = 12;
  bool _useLowercase = true;
  bool _useUppercase = true;
  bool _useDigits = true;
  bool _useSpecial = true;
  bool _excludeAmbiguous = false;

  // Passphrase-mode options
  double _wordCount = 6;
  String _separator = '-';
  bool _includeNumber = false;

  PasswordMode _mode = PasswordMode.characters;

  String _generatedPassword = '';
  List<String> _passwordHistory = [];
  static const String _historyKey = 'password_history';
  static const int _maxHistorySize = 50;

  bool _obscured = true;
  bool _wasBackgrounded = false;

  Timer? _clipboardClearTimer;
  String? _lastCopied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPasswordHistory();
    _generate(recordHistory: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clipboardClearTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Hide stale secrets and re-lock when the app leaves the foreground.
      _wasBackgrounded = !_obscured;
      if (_wasBackgrounded) setState(() => _obscured = true);
      if (appSettings.lockEnabled) appSettings.lock();
    } else if (state == AppLifecycleState.resumed) {
      if (_wasBackgrounded) {
        _wasBackgrounded = false;
        setState(() => _obscured = false);
      }
    }
  }

  // ---- History ------------------------------------------------------------

  Future<void> _loadPasswordHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw == null) return;
      final decoded = (jsonDecode(raw) as List)
          .whereType<String>()
          .take(_maxHistorySize)
          .toList();
      if (mounted) setState(() => _passwordHistory = decoded);
    } catch (_) {}
  }

  Future<void> _savePasswordHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonEncode(_passwordHistory));
    } catch (_) {}
  }

  void _addToHistory(String password) {
    setState(() {
      _passwordHistory.remove(password);
      _passwordHistory.insert(0, password);
      if (_passwordHistory.length > _maxHistorySize) {
        _passwordHistory = _passwordHistory.sublist(0, _maxHistorySize);
      }
    });
    _savePasswordHistory();
  }

  // ---- Generation ---------------------------------------------------------

  void _generate({bool recordHistory = true}) {
    HapticFeedback.lightImpact();
    final String newPassword;
    final bool valid;

    if (_mode == PasswordMode.characters) {
      if (!_useLowercase && !_useUppercase && !_useDigits && !_useSpecial) {
        setState(() {
          _generatedPassword = 'Select at least one character type.';
        });
        return;
      }
      valid = true;
      newPassword = generateCharacters(
        length: _passwordLength.round(),
        useLowercase: _useLowercase,
        useUppercase: _useUppercase,
        useDigits: _useDigits,
        useSpecial: _useSpecial,
        excludeAmbiguous: _excludeAmbiguous,
      );
    } else {
      valid = true;
      newPassword = generatePassphrase(
        wordCount: _wordCount.round(),
        separator: _separator,
        includeNumber: _includeNumber,
      );
    }

    if (!valid) return;
    setState(() {
      _generatedPassword = newPassword;
      _obscured = true;
    });
    if (recordHistory) _addToHistory(newPassword);
  }

  // ---- Entropy / strength -------------------------------------------------

  double _currentEntropy() {
    if (_mode == PasswordMode.characters) {
      final pool = buildCharacterPool(
        useLowercase: _useLowercase,
        useUppercase: _useUppercase,
        useDigits: _useDigits,
        useSpecial: _useSpecial,
        excludeAmbiguous: _excludeAmbiguous,
      );
      if (pool.isEmpty) return 0;
      return characterEntropyBits(
        length: _passwordLength.round(),
        poolSize: pool.length,
      );
    }
    return passphraseEntropyBits(
      wordCount: _wordCount.round(),
      includeNumber: _includeNumber,
    );
  }

  double get _currentScore => strengthScoreForBits(_currentEntropy());
  PasswordStrength get _currentStrength => strengthForBits(_currentEntropy());

  // ---- Clipboard ----------------------------------------------------------

  Future<void> _copyToClipboard(String password) async {
    if (password.isEmpty || password.startsWith('Select at least')) return;
    await Clipboard.setData(ClipboardData(text: password));
    HapticFeedback.selectionClick();
    _lastCopied = password;
    _clipboardClearTimer?.cancel();
    if (appSettings.autoClearClipboard) {
      _clipboardClearTimer = Timer(const Duration(seconds: 60), () async {
        try {
          final clip = await Clipboard.getData(Clipboard.kTextPlain);
          if (clip?.text == _lastCopied) {
            await Clipboard.setData(const ClipboardData(text: ''));
          }
        } catch (_) {}
      });
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appSettings.autoClearClipboard
            ? 'Copied — clipboard clears in 60s'
            : 'Password copied to clipboard!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ---- UI -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;
    final sub = scheme.onSurfaceVariant;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showPasswordPlaceholder = _generatedPassword.isEmpty;
    final displayText = showPasswordPlaceholder
        ? 'Generate a password'
        : (_obscured ? _mask(_generatedPassword) : _generatedPassword);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _buildHeader(scheme),
                      const SizedBox(height: 16),
                      SegmentedButton<PasswordMode>(
                        segments: const [
                          ButtonSegment(
                            value: PasswordMode.characters,
                            icon: Icon(Icons.shuffle),
                            label: Text('Characters'),
                          ),
                          ButtonSegment(
                            value: PasswordMode.passphrase,
                            icon: Icon(Icons.abc),
                            label: Text('Passphrase'),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (selection) {
                          setState(() => _mode = selection.first);
                          _generate();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordCard(
                        scheme,
                        onSurface,
                        sub,
                        isDark,
                        displayText,
                      ),
                      const SizedBox(height: 16),
                      if (_mode == PasswordMode.characters)
                        _buildCharacterOptions(scheme, onSurface, sub, isDark)
                      else
                        _buildPassphraseOptions(scheme, onSurface, sub, isDark),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _generate,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Generate'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (appSettings.lockEnabled &&
                          !appSettings.biometricsEnabled) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Tip: unlock with your PIN each time you open the app.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: sub),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (_passwordHistory.isNotEmpty)
                        _buildHistory(scheme, onSurface, sub, isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme scheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          'Cipher Generator',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        if (appSettings.lockEnabled)
          IconButton(
            tooltip: 'Lock now',
            icon: const Icon(Icons.lock_outline),
            onPressed: () => appSettings.lock(),
          ),
        IconButton(
          tooltip: appSettings.themeMode == ThemeMode.dark
              ? 'Switch to light mode'
              : 'Switch to dark mode',
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          onPressed: () {
            appSettings.setThemeMode(
              appSettings.themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark,
            );
          },
        ),
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SettingsSheet(),
              ),
            );
          },
        ),
        IconButton(
          tooltip: 'About',
          icon: const Icon(Icons.info_outline),
          onPressed: () => showAppAboutDialog(context),
        ),
      ],
    );
  }

  Widget _buildPasswordCard(
    ColorScheme scheme,
    Color onSurface,
    Color sub,
    bool isDark,
    String displayText,
  ) {
    final strengthColor = _strengthColor(_currentStrength, scheme);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: SelectableText(
                      displayText,
                      key: ValueKey(displayText),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: _generatedPassword.isEmpty
                            ? sub
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: _obscured ? 'Show password' : 'Hide password',
                  icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscured = !_obscured),
                ),
                IconButton(
                  tooltip: 'Copy',
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_generatedPassword),
                ),
                IconButton(
                  tooltip: 'Generate new',
                  icon: const Icon(Icons.refresh),
                  onPressed: _generate,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Strength: ${strengthLabel(_currentStrength)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: strengthColor),
                ),
                Text(
                  '${_currentEntropy().round()} bits',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: sub),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _currentScore),
                duration: const Duration(milliseconds: 400),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: strengthColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Estimated offline attack time: ${crackTimeLabel(_currentEntropy())}',
              style: TextStyle(fontSize: 12, color: sub),
            ),
          ],
        ),
      ),
    );
  }

  Color _strengthColor(PasswordStrength strength, ColorScheme scheme) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return Colors.red;
      case PasswordStrength.weak:
        return Colors.orange;
      case PasswordStrength.fair:
        return Colors.amber.shade700;
      case PasswordStrength.good:
        return Colors.lightGreen;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  String _mask(String password) {
    if (password.length <= 1) return password;
    return '•' * password.length;
  }

  // ---- Options cards ------------------------------------------------------

  Widget _buildCharacterOptions(
    ColorScheme scheme,
    Color onSurface,
    Color sub,
    bool isDark,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Options',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Length: ${_passwordLength.round()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Text('more = stronger', style: TextStyle(fontSize: 12, color: sub)),
              ],
            ),
            Slider(
              value: _passwordLength,
              min: 4,
              max: 64,
              divisions: 60,
              label: _passwordLength.round().toString(),
              onChanged: (value) {
                setState(() => _passwordLength = value);
                _generate(recordHistory: false);
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip('a-z', _useLowercase, (v) => _useLowercase = v),
                _buildChip('A-Z', _useUppercase, (v) => _useUppercase = v),
                _buildChip('0-9', _useDigits, (v) => _useDigits = v),
                _buildChip('!@#', _useSpecial, (v) => _useSpecial = v),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Exclude ambiguous characters'),
              subtitle: const Text('Skip characters like 0, O, 1, l, I'),
              value: _excludeAmbiguous,
              onChanged: (value) {
                setState(() => _excludeAmbiguous = value);
                _generate(recordHistory: false);
              },
              secondary: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool selected, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) {
        setState(() => onChanged(value));
        _generate(recordHistory: false);
      },
    );
  }

  Widget _buildPassphraseOptions(
    ColorScheme scheme,
    Color onSurface,
    Color sub,
    bool isDark,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Options',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Words: ${_wordCount.round()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Text('time to crack: ${crackTimeLabel(_currentEntropy())}',
                    style: TextStyle(fontSize: 12, color: sub)),
              ],
            ),
            Slider(
              value: _wordCount,
              min: 3,
              max: 10,
              divisions: 7,
              label: _wordCount.round().toString(),
              onChanged: (value) {
                setState(() => _wordCount = value);
                _generate(recordHistory: false);
              },
            ),
            const SizedBox(height: 8),
            Text('Separator', style: TextStyle(fontSize: 13, color: sub)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final sep in ['-', '_', '.', 'space'])
                  _buildChip(
                    sep == 'space' ? '␣' : sep,
                    _separator == (sep == 'space' ? ' ' : sep),
                    (v) {
                      _separator = sep == 'space' ? ' ' : sep;
                      setState(() {});
                      _generate(recordHistory: false);
                    },
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Add a number'),
              subtitle: const Text('Boosts entropy with one more character'),
              value: _includeNumber,
              onChanged: (value) {
                setState(() => _includeNumber = value);
                _generate(recordHistory: false);
              },
              secondary: const Icon(Icons.tag),
            ),
          ],
        ),
      ),
    );
  }

  // ---- History ------------------------------------------------------------

  Widget _buildHistory(
    ColorScheme scheme,
    Color onSurface,
    Color sub,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Passwords',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() => _passwordHistory.clear());
                _savePasswordHistory();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        for (final password in _passwordHistory.take(10))
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _obscured ? _mask(password) : password,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy',
                    onPressed: () => _copyToClipboard(password),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}