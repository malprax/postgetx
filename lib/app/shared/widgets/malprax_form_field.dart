import 'package:flutter/material.dart';

class MalpraxFormField extends StatelessWidget {
  const MalpraxFormField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.onChanged,
    this.validator,
    this.helperText,
    this.icon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.enabled = true,
  });
  final String label;
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? helperText;
  final IconData? icon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool autofocus;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        obscureText: obscureText,
        autofocus: autofocus,
        maxLines: obscureText ? 1 : maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
          prefixIcon: icon == null ? null : Icon(icon),
          suffixIcon: suffixIcon,
        ),
      );
}
