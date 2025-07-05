import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(PasswordGeneratorApp());
}

class PasswordGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Password Generator',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PasswordGeneratorHomePage(),
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
    if (_useSpecial) charSets.add('!@#$%^&*()_+-=[]{}|;:,.<>?');

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

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modern Password Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Password Display
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _generatedPassword,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),

            // Length Slider
            Text('Password Length: ${_passwordLength.round()}', style: TextStyle(fontSize: 16)),
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
            ),
            SizedBox(height: 24),

            // Character Type Switches
            SwitchListTile(
              title: Text('Include Lowercase'),
              value: _useLowercase,
              onChanged: (value) => setState(() => _useLowercase = value),
            ),
            SwitchListTile(
              title: Text('Include Uppercase'),
              value: _useUppercase,
              onChanged: (value) => setState(() => _useUppercase = value),
            ),
            SwitchListTile(
              title: Text('Include Digits'),
              value: _useDigits,
              onChanged: (value) => setState(() => _useDigits = value),
            ),
            SwitchListTile(
              title: Text('Include Special Characters'),
              value: _useSpecial,
              onChanged: (value) => setState(() => _useSpecial = value),
            ),
            SizedBox(height: 32),

            // Generate Button
            ElevatedButton(
              onPressed: _generatePassword,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Generate Password', style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}