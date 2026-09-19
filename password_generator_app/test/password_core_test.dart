import 'package:flutter_test/flutter_test.dart';

import 'package:cipher_generator/password_core.dart';
import 'package:cipher_generator/word_list.dart';

void main() {
  test('passphrase word list has 1024 unique 4-8 letter words', () {
    expect(kPassphraseWords.length, 1024);
    expect(kPassphraseWords.toSet().length, 1024);
    for (final word in kPassphraseWords) {
      expect(word.length, inInclusiveRange(4, 8));
      expect(RegExp(r'^[a-z]+$').hasMatch(word), isTrue);
    }
  });

  test('character generation respects options and length', () {
    final password = generateCharacters(
      length: 16,
      useLowercase: true,
      useUppercase: true,
      useDigits: true,
      useSpecial: true,
      excludeAmbiguous: false,
    );
    expect(password.length, 16);
    expect(hasLowercase(password), isTrue);
    expect(hasUppercase(password), isTrue);
    expect(hasDigit(password), isTrue);
    expect(hasSpecial(password), isTrue);
  });

  test('ambiguous characters can be excluded', () {
    for (var i = 0; i < 20; i++) {
      final password = generateCharacters(
        length: 20,
        useLowercase: true,
        useUppercase: true,
        useDigits: true,
        useSpecial: false,
        excludeAmbiguous: true,
      );
      for (final char in password.split('')) {
        expect(kAmbiguousChars.contains(char), isFalse);
      }
    }
  });

  test('passphrase generation produces separators and optional number', () {
    final phrase = generatePassphrase(
      wordCount: 6,
      separator: '-',
      includeNumber: true,
    );
    final parts = phrase.split('-');
    expect(parts.length, inInclusiveRange(2, 6));
    expect(RegExp(r'[0-9]$').hasMatch(phrase), isTrue);
  });

  test('entropy is monotonic with length and pool size', () {
    final small = characterEntropyBits(length: 8, poolSize: 26);
    final big = characterEntropyBits(length: 16, poolSize: 26);
    final huge = characterEntropyBits(length: 16, poolSize: 95);
    expect(big, greaterThan(small));
    expect(huge, greaterThan(big));
  });

  test('strength classification matches entropy', () {
    expect(strengthForBits(10), PasswordStrength.veryWeak);
    expect(strengthForBits(50), PasswordStrength.fair);
    expect(strengthForBits(80), PasswordStrength.strong);
  });

  test('crack time labels escalate', () {
    final instant = crackTimeLabel(1);
    final year = crackTimeLabel(45);
    final centuries = crackTimeLabel(120);
    expect(instant, isNot(year));
    expect(centuries, 'centuries');
    expect(year, isNot('centuries'));
  });
}