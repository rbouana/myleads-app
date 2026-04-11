/// Centralized validation rules for the app.
class Validators {
  Validators._();

  /// Email validation - RFC 5322 simplified.
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone validation - international format with optional + and digits/spaces/dashes.
  static final RegExp _phoneRegex = RegExp(
    r'^[\+]?[0-9\s\-\(\)]{7,20}$',
  );

  /// Password complexity:
  /// - 8 to 15 chars
  /// - at least one letter
  /// - at least one digit
  /// - at least one symbol
  /// - no whitespace
  /// - case sensitive (intrinsic)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    if (value.length > 15) {
      return 'Le mot de passe ne doit pas dépasser 15 caractères';
    }
    if (value.contains(RegExp(r'\s'))) {
      return 'Le mot de passe ne doit pas contenir d\'espaces';
    }
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Le mot de passe doit contenir au moins une lettre';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/~`;]'))) {
      return 'Le mot de passe doit contenir au moins un symbole';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre email';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Email invalide';
    }
    return null;
  }

  static String? validatePhone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Veuillez entrer un numéro de téléphone' : null;
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Le champ "$fieldName" est obligatoire';
    }
    return null;
  }

  /// Normalize phone number for uniqueness checks (digits + leading +).
  static String normalizePhone(String? phone) {
    if (phone == null) return '';
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return '';
    final hasPlus = trimmed.startsWith('+');
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    return hasPlus ? '+$digitsOnly' : digitsOnly;
  }

  /// Normalize email for uniqueness checks.
  static String normalizeEmail(String? email) {
    if (email == null) return '';
    return email.trim().toLowerCase();
  }
}
