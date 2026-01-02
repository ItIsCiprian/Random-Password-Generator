import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(PasswordGeneratorApp());
}

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier(ThemeMode value) : super(value);

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeNotifier = ThemeNotifier(ThemeMode.system);

class PasswordGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Cipher Generator',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.light,
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              secondary: const Color(0xFFFF6B6B),
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple,
              secondary: const Color(0xFFFF6B6B),
              surface: const Color(0xFF121212),
              onSurface: Colors.white,
            ),
          ),
          themeMode: mode,
          home: PasswordGeneratorHomePage(),
        );
      },
    );
  }
}

enum PasswordStrength {
  veryWeak,
  weak,
  fair,
  good,
  strong,
}

class PasswordGeneratorHomePage extends StatefulWidget {
  @override
  _PasswordGeneratorHomePageState createState() => _PasswordGeneratorHomePageState();
}

class _PasswordGeneratorHomePageState extends State<PasswordGeneratorHomePage> {
  double _passwordLength = 12.0;
  bool _useLowercase = true;
  bool _useUppercase = true;
  bool _useDigits = true;
  bool _useSpecial = true;
  String _generatedPassword = '';
  List<String> _passwordHistory = [];
  static const String _historyKey = 'password_history';
  static const int _maxHistorySize = 50;

  @override
  void initState() {
    super.initState();
    _generatePassword();
    _loadPasswordHistory();
  }

  Future<void> _loadPasswordHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      setState(() {
        _passwordHistory = List<String>.from(jsonDecode(historyJson));
      });
    }
  }

  Future<void> _savePasswordHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(_passwordHistory));
  }

  void _addToHistory(String password) {
    setState(() {
      // Remove if already exists
      _passwordHistory.remove(password);
      // Add to beginning
      _passwordHistory.insert(0, password);
      // Limit history size
      if (_passwordHistory.length > _maxHistorySize) {
        _passwordHistory = _passwordHistory.sublist(0, _maxHistorySize);
      }
    });
    _savePasswordHistory();
  }

  PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.veryWeak;
    
    int score = 0;
    
    // Length score
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    if (password.length >= 16) score += 1;
    
    // Character variety
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int varietyCount = [hasLower, hasUpper, hasDigit, hasSpecial].where((b) => b).length;
    score += varietyCount - 1; // -1 because at least one is required
    
    if (score <= 1) return PasswordStrength.veryWeak;
    if (score == 2) return PasswordStrength.weak;
    if (score == 3) return PasswordStrength.fair;
    if (score == 4) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  String _getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 'Very Weak';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  Color _getStrengthColor(PasswordStrength strength, bool isDark) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return Colors.red;
      case PasswordStrength.weak:
        return Colors.orange;
      case PasswordStrength.fair:
        return Colors.yellow.shade700;
      case PasswordStrength.good:
        return Colors.lightGreen;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  double _getStrengthValue(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 0.2;
      case PasswordStrength.weak:
        return 0.4;
      case PasswordStrength.fair:
        return 0.6;
      case PasswordStrength.good:
        return 0.8;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  void _generatePassword() {
    final random = Random.secure();
    final List<String> charSets = [];
    if (_useLowercase) charSets.add('abcdefghijklmnopqrstuvwxyz');
    if (_useUppercase) charSets.add('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    if (_useDigits) charSets.add('0123456789');
    if (_useSpecial) charSets.add('!@#\$%^&*()_+-=[]{}|;:,.<>?');

    if (charSets.isEmpty) {
      setState(() {
        _generatedPassword = 'Select at least one character type.';
      });
      return;
    }

    List<String> password = [];
    // Ensure at least one character from each selected set
    charSets.forEach((set) {
      password.add(set[random.nextInt(set.length)]);
    });

    // Fill the rest of the password
    final allChars = charSets.join();
    for (int i = password.length; i < _passwordLength; i++) {
      password.add(allChars[random.nextInt(allChars.length)]);
    }

    // Shuffle the password
    password.shuffle(random);

    final newPassword = password.join();
    setState(() {
      _generatedPassword = newPassword;
    });
    _addToHistory(newPassword);
  }

  void _copyToClipboard(String password) {
    if (password.isNotEmpty && password != 'Select at least one character type.') {
      Clipboard.setData(ClipboardData(text: password));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password copied to clipboard!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strength = _calculateStrength(_generatedPassword);
    final strengthColor = _getStrengthColor(strength, isDark);
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? const Color.fromRGBO(30, 30, 30, 0.9)
                        : const Color.fromRGBO(255, 255, 255, 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                        blurRadius: 35,
                        offset: const Offset(0, 15),
                      ),
                    ],
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Password Generator',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Password Display
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color.fromRGBO(20, 20, 20, 0.8)
                              : const Color.fromRGBO(240, 240, 250, 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: strengthColor.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    _generatedPassword,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: strengthColor,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy, color: strengthColor),
                                  onPressed: () => _copyToClipboard(_generatedPassword),
                                  tooltip: 'Copy Password',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Strength Meter
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Strength: ${_getStrengthText(strength)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '${(_getStrengthValue(strength) * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: strengthColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _getStrengthValue(strength),
                                    backgroundColor: isDark 
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Length Slider
                      Column(
                        children: [
                          Text(
                            'Password Length: ${_passwordLength.round()}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Slider(
                            value: _passwordLength,
                            min: 4,
                            max: 32,
                            divisions: 28,
                            label: _passwordLength.round().toString(),
                            onChanged: (value) {
                              setState(() {
                                _passwordLength = value;
                              });
                            },
                            activeColor: const Color(0xFFFF6B6B),
                            inactiveColor: isDark 
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Character Type Switches
                      _buildOptionRow(
                        context,
                        'Include Lowercase',
                        _useLowercase,
                        (value) => setState(() => _useLowercase = value),
                        isDark,
                      ),
                      _buildOptionRow(
                        context,
                        'Include Uppercase',
                        _useUppercase,
                        (value) => setState(() => _useUppercase = value),
                        isDark,
                      ),
                      _buildOptionRow(
                        context,
                        'Include Digits',
                        _useDigits,
                        (value) => setState(() => _useDigits = value),
                        isDark,
                      ),
                      _buildOptionRow(
                        context,
                        'Include Special Characters',
                        _useSpecial,
                        (value) => setState(() => _useSpecial = value),
                        isDark,
                      ),
                      const SizedBox(height: 20),

                      // Generate Button
                      ElevatedButton(
                        onPressed: _generatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Generate Password'),
                      ),
                      const SizedBox(height: 20),

                      // Password History Section
                      if (_passwordHistory.isNotEmpty) ...[
                        Divider(
                          color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Passwords',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _passwordHistory.clear();
                                });
                                _savePasswordHistory();
                              },
                              child: Text(
                                'Clear',
                                style: TextStyle(color: const Color(0xFFFF6B6B)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ..._passwordHistory.take(10).map((password) {
                          final pwdStrength = _calculateStrength(password);
                          final pwdColor = _getStrengthColor(pwdStrength, isDark);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color.fromRGBO(20, 20, 20, 0.6)
                                  : const Color.fromRGBO(240, 240, 250, 0.6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: pwdColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    password,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'monospace',
                                      color: pwdColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy, size: 18, color: pwdColor),
                                  onPressed: () => _copyToClipboard(password),
                                  tooltip: 'Copy',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Top buttons - Better placement for mobile
            Positioned(
              top: 10,
              right: 10,
              child: SafeArea(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTopButton(
                      context,
                      themeNotifier.value == ThemeMode.light ? Icons.wb_sunny : Icons.nightlight_round,
                      () {
                        themeNotifier.toggleTheme();
                      },
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildTopButton(
                      context,
                      Icons.info_outline,
                      () {
                        _showInfoModal(context);
                      },
                      isDark,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color.fromRGBO(20, 20, 20, 0.5)
            : const Color.fromRGBO(240, 240, 250, 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(BuildContext context, IconData icon, VoidCallback onPressed, bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? const Color.fromRGBO(30, 30, 30, 0.9)
            : const Color.fromRGBO(255, 255, 255, 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: 20,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showInfoModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color.fromRGBO(30, 30, 30, 0.95)
                  : const Color.fromRGBO(255, 255, 255, 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Text(
                        'About Cipher Generator',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Modern Password Generator',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Built by Ionut Ciprian Anescu',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          const url = 'https://github.com/ItIsCiprian';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not launch GitHub profile.')),
                            );
                          }
                        },
                        child: Text(
                          'GitHub Profile: https://github.com/ItIsCiprian',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '- Customizable Password Generation: Generate passwords of any length with your choice of character types (lowercase, uppercase, digits, special characters).\n'
                        '- Password Strength Meter: Visual indicator showing the strength of your generated password.\n'
                        '- Password History: Keep track of recently generated passwords for easy access.\n'
                        '- Secure: Generates strong, random passwords to protect your accounts.\n'
                        '- Modern UI: Beautiful and responsive interface with light/dark mode support.',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Project Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'This project contains two implementations of a random password generator:',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Text(
                        '\n1. A Flutter application: A cross-platform app that allows you to generate random passwords with customizable options.',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Text(
                        '\n2. A simple web version: A basic HTML and Python-based password generator.',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LicensePage(),
                            ),
                          );
                        },
                        child: const Text('View License'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LicensePage extends StatelessWidget {
  const LicensePage({Key? key}) : super(key: key);

  Future<String> _loadLicense() async {
    return await rootBundle.loadString('LICENSE');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('License'),
      ),
      body: FutureBuilder<String>(
        future: _loadLicense(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(snapshot.data!),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
