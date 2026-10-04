class PakistanInput {
  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  static String? validateGmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final email = value.trim().toLowerCase();
    if (!email.contains('@')) return 'Enter a valid email';
    if (!email.endsWith('@gmail.com') && !email.endsWith('@googlemail.com')) {
      return 'Use a Gmail address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    final digits = digitsOnly(value);
    final valid = (digits.startsWith('03') && digits.length == 11) ||
        (digits.startsWith('923') && digits.length == 12) ||
        (digits.startsWith('3') && digits.length == 10);
    return valid ? null : 'Enter a valid Pakistani number (+92)';
  }

  static String normalizePhone(String value) {
    var digits = digitsOnly(value);
    if (digits.startsWith('0')) {
      digits = '92${digits.substring(1)}';
    } else if (digits.startsWith('3') && digits.length == 10) {
      digits = '92$digits';
    }
    return '+$digits';
  }

  static String? validateCnic(String? value) {
    if (value == null || value.trim().isEmpty) return 'CNIC is required';
    if (digitsOnly(value).length != 13) return 'CNIC must be 13 digits';
    return null;
  }

  static String normalizeCnic(String value) {
    final digits = digitsOnly(value);
    if (digits.length != 13) return value.trim();
    return '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12)}';
  }
}
