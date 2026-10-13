import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outline, destructive, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool isFullWidth;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isFullWidth = true,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    Color bgColor;
    Color fgColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = theme.colorScheme.primary;
        fgColor = theme.colorScheme.onPrimary;
        break;
      case AppButtonVariant.secondary:
        bgColor = theme.colorScheme.secondary;
        fgColor = theme.colorScheme.onSecondary;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = theme.colorScheme.onSurface;
        borderSide = BorderSide(color: theme.colorScheme.outline);
        break;
      case AppButtonVariant.destructive:
        bgColor = theme.colorScheme.error;
        fgColor = theme.colorScheme.onError;
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = theme.colorScheme.onSurface;
        break;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isEnabled ? fgColor : fgColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: Material(
        color: isEnabled ? bgColor : bgColor.withValues(alpha: 0.5),
        shape: borderSide != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: borderSide,
              )
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: content,
          ),
        ),
      ),
    );
  }
}
