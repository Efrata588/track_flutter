import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';

enum StatusAlertVariant { success, error, warning, info }

class StatusAlert extends StatelessWidget {
  final String message;
  final StatusAlertVariant variant;

  const StatusAlert({
    super.key,
    required this.message,
    this.variant = StatusAlertVariant.success,
  });

  factory StatusAlert.error({Key? key, required String message}) =>
      StatusAlert(key: key, message: message, variant: StatusAlertVariant.error);

  factory StatusAlert.success({Key? key, required String message}) =>
      StatusAlert(key: key, message: message, variant: StatusAlertVariant.success);

  factory StatusAlert.warning({Key? key, required String message}) =>
      StatusAlert(key: key, message: message, variant: StatusAlertVariant.warning);

  factory StatusAlert.info({Key? key, required String message}) =>
      StatusAlert(key: key, message: message, variant: StatusAlertVariant.info);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData iconData;

    switch (variant) {
      case StatusAlertVariant.success:
        bgColor = isDark
            ? AppColors.statusCompletedBgDark
            : AppColors.statusCompletedBgLight;
        borderColor = isDark
            ? AppColors.statusCompletedBorderDark
            : AppColors.statusCompletedBorderLight;
        textColor = isDark
            ? AppColors.statusCompletedTextDark
            : AppColors.statusCompletedTextLight;
        iconData = LucideIcons.checkCircle2;
        break;
      case StatusAlertVariant.error:
        bgColor = isDark
            ? AppColors.statusOverdueBgDark
            : AppColors.statusOverdueBgLight;
        borderColor = isDark
            ? AppColors.statusOverdueBorderDark
            : AppColors.statusOverdueBorderLight;
        textColor = isDark
            ? AppColors.statusOverdueTextDark
            : AppColors.statusOverdueTextLight;
        iconData = LucideIcons.alertCircle;
        break;
      case StatusAlertVariant.warning:
        bgColor = isDark
            ? AppColors.statusPendingBgDark
            : AppColors.statusPendingBgLight;
        borderColor = isDark
            ? AppColors.statusPendingBorderDark
            : AppColors.statusPendingBorderLight;
        textColor = isDark
            ? AppColors.statusPendingTextDark
            : AppColors.statusPendingTextLight;
        iconData = LucideIcons.alertTriangle;
        break;
      case StatusAlertVariant.info:
        bgColor = isDark
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
        borderColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.3);
        textColor = Theme.of(context).colorScheme.primary;
        iconData = LucideIcons.info;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, size: 18, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
