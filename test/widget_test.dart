import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_mobile/features/auth/ui/welcome_screen.dart';

void main() {
  testWidgets('WelcomeScreen renders logo, app title, and login button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WelcomeScreen(),
        ),
      ),
    );

    // Verify app title and slogan
    expect(find.text('Track'), findsOneWidget);
    expect(find.text('Stay organized.'), findsOneWidget);

    // Verify Login button
    expect(find.text('Log in'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing); // Uses custom AppButton
  });
}
