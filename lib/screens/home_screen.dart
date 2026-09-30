import 'package:flutter/material.dart';

import '../logic/contact_validator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.clock = DateTime.now});

  final DateTime Function() clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final List<ContactMessage> _sent = [];

  @override
  void dispose() {
    for (final c in [_name, _email, _subject, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _sent.insert(
        0,
        ContactMessage(
          name: _name.text,
          email: _email.text,
          subject: _subject.text,
          message: _message.text,
          sentAt: widget.clock(),
        ),
      );
      _formKey.currentState!.reset();
      for (final c in [_name, _email, _subject, _message]) {
        c.clear();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message saved on this device')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Forms')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  key: const Key('name-field'),
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: ContactLimits.nameMax,
                  textInputAction: TextInputAction.next,
                  validator: validateName,
                ),
                TextFormField(
                  key: const Key('email-field'),
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('subject-field'),
                  controller: _subject,
                  decoration: const InputDecoration(
                    labelText: 'Subject (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: ContactLimits.subjectMax,
                  validator: validateSubject,
                ),
                TextFormField(
                  key: const Key('message-field'),
                  controller: _message,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 4,
                  maxLines: 8,
                  maxLength: ContactLimits.messageMax,
                  validator: validateMessage,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('submit'),
                    onPressed: _submit,
                    icon: const Icon(Icons.send),
                    label: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Submitted (${_sent.length})', style: textTheme.titleMedium),
          if (_sent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Nothing submitted yet.'),
            ),
          for (final m in _sent)
            Card(
              child: ListTile(
                title: Text(m.subject),
                subtitle: Text('${m.name} <${m.email}>\n${m.message}'),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }
}
