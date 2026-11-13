import 'package:courtside_kits/main.dart';
import 'package:courtside_kits/providers/auth_provider.dart';
import 'package:courtside_kits/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Widget app() => ChangeNotifierProvider(
      // Points at an unused address: these tests never reach the network.
      create: (_) => AuthProvider(GoTrueClient(url: 'http://127.0.0.1:9', autoRefreshToken: false)),
      child: const CourtsideKitsApp(home: AuthScreen()),
    );

void main() {
  testWidgets('shows email sign-in and the GitHub option', (tester) async {
    await tester.pumpWidget(app());
    expect(find.text('Continue with GitHub'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('validates email and password before submitting', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('At least 6 characters'), findsOneWidget);
  });

  testWidgets('create account asks to confirm the password', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Create account'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'fan@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm password'), 'different');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
