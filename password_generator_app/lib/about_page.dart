import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows the "About" dialog describing the app.
void showAppAboutDialog(BuildContext context) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  final sub = Theme.of(context).colorScheme.onSurfaceVariant;

  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Text(
              'About Cipher Generator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text('Modern Password Generator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface)),
            const SizedBox(height: 6),
            Text(
              'Built by Ionut Ciprian Anescu',
              style: TextStyle(fontSize: 14, color: sub),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                const url = 'https://github.com/ItIsCiprian';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
              child: Text(
                'GitHub Profile: https://github.com/ItIsCiprian',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
            const SizedBox(height: 8),
            _bullet(context, '- Customizable character and passphrase generation.'),
            _bullet(context, '- Live strength meter with entropy and time-to-crack estimates.'),
            _bullet(context, '- Facial recognition / fingerprint / PIN app lock.'),
            _bullet(context, '- Password history with one-tap copy.'),
            _bullet(context, '- Privacy tools: clipboard auto-clear and hide-on-background.'),
            _bullet(context, '- Modern Material 3 interface with light/dark mode.'),
            const SizedBox(height: 20),
            Text('Project Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
            const SizedBox(height: 8),
            _bullet(context, 'A cross-platform Flutter application for generating strong, random passwords.'),
            _bullet(context, 'Companion web version lives at https://github.com/ItIsCiprian.'),
            const SizedBox(height: 20),
            Center(
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const LicensePage()),
                ),
                child: const Text('View License'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _bullet(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      '• $text',
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  Future<String> _loadLicense() async {
    return rootBundle.loadString('LICENSE');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('License')),
      body: FutureBuilder<String>(
        future: _loadLicense(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(snapshot.data!),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}