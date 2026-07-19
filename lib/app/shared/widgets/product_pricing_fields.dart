import 'package:flutter/material.dart';
import 'package:postgetx/app/shared/forms/form_validators.dart';
import 'package:postgetx/app/shared/widgets/malprax_form_field.dart';

class ProductPricingFields extends StatelessWidget {
  const ProductPricingFields({
    super.key,
    required this.sellingPriceController,
    required this.costPriceController,
  });

  final TextEditingController sellingPriceController;
  final TextEditingController costPriceController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MalpraxFormField(
            key: const ValueKey('product-selling-price'),
            controller: sellingPriceController,
            label: 'Selling Price',
            hint: 'Example: 7500',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: (value) =>
                FormValidators.positiveNumber(value, 'Selling price'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MalpraxFormField(
            key: const ValueKey('product-cost-price'),
            controller: costPriceController,
            label: 'Cost Price',
            hint: 'Example: 4500',
            helperText: 'Capital required to replace one item.',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: (value) =>
                FormValidators.positiveNumber(value, 'Cost price'),
          ),
        ),
      ],
    );
  }
}
