class CustomerUtils {
  CustomerUtils._();

  static const String indonesiaCountryCode = '62';

  static String normalizePhone(String value) {
    final digits = value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (digits.isEmpty) {
      return '';
    }

    if (digits.startsWith('00$indonesiaCountryCode')) {
      return digits.substring(2);
    }

    if (digits.startsWith(indonesiaCountryCode)) {
      return digits;
    }

    if (digits.startsWith('0')) {
      return '$indonesiaCountryCode${digits.substring(1)}';
    }

    if (digits.startsWith('8')) {
      return '$indonesiaCountryCode$digits';
    }

    return digits;
  }

  static bool isValidPhone(
    String value, {
    int minimumLength = 10,
    int maximumLength = 15,
  }) {
    final normalized = normalizePhone(value);

    if (normalized.isEmpty) {
      return false;
    }

    return normalized.length >= minimumLength &&
        normalized.length <= maximumLength;
  }

  static bool isSamePhone(
    String first,
    String second,
  ) {
    final normalizedFirst = normalizePhone(first);
    final normalizedSecond = normalizePhone(second);

    if (normalizedFirst.isEmpty || normalizedSecond.isEmpty) {
      return false;
    }

    return normalizedFirst == normalizedSecond;
  }

  static String formatForDisplay(String value) {
    final normalized = normalizePhone(value);

    if (normalized.isEmpty) {
      return '';
    }

    if (normalized.startsWith(indonesiaCountryCode)) {
      return '+$normalized';
    }

    return normalized;
  }

  static String generateMembershipId(int sequence) {
    if (sequence < 1) {
      throw ArgumentError.value(
        sequence,
        'sequence',
        'Membership sequence must be greater than zero.',
      );
    }

    return 'MBR-${sequence.toString().padLeft(6, '0')}';
  }
}
