import '../logic/contact_validator.dart';
import 'list_repository.dart';

typedef ContactMessageRepository = ListRepository<ContactMessage>;

/// Device storage for messages (shared_preferences, JSON).
const ContactMessageRepository deviceContactMessageRepository =
    SharedPreferencesListRepository<ContactMessage>(
  storageKey: 'contact_forms_messages_v1',
  fromJson: ContactMessage.fromJson,
  toJson: contactMessageToJson,
);
