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
    expect(find.text('Laravel Task Manager'), findsOneWidget);
    expect(find.text('Organize with clarity. Deliver on time.'), findsOneWidget);

    // Verify Login button
    expect(find.text('Log in'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing); // Uses custom AppButton
  });
}
