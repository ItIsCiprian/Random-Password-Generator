import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cipher_generator/main.dart' show PasswordGeneratorApp;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the password generator home page', (tester) async {
    await tester.pumpWidget(const PasswordGeneratorApp());
    await tester.pumpAndSettle();

    expect(find.text('Cipher Generator'), findsOneWidget);
    expect(find.text('Generate'), findsWidgets);
  });
}