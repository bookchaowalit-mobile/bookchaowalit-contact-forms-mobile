import 'package:contact_forms/main.dart';
import 'package:contact_forms/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('app shell shows the form and about tab', (tester) async {
    await tester.pumpWidget(const ContactFormsApp());
    await tester.pumpAndSettle();
    expect(find.text('Contact Forms'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('invalid submit shows errors, valid submit lists message', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
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

  Widget home({double textScale = 1}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const HomeScreen(),
        ),
      );

  testWidgets('an 80-emoji name passes both the counter and the validator', (
    tester,
  ) async {
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-field')), '😀' * 80);
    await tester.enterText(find.byKey(const Key('email-field')), 'a@b.co');
    await tester.enterText(
      find.byKey(const Key('message-field')),
      'Ten or more characters here.',
    );
    await tester.ensureVisible(find.byKey(const Key('submit')));
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pump();
    expect(find.textContaining('at most'), findsNothing);
    expect(find.text('Submitted (1)'), findsOneWidget);
  });

  testWidgets('deleting a message empties the list again', (tester) async {
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-field')), 'Ada');
    await tester.enterText(find.byKey(const Key('email-field')), 'a@b.co');
    await tester.enterText(
      find.byKey(const Key('message-field')),
      'Ten or more characters here.',
    );
    await tester.ensureVisible(find.byKey(const Key('submit')));
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();
    expect(find.text('Message saved on this device'), findsOneWidget);
    // Dismiss the "saved" snack bar so it does not cover the list.
    ScaffoldMessenger.of(
      tester.element(find.byType(HomeScreen)),
    ).removeCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byIcon(Icons.delete_outline),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    expect(find.text('Nothing submitted yet.'), findsOneWidget);
  });

  testWidgets('meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('lays out at 200% text scale without overflow', (tester) async {
    await tester.pumpWidget(home(textScale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
