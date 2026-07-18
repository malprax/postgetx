abstract final class FormValidators {
  static String? required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required.' : null;

  static String? email(String? value) {
    final missing = required(value, 'Email');
    if (missing != null) return missing;
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailPattern.hasMatch(value!.trim())
        ? null
        : 'Enter a valid email address.';
  }

  static String? nonNegativeNumber(String? value, String label) {
    final missing = required(value, label);
    if (missing != null) return missing;
    final parsed = double.tryParse(value!.trim());
    if (parsed == null) return '$label must be a number.';
    return parsed < 0 ? '$label cannot be negative.' : null;
  }

  static String? positiveNumber(String? value, String label) {
    final invalid = nonNegativeNumber(value, label);
    if (invalid != null) return invalid;
    return double.parse(value!.trim()) <= 0
        ? '$label must be greater than zero.'
        : null;
  }

  static String? discount(String? value, {required bool percentage}) {
    final invalid = nonNegativeNumber(value, 'Discount');
    if (invalid != null) return invalid;
    final parsed = double.parse(value!.trim());
    if (percentage && parsed > 100) {
      return 'Percentage cannot be greater than 100.';
    }
    return null;
  }
}
