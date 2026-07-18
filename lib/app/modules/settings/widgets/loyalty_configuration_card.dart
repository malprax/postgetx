import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/app/data/models/loyalty_configuration.dart';
import 'package:postgetx/app/modules/settings/controllers/loyalty_configuration_controller.dart';

class LoyaltyConfigurationCard extends StatefulWidget {
  const LoyaltyConfigurationCard({
    super.key,
    this.controller,
  });

  final LoyaltyConfigurationController? controller;

  @override
  State<LoyaltyConfigurationCard> createState() =>
      _LoyaltyConfigurationCardState();
}

class _LoyaltyConfigurationCardState extends State<LoyaltyConfigurationCard> {
  late final LoyaltyConfigurationController controller;
  late final TextEditingController spendController;
  late final TextEditingController redeemController;
  late final TextEditingController minimumController;
  late final TextEditingController maximumController;
  late bool enabled;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    controller =
        widget.controller ?? Get.find<LoyaltyConfigurationController>();

    final configuration = controller.configuration.value;
    enabled = configuration.isEnabled;

    spendController = TextEditingController(
      text: _number(configuration.spendPerPoint),
    );
    redeemController = TextEditingController(
      text: _number(configuration.redeemValuePerPoint),
    );
    minimumController = TextEditingController(
      text: _number(configuration.minimumEligibleTransaction),
    );
    maximumController = TextEditingController(
      text: _number(configuration.maximumRedemptionPercentage),
    );
  }

  static String _number(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  double? _parse(TextEditingController value) {
    return double.tryParse(
      value.text.trim().replaceAll(',', '.'),
    );
  }

  String? _positiveValue(
    String? value, {
    bool allowZero = false,
  }) {
    final parsed = double.tryParse(
      value?.trim().replaceAll(',', '.') ?? '',
    );

    if (parsed == null || !parsed.isFinite) {
      return 'Enter a valid number.';
    }

    if (allowZero ? parsed < 0 : parsed <= 0) {
      return allowZero
          ? 'Value cannot be negative.'
          : 'Value must be greater than zero.';
    }

    return null;
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final configuration = LoyaltyConfiguration(
      isEnabled: enabled,
      spendPerPoint: _parse(spendController)!,
      redeemValuePerPoint: _parse(redeemController)!,
      minimumEligibleTransaction: _parse(minimumController)!,
      maximumRedemptionPercentage: _parse(maximumController)!,
    );

    final saved = await controller.save(configuration);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Loyalty configuration saved.'
              : controller.errorMessage.value,
        ),
      ),
    );
  }

  @override
  void dispose() {
    spendController.dispose();
    redeemController.dispose();
    minimumController.dispose();
    maximumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('loyalty-configuration-card'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                key: const ValueKey('loyalty-enabled-switch'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable customer loyalty'),
                subtitle: const Text(
                  'Customers can earn and redeem points during checkout.',
                ),
                value: enabled,
                onChanged: (value) {
                  setState(() => enabled = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('loyalty-spend-per-point'),
                controller: spendController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Spending required for 1 point',
                  prefixText: 'Rp ',
                ),
                validator: _positiveValue,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('loyalty-redeem-value'),
                controller: redeemController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Discount value of 1 point',
                  prefixText: 'Rp ',
                ),
                validator: _positiveValue,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('loyalty-minimum-transaction'),
                controller: minimumController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Minimum transaction to earn points',
                  prefixText: 'Rp ',
                ),
                validator: (value) => _positiveValue(
                  value,
                  allowZero: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('loyalty-maximum-redemption'),
                controller: maximumController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Maximum payment covered by points',
                  suffixText: '%',
                ),
                validator: (value) {
                  final basic = _positiveValue(value);
                  if (basic != null) return basic;

                  final parsed = double.parse(
                    value!.trim().replaceAll(',', '.'),
                  );

                  if (parsed > 100) {
                    return 'Percentage cannot exceed 100.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              Obx(
                () => FilledButton.icon(
                  key: const ValueKey('save-loyalty-configuration'),
                  onPressed: controller.saving.value ? null : _save,
                  icon: controller.saving.value
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save loyalty rules'),
                ),
              ),
              Obx(
                () => controller.errorMessage.value.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          controller.errorMessage.value,
                          key: const ValueKey(
                            'loyalty-configuration-error',
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
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
