import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/task_model.dart';
import 'clock_provider.dart';
import 'tasks_controller.dart';

/// Categorized collection of tasks matching the web app's categorization rules.
class CategorizedTasks {
  final List<Task> today;
  final List<Task> upcoming;
  final List<Task> pastDue;
  final List<Task> completed;
  final int totalCount;

  const CategorizedTasks({
    required this.today,
    required this.upcoming,
    required this.pastDue,
    required this.completed,
    required this.totalCount,
  });

  bool get isEmpty => totalCount == 0;
}

/// Checks whether a task's due date is in the past compared to the given reference time.
bool isPastDue(Task task, DateTime now) {
  return task.dueAt.isBefore(now);
}

/// Compares two DateTime instances by local year, month, and day.
bool isSameDay(DateTime a, DateTime b) {
  final aLocal = a.toLocal();
  final bLocal = b.toLocal();
  return aLocal.year == bLocal.year &&
      aLocal.month == bLocal.month &&
      aLocal.day == bLocal.day;
}

/// Pure helper to categorize a list of tasks given a reference timestamp [now].
/// Preserves the existing order of the list within each category.
CategorizedTasks categorizeTasks(List<Task> tasks, DateTime now) {
  final today = <Task>[];
  final upcoming = <Task>[];
  final pastDue = <Task>[];
  final completed = <Task>[];

  for (final task in tasks) {
    if (task.isCompleted || task.completedAt != null) {
      completed.add(task);
    } else if (isPastDue(task, now)) {
      pastDue.add(task);
    } else if (isSameDay(task.dueAt, now)) {
      // Due today and not past due
      today.add(task);
    } else {
      // Not completed, not past due, not same day -> upcoming
      upcoming.add(task);
    }
  }

  return CategorizedTasks(
    today: today,
    upcoming: upcoming,
    pastDue: pastDue,
    completed: completed,
    totalCount: tasks.length,
  );
}

/// Riverpod provider deriving [CategorizedTasks] from tasks and clock ticks.
final categorizedTasksProvider = Provider<AsyncValue<CategorizedTasks>>((ref) {
  final tasksAsync = ref.watch(tasksControllerProvider);
  final now = ref.watch(clockProvider);

  return tasksAsync.whenData((tasks) => categorizeTasks(tasks, now));
});
