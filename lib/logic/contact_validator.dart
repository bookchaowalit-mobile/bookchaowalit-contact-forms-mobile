/// Pure validation rules for a contact message.
library;

import 'package:characters/characters.dart';

/// Length as the user sees it (grapheme clusters), matching the counter that
/// `TextField.maxLength` shows. `String.length` counts UTF-16 code units, so
/// an emoji or a Thai syllable with tone marks would count double.
int visibleLength(String text) => text.characters.length;

class ContactLimits {
  static const nameMax = 80;
  static const subjectMax = 120;
  static const messageMin = 10;
  static const messageMax = 2000;
}

final _emailPattern = RegExp(
  r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
);

String? validateName(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Name is required';
  if (visibleLength(v) > ContactLimits.nameMax) {
    return 'Name must be at most ${ContactLimits.nameMax} characters';
  }
  return null;
}

String? validateEmail(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Email is required';
  if (v.length > 254 || !_emailPattern.hasMatch(v) || v.contains('..')) {
    return 'Enter a valid email address';
  }
  // RFC 5321/5322: the local part is at most 64 octets and may not start or
  // end with a dot.
  final local = v.substring(0, v.lastIndexOf('@'));
  if (local.length > 64 || local.startsWith('.') || local.endsWith('.')) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validateSubject(String? value) {
  final v = (value ?? '').trim();
  if (visibleLength(v) > ContactLimits.subjectMax) {
    return 'Subject must be at most ${ContactLimits.subjectMax} characters';
  }
  return null;
}

String? validateMessage(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Message is required';
  if (visibleLength(v) < ContactLimits.messageMin) {
    return 'Message must be at least ${ContactLimits.messageMin} characters';
  }
  if (visibleLength(v) > ContactLimits.messageMax) {
    return 'Message must be at most ${ContactLimits.messageMax} characters';
  }
  return null;
}

class ContactMessage {
  ContactMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
    required this.sentAt,
  })  : name = name.trim(),
        email = email.trim().toLowerCase(),
        subject = subject.trim().isEmpty ? '(no subject)' : subject.trim(),
        message = message.trim();

  final String name;
  final String email;
  final String subject;
  final String message;
  final DateTime sentAt;

  Map<String, Object?> toJson() => {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'sentAt': sentAt.toIso8601String(),
      };

  static ContactMessage fromJson(Map<String, Object?> json) => ContactMessage(
        name: json['name'] as String,
        email: json['email'] as String,
        subject: json['subject'] as String,
        message: json['message'] as String,
        sentAt: DateTime.parse(json['sentAt'] as String),
      );
}

Map<String, Object?> contactMessageToJson(ContactMessage m) => m.toJson();

/// Returns a map of field -> error for every invalid field (empty when valid).
Map<String, String> validateAll({
  required String name,
  required String email,
  required String subject,
  required String message,
}) {
  final errors = <String, String>{};
  void check(String field, String? error) {
    if (error != null) errors[field] = error;
  }

  check('name', validateName(name));
  check('email', validateEmail(email));
  check('subject', validateSubject(subject));
  check('message', validateMessage(message));
  return errors;
}
