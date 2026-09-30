/// Pure validation rules for a contact message.
library;

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
  if (v.length > ContactLimits.nameMax) {
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
  return null;
}

String? validateSubject(String? value) {
  final v = (value ?? '').trim();
  if (v.length > ContactLimits.subjectMax) {
    return 'Subject must be at most ${ContactLimits.subjectMax} characters';
  }
  return null;
}

String? validateMessage(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Message is required';
  if (v.length < ContactLimits.messageMin) {
    return 'Message must be at least ${ContactLimits.messageMin} characters';
  }
  if (v.length > ContactLimits.messageMax) {
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
}

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
