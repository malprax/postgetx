import 'package:flutter/material.dart';
import 'package:postgetx/app/data/models/capital_protection_configuration.dart';

class CapitalProtectionConfigurationForm extends StatefulWidget {
  const CapitalProtectionConfigurationForm({
    super.key,
    required this.initialConfiguration,
    required this.onSave,
    this.saving = false,
  });

  final CapitalProtectionConfiguration initialConfiguration;
  final Future<String?> Function(
    CapitalProtectionConfiguration configuration,
  ) onSave;
  final bool saving;

  @override
  State<CapitalProtectionConfigurationForm> createState() =>
      _CapitalProtectionConfigurationFormState();
}

class _CapitalProtectionConfigurationFormState
    extends State<CapitalProtectionConfigurationForm> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController reserveController;
  late final TextEditingController bufferController;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    reserveController = TextEditingController(
      text: _number(
        widget.initialConfiguration.operationalReservePercentage,
      ),
    );
    bufferController = TextEditingController(
      text: _number(
        widget.initialConfiguration.minimumCashBuffer,
      ),
    );
  }

  static String _number(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  double? parse(TextEditingController controller) {
    return double.tryParse(
      controller.text.trim().replaceAll(',', '.'),
    );
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false) || widget.saving) {
      return;
    }

    final configuration = CapitalProtectionConfiguration(
      operationalReservePercentage: parse(reserveController)!,
      minimumCashBuffer: parse(bufferController)!,
    );

    final error = await widget.onSave(configuration);

    if (!mounted) return;

    setState(() {
      errorMessage = error ?? '';
    });

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Capital protection rules saved.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    reserveController.dispose();
    bufferController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey(
        'capital-protection-configuration-form',
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const ValueKey(
                  'capital-operational-reserve',
                ),
                controller: reserveController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Operational reserve from margin',
                  suffixText: '%',
                  helperText:
                      'The portion of positive margin reserved for operations.',
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    value?.trim().replaceAll(',', '.') ?? '',
                  );

                  if (parsed == null || !parsed.isFinite) {
                    return 'Enter a valid percentage.';
                  }

                  if (parsed < 0 || parsed > 80) {
                    return 'Reserve percentage must be between 0 and 80.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey(
                  'capital-minimum-cash-buffer',
                ),
                controller: bufferController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Minimum cash buffer',
                  prefixText: 'Rp ',
                  helperText:
                      'Profit below this buffer is not marked safe to use.',
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    value?.trim().replaceAll(',', '.') ?? '',
                  );

                  if (parsed == null || !parsed.isFinite) {
                    return 'Enter a valid amount.';
                  }

                  if (parsed < 0) {
                    return 'Minimum cash buffer cannot be negative.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey(
                  'save-capital-protection-configuration',
                ),
                onPressed: widget.saving ? null : save,
                icon: const Icon(Icons.shield_outlined),
                label: Text(
                  widget.saving ? 'Saving...' : 'Save capital protection rules',
                ),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    errorMessage,
                    key: const ValueKey(
                      'capital-protection-configuration-error',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
