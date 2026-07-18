import 'package:flutter/material.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';

typedef SaveLoyaltyTierRules = Future<String?> Function(
  LoyaltyTierRules rules,
);

class LoyaltyTierRulesForm extends StatefulWidget {
  const LoyaltyTierRulesForm({
    super.key,
    required this.initialRules,
    required this.onSave,
  });

  final LoyaltyTierRules initialRules;
  final SaveLoyaltyTierRules onSave;

  @override
  State<LoyaltyTierRulesForm> createState() => _LoyaltyTierRulesFormState();
}

class _LoyaltyTierRulesFormState extends State<LoyaltyTierRulesForm> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController silverSpendController;
  late final TextEditingController goldSpendController;
  late final TextEditingController memberMultiplierController;
  late final TextEditingController silverMultiplierController;
  late final TextEditingController goldMultiplierController;

  bool saving = false;
  String message = '';
  bool saveSucceeded = false;

  @override
  void initState() {
    super.initState();

    final rules = widget.initialRules;

    silverSpendController = TextEditingController(
      text: _number(rules.silverMinimumSpend),
    );
    goldSpendController = TextEditingController(
      text: _number(rules.goldMinimumSpend),
    );
    memberMultiplierController = TextEditingController(
      text: _number(rules.memberPointsMultiplier),
    );
    silverMultiplierController = TextEditingController(
      text: _number(rules.silverPointsMultiplier),
    );
    goldMultiplierController = TextEditingController(
      text: _number(rules.goldPointsMultiplier),
    );
  }

  static String _number(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  double? _parse(TextEditingController controller) {
    return double.tryParse(
      controller.text.trim().replaceAll(',', '.'),
    );
  }

  String? _positive(String? value) {
    final parsed = double.tryParse(
      value?.trim().replaceAll(',', '.') ?? '',
    );

    if (parsed == null || !parsed.isFinite) {
      return 'Enter a valid number.';
    }

    if (parsed <= 0) {
      return 'Value must be greater than zero.';
    }

    return null;
  }

  String? _multiplier(String? value) {
    final basic = _positive(value);
    if (basic != null) return basic;

    final parsed = double.parse(
      value!.trim().replaceAll(',', '.'),
    );

    if (parsed < 1 || parsed > 2) {
      return 'Multiplier must be between 1 and 2.';
    }

    return null;
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final rules = LoyaltyTierRules(
      silverMinimumSpend: _parse(silverSpendController)!,
      goldMinimumSpend: _parse(goldSpendController)!,
      memberPointsMultiplier: _parse(memberMultiplierController)!,
      silverPointsMultiplier: _parse(silverMultiplierController)!,
      goldPointsMultiplier: _parse(goldMultiplierController)!,
    );

    final errors = rules.validate();

    if (errors.isNotEmpty) {
      setState(() {
        saveSucceeded = false;
        message = errors.join(' ');
      });
      return;
    }

    setState(() {
      saving = true;
      message = '';
    });

    final error = await widget.onSave(rules);

    if (!mounted) return;

    setState(() {
      saving = false;
      saveSucceeded = error == null;
      message = error ?? 'Tier rules saved.';
    });
  }

  @override
  void dispose() {
    silverSpendController.dispose();
    goldSpendController.dispose();
    memberMultiplierController.dispose();
    silverMultiplierController.dispose();
    goldMultiplierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('loyalty-tier-rules-form'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tier thresholds',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('tier-silver-spend'),
                controller: silverSpendController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Silver minimum lifetime spending',
                  prefixText: 'Rp ',
                ),
                validator: _positive,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('tier-gold-spend'),
                controller: goldSpendController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Gold minimum lifetime spending',
                  prefixText: 'Rp ',
                ),
                validator: _positive,
              ),
              const SizedBox(height: 20),
              Text(
                'Points multipliers',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('tier-member-multiplier'),
                controller: memberMultiplierController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Member multiplier',
                  prefixText: 'x ',
                ),
                validator: _multiplier,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('tier-silver-multiplier'),
                controller: silverMultiplierController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Silver multiplier',
                  prefixText: 'x ',
                ),
                validator: _multiplier,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('tier-gold-multiplier'),
                controller: goldMultiplierController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Gold multiplier',
                  prefixText: 'x ',
                ),
                validator: _multiplier,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('save-tier-rules'),
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.workspace_premium_outlined),
                label: const Text('Save tier rules'),
              ),
              if (message.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  message,
                  key: const ValueKey('tier-rules-message'),
                  style: TextStyle(
                    color: saveSucceeded
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
