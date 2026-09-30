import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:contact_forms/data/list_repository.dart';
import 'package:contact_forms/data/contact_message_repository.dart';
import 'package:contact_forms/logic/contact_validator.dart';
import 'package:contact_forms/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final sample = ContactMessage(
    name: 'Ann',
    email: 'ann@example.com',
    subject: 'Hello',
    message: 'Hi there',
    sentAt: DateTime.utc(2026, 1, 2, 3, 4),
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('round-trips messages through shared_preferences', () async {
    await deviceContactMessageRepository.save([sample]);
    final loaded = await deviceContactMessageRepository.load();
    expect(loaded, hasLength(1));
    expect(loaded.single.toJson(), sample.toJson());
  });

  test('empty storage loads an empty list', () async {
    expect(await deviceContactMessageRepository.load(), isEmpty);
  });

  test('skips malformed records and rejects non-list payloads', () async {
    SharedPreferences.setMockInitialValues({
      'contact_forms_messages_v1': jsonEncode([
        sample.toJson(),
        {'id': 'x'},
        42,
      ]),
    });
    expect(await deviceContactMessageRepository.load(), hasLength(1));

    SharedPreferences.setMockInitialValues({'contact_forms_messages_v1': '{}'});
    expect(deviceContactMessageRepository.load(), throwsFormatException);
  });

  testWidgets('home screen restores saved messages and saves changes',
      (tester) async {
    final repo = InMemoryListRepository<ContactMessage>([sample]);
    await tester.pumpWidget(MaterialApp(home: HomeScreen(repository: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsWidgets);

    await tester.tap(find.byTooltip('Delete message'));
    await tester.pumpAndSettle();
    expect(await repo.load(), isEmpty);
  });

  testWidgets('shows an error when saved messages cannot be read',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(repository: _FailingRepository())),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('storage-error')), findsOneWidget);
  });
}

class _FailingRepository implements ListRepository<ContactMessage> {
  @override
  Future<List<ContactMessage>> load() async =>
      throw const FormatException('bad');

  @override
  Future<void> save(List<ContactMessage> items) async =>
      throw StateError('full');
}
