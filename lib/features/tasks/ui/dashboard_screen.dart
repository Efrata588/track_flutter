import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../auth/state/auth_controller.dart';
import '../../settings/ui/settings_drawer.dart';
import '../data/task_model.dart';
import '../state/categorized_tasks_provider.dart';
import '../state/clock_provider.dart';
import '../state/tasks_controller.dart';
import 'widgets/summary_metric_card.dart';
import 'widgets/task_card.dart';
import 'widgets/task_form_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).fetchCurrentUser();
    });
  }

  String _formatTodayDate(DateTime now) {
    return DateFormat('EEEE, MMM d').format(now);
  }

  Future<void> _openCreateTask(BuildContext context, WidgetRef ref) async {
    final created = await TaskFormSheet.show(context);
    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openEditTask(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final updated = await TaskFormSheet.show(context, task: task);
    if (updated == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleTask(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    try {
      await ref
          .read(tasksControllerProvider.notifier)
          .toggleCompletion(task.id);
    } catch (e) {
      if (context.mounted) {
        final message = e is ApiException
            ? e.message
            : 'Failed to update task.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    try {
      await ref.read(tasksControllerProvider.notifier).deleteTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final message = e is ApiException
            ? e.message
            : 'Failed to delete task.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).user;
    final now = ref.watch(clockProvider);
    final tasksAsync = ref.watch(tasksControllerProvider);
    final categorizedAsync = ref.watch(categorizedTasksProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [const AppLogo(size: 24), const SizedBox(width: 8)],
        ),
      ),
      drawer: const SettingsDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(tasksControllerProvider.notifier).refresh(),
              ref.read(authControllerProvider.notifier).fetchCurrentUser(),
            ]);
          },
          child: tasksAsync.when(
            loading: () => _buildLoadingSkeleton(context),
            error: (err, _) => _buildErrorState(context, ref, err),
            data: (tasks) {
              final categorized =
                  categorizedAsync.asData?.value ?? categorizeTasks(tasks, now);

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    children: [
                      // Dashboard Greeting Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, ${user?.name ?? 'there'}!',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.calendar,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTodayDate(now),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Text(
                                      ' • Here\'s an overview of your tasks.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            label: 'Add Task',
                            icon: const Icon(LucideIcons.plus, size: 16),
                            isFullWidth: false,
                            height: 38,
                            onPressed: () => _openCreateTask(context, ref),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Metric Summary Cards (2x2 grid)
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.45,
                        children: [
                          SummaryMetricCard(
                            title: 'Today',
                            count: categorized.today.length,
                            description: 'Due by end of today',
                            icon: LucideIcons.calendarDays,
                            iconColor: theme.colorScheme.primary,
                          ),
                          SummaryMetricCard(
                            title: 'Upcoming',
                            count: categorized.upcoming.length,
                            description: 'Scheduled for future days',
                            icon: LucideIcons.clock,
                            iconColor: const Color(0xFF3B82F6),
                          ),
                          SummaryMetricCard(
                            title: 'Past Due',
                            count: categorized.pastDue.length,
                            description: 'Requires immediate attention',
                            icon: LucideIcons.alertCircle,
                            iconColor: theme.colorScheme.error,
                            countColor: categorized.pastDue.isNotEmpty
                                ? theme.colorScheme.error
                                : null,
                          ),
                          SummaryMetricCard(
                            title: 'Completed',
                            count: categorized.completed.length,
                            description: 'Accomplished so far',
                            icon: LucideIcons.checkCircle2,
                            iconColor: const Color(0xFF10B981),
                            countColor: const Color(0xFF10B981),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Main Section Header: My Tasks
                      Text(
                        'My Tasks',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Global Empty State or Categorized Task Sections
                      if (tasks.isEmpty)
                        GlobalEmptyState(
                          onAddTask: () => {_openCreateTask(context, ref)},
                        )
                      else ...[
                        // 1. Today Category
                        _buildCategorySection(
                          context: context,
                          ref: ref,
                          title: 'Today',
                          tasks: categorized.today,
                          now: now,
                        ),
                        const SizedBox(height: 24),

                        // 2. Upcoming Category
                        _buildCategorySection(
                          context: context,
                          ref: ref,
                          title: 'Upcoming',
                          tasks: categorized.upcoming,
                          now: now,
                        ),
                        const SizedBox(height: 24),

                        // 3. Past Due Category
                        _buildCategorySection(
                          context: context,
                          ref: ref,
                          title: 'Past Due',
                          tasks: categorized.pastDue,
                          now: now,
                        ),
                        const SizedBox(height: 24),

                        // 4. Completed Category
                        _buildCategorySection(
                          context: context,
                          ref: ref,
                          title: 'Completed',
                          tasks: categorized.completed,
                          now: now,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required List<Task> tasks,
    required DateTime now,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Title & Count Badge
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${tasks.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: theme.colorScheme.onSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (tasks.isEmpty)
          const CategoryEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (ctx, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                now: now,
                onToggle: () => _toggleTask(context, ref, task),
                onEdit: () => _openEditTask(context, ref, task),
                onDelete: () => _deleteTask(context, ref, task),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 36,
              width: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: List.generate(
                4,
                (index) => Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              height: 24,
              width: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final theme = Theme.of(context);
    final message = error is ApiException
        ? error.message
        : 'Failed to load tasks. Please check your network connection.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load tasks',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(tasksControllerProvider.notifier).refresh(),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
