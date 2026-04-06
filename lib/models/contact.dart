import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 0)
class Contact extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String firstName;

  @HiveField(2)
  String lastName;

  @HiveField(3)
  String? jobTitle;

  @HiveField(4)
  String? company;

  @HiveField(5)
  String? phone;

  @HiveField(6)
  String? email;

  @HiveField(7)
  String? source;

  @HiveField(8)
  String? project;

  @HiveField(9)
  String? interest;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  List<String> tags;

  @HiveField(12)
  String status; // 'hot', 'warm', 'cold'

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime? lastContactDate;

  @HiveField(15)
  String? avatarColor;

  @HiveField(16)
  String captureMethod; // 'scan', 'qr', 'nfc', 'manual'

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.jobTitle,
    this.company,
    this.phone,
    this.email,
    this.source,
    this.project,
    this.interest,
    this.notes,
    List<String>? tags,
    this.status = 'warm',
    DateTime? createdAt,
    this.lastContactDate,
    this.avatarColor,
    this.captureMethod = 'manual',
  })  : tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  String get subtitle {
    final parts = <String>[];
    if (jobTitle != null && jobTitle!.isNotEmpty) parts.add(jobTitle!);
    if (company != null && company!.isNotEmpty) parts.add(company!);
    return parts.join(' - ');
  }

  Contact copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? jobTitle,
    String? company,
    String? phone,
    String? email,
    String? source,
    String? project,
    String? interest,
    String? notes,
    List<String>? tags,
    String? status,
    DateTime? createdAt,
    DateTime? lastContactDate,
    String? avatarColor,
    String? captureMethod,
  }) {
    return Contact(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      source: source ?? this.source,
      project: project ?? this.project,
      interest: interest ?? this.interest,
      notes: notes ?? this.notes,
      tags: tags ?? List.from(this.tags),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      avatarColor: avatarColor ?? this.avatarColor,
      captureMethod: captureMethod ?? this.captureMethod,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'jobTitle': jobTitle,
        'company': company,
        'phone': phone,
        'email': email,
        'source': source,
        'project': project,
        'interest': interest,
        'notes': notes,
        'tags': tags,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'lastContactDate': lastContactDate?.toIso8601String(),
        'avatarColor': avatarColor,
        'captureMethod': captureMethod,
      };

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        jobTitle: json['jobTitle'] as String?,
        company: json['company'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        source: json['source'] as String?,
        project: json['project'] as String?,
        interest: json['interest'] as String?,
        notes: json['notes'] as String?,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        status: json['status'] as String? ?? 'warm',
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastContactDate: json['lastContactDate'] != null
            ? DateTime.parse(json['lastContactDate'] as String)
            : null,
        avatarColor: json['avatarColor'] as String?,
        captureMethod: json['captureMethod'] as String? ?? 'manual',
      );
}
