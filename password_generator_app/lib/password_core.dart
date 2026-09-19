import 'dart:math';

import 'word_list.dart';

enum PasswordMode { characters, passphrase }

const String kLowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
const String kUppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const String kDigitChars = '0123456789';
const String kSpecialChars = r'!@#$%^&*()_+-=[]{}|;:,.<>?';
// Characters that are easy to misread (0/O, 1/l/I).
const String kAmbiguousChars = '0Oo1lI';

double _log2(double x) => log(x) / ln2;

/// Estimates for an offline attack using a high-end GPU rig.
const double kOfflineAttackRatePerSecond = 1e10;

enum PasswordStrength { veryWeak, weak, fair, good, strong }

String strengthLabel(PasswordStrength value) {
  switch (value) {
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

bool hasLowercase(String s) => s.contains(RegExp(r'[a-z]'));
bool hasUppercase(String s) => s.contains(RegExp(r'[A-Z]'));
bool hasDigit(String s) => s.contains(RegExp(r'[0-9]'));
bool hasSpecial(String s) => s.contains(RegExp(r'[^a-zA-Z0-9]'));

double strengthScoreForBits(double bits) {
  if (bits < 28) return 0.2;
  if (bits < 45) return 0.4;
  if (bits < 60) return 0.6;
  if (bits < 75) return 0.8;
  return 1.0;
}

PasswordStrength strengthForBits(double bits) {
  if (bits < 28) return PasswordStrength.veryWeak;
  if (bits < 45) return PasswordStrength.weak;
  if (bits < 60) return PasswordStrength.fair;
  if (bits < 75) return PasswordStrength.good;
  return PasswordStrength.strong;
}

double strengthScoreForPassword(String password) {
  if (password.isEmpty) return 0;
  return min(strengthScoreForBits(entropyBitsOf(password)), 1.0);
}

PasswordStrength strengthOfPassword(String password) {
  return strengthForBits(entropyBitsOf(password));
}

/// Estimate the entropy (in bits) of an already-generated password by
/// treating each character as one of the 95 printable ASCII characters.
double entropyBitsOf(String password) {
  return password.length * _log2(95);
}

/// Entropy of a randomly generated password of a given length and pool size.
double characterEntropyBits({required int length, required int poolSize}) {
  if (length <= 0 || poolSize <= 0) return 0;
  return length * _log2(poolSize.toDouble());
}

/// Entropy of a passphrase made of [wordCount] words with optional appended
/// number.
double passphraseEntropyBits({
  required int wordCount,
  required bool includeNumber,
}) {
  double bits = wordCount * _log2(kPassphraseWords.length.toDouble());
  if (includeNumber) bits += _log2(10);
  return bits;
}

/// Friendly "time to crack" estimate derived from entropy bits.
String crackTimeLabel(double bits) {
  final seconds = pow(2.0, bits) / kOfflineAttackRatePerSecond;
  if (seconds < 1) return 'instantly';
  if (seconds < 60) return 'under a minute';
  if (seconds < 3600) return '${(seconds / 60).round()} minutes';
  if (seconds < 86400) return '${(seconds / 3600).round()} hours';
  if (seconds < 86400 * 30) return '${(seconds / 86400).round()} days';
  if (seconds < 86400 * 365) return '${(seconds / 86400 / 30).round()} months';
  if (seconds < 86400 * 365 * 100) {
    return '${(seconds / 86400 / 365).round()} years';
  }
  return 'centuries';
}

/// Build the combined character pool given the selected options.
String buildCharacterPool({
  required bool useLowercase,
  required bool useUppercase,
  required bool useDigits,
  required bool useSpecial,
  required bool excludeAmbiguous,
}) {
  final buffer = StringBuffer();
  if (useLowercase) buffer.write(_stripAmbiguous(kLowercaseChars, excludeAmbiguous));
  if (useUppercase) buffer.write(_stripAmbiguous(kUppercaseChars, excludeAmbiguous));
  if (useDigits) buffer.write(_stripAmbiguous(kDigitChars, excludeAmbiguous));
  if (useSpecial) buffer.write(kSpecialChars);
  return buffer.toString();
}

String _stripAmbiguous(String source, bool strip) {
  if (!strip) return source;
  return source.split('').where((c) => !kAmbiguousChars.contains(c)).join();
}

/// Generate a random-character password of the requested length, guaranteeing
/// at least one character from each selected set, then shuffling.
String generateCharacters({
  required int length,
  required bool useLowercase,
  required bool useUppercase,
  required bool useDigits,
  required bool useSpecial,
  required bool excludeAmbiguous,
}) {
  final random = Random.secure();
  final sets = <String>[];
  if (useLowercase) {
    sets.add(_stripAmbiguous(kLowercaseChars, excludeAmbiguous));
    if (sets.last.isEmpty) sets.removeLast();
  }
  if (useUppercase) {
    sets.add(_stripAmbiguous(kUppercaseChars, excludeAmbiguous));
    if (sets.last.isEmpty) sets.removeLast();
  }
  if (useDigits) {
    sets.add(_stripAmbiguous(kDigitChars, excludeAmbiguous));
    if (sets.last.isEmpty) sets.removeLast();
  }
  if (useSpecial) sets.add(kSpecialChars);

  final combined = sets.join();
  final password = <String>[];
  for (final set in sets) {
    password.add(set[random.nextInt(set.length)]);
  }
  while (password.length < length) {
    password.add(combined[random.nextInt(combined.length)]);
  }
  password.shuffle(random);
  return password.join();
}

/// Generate a word-based passphrase of [wordCount] words joined by
/// [separator], optionally ending with a random digit.
String generatePassphrase({
  required int wordCount,
  required String separator,
  required bool includeNumber,
}) {
  final random = Random.secure();
  final words = List.generate(
    wordCount,
    (_) => kPassphraseWords[random.nextInt(kPassphraseWords.length)],
  );
  var phrase = words.join(separator);
  if (includeNumber) phrase += kDigitChars[random.nextInt(kDigitChars.length)];
  return phrase;
}