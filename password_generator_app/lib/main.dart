import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';


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
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.dark,
          ),
          themeMode: mode,
          home: PasswordGeneratorHomePage(),
        );
      },
    );
  }
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

    setState(() {
      _generatedPassword = password.join();
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(40),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color.fromRGBO(255, 255, 255, 0.1)
                    : const Color.fromRGBO(0, 0, 0, 0.2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 35,
                    offset: const Offset(0, 15),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Password Generator',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // Will be adjusted by theme later
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password Display
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color.fromRGBO(0, 0, 0, 0.2)
                          : const Color.fromRGBO(255, 255, 255, 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
                      children: [
                        Expanded(
                          child: SelectableText(
                            _generatedPassword,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Will be adjusted by theme later
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white), // Will be adjusted by theme later
                          onPressed: _copyToClipboard,
                          tooltip: 'Copy Password',
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
                        style: const TextStyle(fontSize: 16, color: Colors.white), // Will be adjusted by theme later
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
                        activeColor: const Color(0xFFFF6B6B), // Matches HTML button color
                        inactiveColor: Colors.white.withOpacity(0.3),
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
                  ),
                  _buildOptionRow(
                    context,
                    'Include Uppercase',
                    _useUppercase,
                    (value) => setState(() => _useUppercase = value),
                  ),
                  _buildOptionRow(
                    context,
                    'Include Digits',
                    _useDigits,
                    (value) => setState(() => _useDigits = value),
                  ),
                  _buildOptionRow(
                    context,
                    'Include Special Characters',
                    _useSpecial,
                    (value) => setState(() => _useSpecial = value),
                  ),
                  const SizedBox(height: 20),

                  // Generate Button
                  ElevatedButton(
                    onPressed: _generatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B), // Matches HTML button color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Generate Password'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              children: [
                _buildTopButton(
                  context,
                  themeNotifier.value == ThemeMode.light ? Icons.wb_sunny : Icons.nightlight_round,
                  () {
                    themeNotifier.toggleTheme();
                  },
                ),
                const SizedBox(width: 10),
                _buildTopButton(
                  context,
                  Icons.info_outline,
                  () {
                    _showInfoModal(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(BuildContext context, String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? const Color.fromRGBO(0, 0, 0, 0.1)
            : const Color.fromRGBO(255, 255, 255, 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white), // Will be adjusted by theme later
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF6B6B), // Matches HTML button color
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? const Color.fromRGBO(255, 255, 255, 0.2)
            : const Color.fromRGBO(0, 0, 0, 0.3),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20), // Will be adjusted by theme later
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showInfoModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color.fromRGBO(255, 255, 255, 0.1)
                  : const Color.fromRGBO(0, 0, 0, 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
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
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const Text(
                        'About Cipher Generator',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Modern Password Generator',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Built by Ionut Ciprian Anescu',
                        style: TextStyle(fontSize: 16, color: Colors.white),
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
                        child: const Text(
                          'GitHub Profile: https://github.com/ItIsCiprian',
                          style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Features',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '- Customizable Password Generation: Generate passwords of any length with your choice of character types (lowercase, uppercase, digits, special characters).\n'
                        '- Interactive CLI: A user-friendly command-line interface that guides you through the password generation process.\n'
                        '- Modern Web UI: A beautiful and responsive web interface with interactive controls and a sleek design.\n'
                        '- Secure: Generates strong, random passwords to protect your accounts.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Project Overview',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This project contains two implementations of a random password generator:',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const Text(
                        '\n1. A Flutter application: A cross-platform app that allows you to generate random passwords with customizable options.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const Text(
                        '\n2. A simple web version: A basic HTML and Python-based password generator.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LicensePage()));
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