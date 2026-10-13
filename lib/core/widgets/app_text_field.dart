import 'package:flutter/material.dart';
import 'field_error.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.errorText,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          onChanged: onChanged,
          autofocus: autofocus,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            errorText: null, // Custom FieldError rendered below
          ),
        ),
        FieldError(message: errorText),
      ],
    );
  }
}
