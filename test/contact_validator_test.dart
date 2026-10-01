import 'package:contact_forms/logic/contact_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('name is required and length-limited', () {
    expect(validateName(''), 'Name is required');
    expect(validateName('   '), 'Name is required');
    expect(validateName('Ada'), isNull);
    expect(validateName('x' * 81), contains('at most 80'));
  });

  test('email format rules', () {
    expect(validateEmail(null), 'Email is required');
    for (final ok in ['a@b.co', 'first.last+tag@sub.example.org']) {
      expect(validateEmail(ok), isNull, reason: ok);
    }
    for (final bad in ['plain', 'a@b', 'a@@b.com', 'a b@c.com', 'a..b@c.com']) {
      expect(validateEmail(bad), 'Enter a valid email address', reason: bad);
    }
  });

  test('subject optional, message length bounds', () {
    expect(validateSubject(''), isNull);
    expect(validateSubject('x' * 121), isNotNull);
    expect(validateMessage(''), 'Message is required');
    expect(validateMessage('too short'), contains('at least 10'));
    expect(validateMessage('long enough message'), isNull);
    expect(validateMessage('x' * 2001), contains('at most 2000'));
  });

  test('validateAll collects every error', () {
    final errors =
        validateAll(name: '', email: 'bad', subject: '', message: '');
    expect(errors.keys, containsAll(['name', 'email', 'message']));
    expect(errors.containsKey('subject'), isFalse);
    expect(
      validateAll(
        name: 'Ada',
        email: 'ada@example.com',
        subject: '',
        message: 'Hello there, nice app!',
      ),
      isEmpty,
    );
  });

  test('ContactMessage normalises fields', () {
    final m = ContactMessage(
      name: ' Ada ',
      email: ' Ada@Example.COM ',
      subject: ' ',
      message: ' hi there friend ',
      sentAt: DateTime(2026),
    );
    expect(m.name, 'Ada');
    expect(m.email, 'ada@example.com');
    expect(m.subject, '(no subject)');
    expect(m.message, 'hi there friend');
  });

  group('edge cases (pass 3)', () {
    test('lengths count what the user sees, not UTF-16 code units', () {
      // 80 emoji = 160 code units; the TextField counter shows 80/80.
      expect(validateName('😀' * 80), isNull);
      expect(validateName('😀' * 81), isNotNull);
      // Thai with tone marks: each syllable is one grapheme cluster.
      expect('น้ำ'.length, 3);
      expect(visibleLength('น้ำ'), 1);
      expect(validateMessage('👍🏽' * 10), isNull);
      expect(validateMessage('👍🏽' * 9), contains('at least'));
      expect(validateSubject('é' * ContactLimits.subjectMax), isNull);
    });

    test('surrounding whitespace does not count toward limits', () {
      expect(validateName('  ${'a' * ContactLimits.nameMax}  '), isNull);
      expect(validateMessage('   short    '), contains('at least'));
      expect(validateName(' \t\n '), 'Name is required');
      expect(validateName(null), 'Name is required');
    });

    test('email local part rules', () {
      for (final bad in [
        '.ada@example.com',
        'ada.@example.com',
        '${'a' * 65}@example.com',
        'ada@example',
        'ada@-example.com',
        'ada@example..com',
        'ada example@example.com',
        '@example.com',
        'ada@',
      ]) {
        expect(validateEmail(bad), isNotNull, reason: bad);
      }
      for (final ok in [
        '${'a' * 64}@example.com',
        'first.last+tag@sub.example.co.th',
        '  ADA@Example.com ',
      ]) {
        expect(validateEmail(ok), isNull, reason: ok);
      }
    });

    test('JSON round trip keeps unicode and timestamps', () {
      final m = ContactMessage(
        name: 'สมชาย 😀',
        email: 'A@B.CO',
        subject: '   ',
        message: 'สวัสดีครับ ขอใบเสนอราคา',
        sentAt: DateTime(2026, 2, 29 - 1, 23, 59, 59),
      );
      final back = ContactMessage.fromJson(m.toJson());
      expect(back.name, 'สมชาย 😀');
      expect(back.email, 'a@b.co');
      expect(back.subject, '(no subject)');
      expect(back.sentAt, m.sentAt);
    });
  });
}
