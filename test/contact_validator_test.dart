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
}
