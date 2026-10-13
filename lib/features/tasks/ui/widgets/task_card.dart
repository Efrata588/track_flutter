import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/task_model.dart';
import '../../state/categorized_tasks_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final DateTime now;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.now,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDueDate(DateTime dueAt) {
    try {
      final local = dueAt.toLocal();
      return DateFormat('MMM d, y, h:mm a').format(local);
    } catch (_) {
      return dueAt.toString();
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Delete Task'),
          content: Text(
            'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop(true);
                onDelete();
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final completed = task.isCompleted || task.completedAt != null;
    final overdue = !completed && isPastDue(task, now);

    // Badge styling matching the web design tokens
    Color badgeBg;
    Color badgeText;
    Color badgeBorder;
    String badgeLabel;

    if (completed) {
      badgeBg = isDark
          ? AppColors.statusCompletedBgDark
          : AppColors.statusCompletedBgLight;
      badgeText = isDark
          ? AppColors.statusCompletedTextDark
          : AppColors.statusCompletedTextLight;
      badgeBorder = isDark
          ? AppColors.statusCompletedBorderDark
          : AppColors.statusCompletedBorderLight;
      badgeLabel = 'Completed';
    } else if (overdue) {
      badgeBg = isDark
          ? AppColors.statusOverdueBgDark
          : AppColors.statusOverdueBgLight;
      badgeText = isDark
          ? AppColors.statusOverdueTextDark
          : AppColors.statusOverdueTextLight;
      badgeBorder = isDark
          ? AppColors.statusOverdueBorderDark
          : AppColors.statusOverdueBorderLight;
      badgeLabel = 'Overdue';
    } else {
      badgeBg = isDark
          ? AppColors.statusPendingBgDark
          : AppColors.statusPendingBgLight;
      badgeText = isDark
          ? AppColors.statusPendingTextDark
          : AppColors.statusPendingTextLight;
      badgeBorder = isDark
          ? AppColors.statusPendingBorderDark
          : AppColors.statusPendingBorderLight;
      badgeLabel = 'Pending';
    }

    return Opacity(
      opacity: completed ? 0.8 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: completed
              ? (isDark
                  ? AppColors.darkMuted.withValues(alpha: 0.4)
                  : AppColors.lightMuted.withValues(alpha: 0.6))
              : (theme.cardTheme.color ?? theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Delete action
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: completed
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (task.description != null &&
                          task.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!.trim(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Delete task',
                  icon: const Icon(LucideIcons.trash2, size: 16),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Middle Row: Due Date + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${_formatDueDate(task.dueAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeBorder),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Divider & Bottom Action buttons
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Complete / Undo toggle
                OutlinedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    completed
                        ? LucideIcons.checkCircle2
                        : LucideIcons.circle,
                    size: 14,
                    color: completed
                        ? (isDark
                            ? AppColors.statusCompletedTextDark
                            : AppColors.statusCompletedTextLight)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  label: Text(
                    completed ? 'Undo' : 'Complete',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: completed
                          ? (isDark
                              ? AppColors.statusCompletedTextDark
                              : AppColors.statusCompletedTextLight)
                          : null,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                // Edit button
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(LucideIcons.pencil, size: 14),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                    foregroundColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
