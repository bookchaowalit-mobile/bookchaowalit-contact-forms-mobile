import 'package:contact_forms/main.dart';
import 'package:contact_forms/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell shows the form and about tab', (tester) async {
    await tester.pumpWidget(const ContactFormsApp());
    expect(find.text('Contact Forms'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('invalid submit shows errors, valid submit lists message', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pump();
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Submitted (0)'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('name-field')), 'Ada');
    await tester.enterText(
      find.byKey(const Key('email-field')),
      'ada@example.com',
    );
    await tester.enterText(find.byKey(const Key('subject-field')), 'Hello');
    await tester.enterText(
      find.byKey(const Key('message-field')),
      'I would like a quote please.',
    );
    await tester.ensureVisible(find.byKey(const Key('submit')));
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pump();
    expect(find.text('Submitted (1)'), findsOneWidget);
    expect(find.text('Name is required'), findsNothing);
  });
}
