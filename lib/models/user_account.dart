/// User account stored in the local SQLite database.
///
/// Sensitive fields (email, names, phone, dateOfBirth) are persisted
/// in encrypted form via [EncryptionService] before being written.
class UserAccount {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? nickname;
  final String? phone;
  final String? dateOfBirth;
  final String? companyName;
  final String? companyRole;
  final String? biography;
  final String passwordHash; // "salt:hash" or empty for OAuth accounts
  final String authProvider; // 'email' | 'google' | 'apple'
  final String? sessionToken;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime passwordChangedAt;
  final String? photoPath; // local file path to profile photo
  final bool emailVerified; // whether email has been verified

  UserAccount({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.nickname,
    this.phone,
    this.dateOfBirth,
    this.companyName,
    this.companyRole,
    this.biography,
    required this.passwordHash,
    this.authProvider = 'email',
    this.sessionToken,
    DateTime? createdAt,
    this.lastLoginAt,
    DateTime? passwordChangedAt,
    this.photoPath,
    this.emailVerified = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        passwordChangedAt = passwordChangedAt ?? DateTime.now();

  String get fullName => '$firstName $lastName'.trim();

  UserAccount copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? nickname,
    String? phone,
    String? dateOfBirth,
    String? companyName,
    String? companyRole,
    String? biography,
    String? passwordHash,
    String? authProvider,
    String? sessionToken,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? passwordChangedAt,
    String? photoPath,
    bool? emailVerified,
  }) {
    return UserAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickname: nickname ?? this.nickname,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      companyName: companyName ?? this.companyName,
      companyRole: companyRole ?? this.companyRole,
      biography: biography ?? this.biography,
      passwordHash: passwordHash ?? this.passwordHash,
      authProvider: authProvider ?? this.authProvider,
      sessionToken: sessionToken ?? this.sessionToken,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      photoPath: photoPath ?? this.photoPath,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}

/// Saved payment method (only stored if user opts in).
class PaymentMethod {
  final String id;
  final String userId;
  final String type; // 'card' | 'mobile_money' | 'paypal'
  final String label;
  final String encryptedDetails; // AES-256 encrypted JSON
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.label,
    required this.encryptedDetails,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
