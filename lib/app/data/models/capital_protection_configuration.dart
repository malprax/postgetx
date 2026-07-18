class CapitalProtectionConfiguration {
  const CapitalProtectionConfiguration({
    required this.operationalReservePercentage,
    required this.minimumCashBuffer,
  });

  static const defaults = CapitalProtectionConfiguration(
    operationalReservePercentage: 20,
    minimumCashBuffer: 0,
  );

  final double operationalReservePercentage;
  final double minimumCashBuffer;

  List<String> validate() {
    final errors = <String>[];

    if (!operationalReservePercentage.isFinite ||
        operationalReservePercentage < 0 ||
        operationalReservePercentage > 80) {
      errors.add(
        'Operational reserve percentage must be between 0 and 80.',
      );
    }

    if (!minimumCashBuffer.isFinite || minimumCashBuffer < 0) {
      errors.add('Minimum cash buffer cannot be negative.');
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'operationalReservePercentage': operationalReservePercentage,
      'minimumCashBuffer': minimumCashBuffer,
    };
  }

  factory CapitalProtectionConfiguration.fromMap(
    Map<dynamic, dynamic> map,
  ) {
    final restored = CapitalProtectionConfiguration(
      operationalReservePercentage:
          (map['operationalReservePercentage'] as num?)?.toDouble() ??
              defaults.operationalReservePercentage,
      minimumCashBuffer: (map['minimumCashBuffer'] as num?)?.toDouble() ??
          defaults.minimumCashBuffer,
    );

    return restored.isValid ? restored : defaults;
  }
}
