/// Interaction entity for the local SQLite database.
class Interaction {
  final String id;
  final String contactId;
  String type; // 'call', 'sms', 'whatsapp', 'email', 'meeting', 'note'
  String content;
  DateTime createdAt;
  String ownerId;

  Interaction({
    required this.id,
    required this.contactId,
    required this.type,
    required this.content,
    DateTime? createdAt,
    this.ownerId = '',
  }) : createdAt = createdAt ?? DateTime.now();

  String get typeIcon {
    switch (type) {
      case 'call':
        return 'phone';
      case 'sms':
        return 'message';
      case 'whatsapp':
        return 'message';
      case 'email':
        return 'email';
      case 'meeting':
        return 'people';
      case 'note':
        return 'note';
      default:
        return 'info';
    }
  }

  String get typeLabel {
    switch (type) {
      case 'call':
        return 'Appel';
      case 'sms':
        return 'SMS';
      case 'whatsapp':
        return 'WhatsApp';
      case 'email':
        return 'Email';
      case 'meeting':
        return 'Réunion';
      case 'note':
        return 'Note';
      default:
        return type;
    }
  }
}
