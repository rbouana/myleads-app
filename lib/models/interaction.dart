import 'package:hive/hive.dart';

part 'interaction.g.dart';

@HiveType(typeId: 2)
class Interaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String contactId;

  @HiveField(2)
  String type; // 'call', 'sms', 'whatsapp', 'email', 'meeting', 'note'

  @HiveField(3)
  String content;

  @HiveField(4)
  DateTime createdAt;

  Interaction({
    required this.id,
    required this.contactId,
    required this.type,
    required this.content,
    DateTime? createdAt,
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
