import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'field_error.dart';

class PasswordField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final Widget? trailingHeaderAction;
  final ValueChanged<String>? onChanged;

  const PasswordField({
    super.key,
    this.label = 'Password',
    this.placeholder = 'Password',
    this.controller,
    this.textInputAction,
    this.autofillHints = const [AutofillHints.password],
    this.errorText,
    this.trailingHeaderAction,
    this.onChanged,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (widget.trailingHeaderAction != null)
              widget.trailingHeaderAction!,
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onChanged: widget.onChanged,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
              tooltip: _obscureText ? 'Show password' : 'Hide password',
            ),
          ),
        ),
        FieldError(message: widget.errorText),
      ],
    );
  }
}
