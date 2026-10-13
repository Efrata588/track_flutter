import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_mobile/features/tasks/data/task_model.dart';
import 'package:task_manager_mobile/features/tasks/state/categorized_tasks_provider.dart';

void main() {
  group('Task Categorization Tests', () {
    final referenceTime = DateTime(2026, 10, 13, 14, 0, 0); // 2:00 PM local

    test('categorizes empty tasks list', () {
      final categorized = categorizeTasks([], referenceTime);
      expect(categorized.totalCount, equals(0));
      expect(categorized.isEmpty, isTrue);
      expect(categorized.today, isEmpty);
      expect(categorized.upcoming, isEmpty);
      expect(categorized.pastDue, isEmpty);
      expect(categorized.completed, isEmpty);
    });

    test('due in 1 minute is categorized as Today', () {
      final task = Task(
        id: 1,
        title: 'Due in 1 min',
        dueAt: referenceTime.add(const Duration(minutes: 1)),
        isCompleted: false,
      );

      final categorized = categorizeTasks([task], referenceTime);
      expect(categorized.today.length, equals(1));
      expect(categorized.today.first.id, equals(1));
      expect(categorized.upcoming, isEmpty);
      expect(categorized.pastDue, isEmpty);
      expect(categorized.completed, isEmpty);
    });

    test('due later today (e.g. 8:00 PM) is categorized as Today', () {
      final task = Task(
        id: 2,
        title: 'Later today',
        dueAt: DateTime(2026, 10, 13, 20, 0, 0),
        isCompleted: false,
      );

      final categorized = categorizeTasks([task], referenceTime);
      expect(categorized.today.length, equals(1));
      expect(categorized.today.first.id, equals(2));
      expect(categorized.upcoming, isEmpty);
      expect(categorized.pastDue, isEmpty);
      expect(categorized.completed, isEmpty);
    });

    test('due tomorrow is categorized as Upcoming', () {
      final task = Task(
        id: 3,
        title: 'Tomorrow morning',
        dueAt: DateTime(2026, 10, 14, 9, 0, 0),
        isCompleted: false,
      );

      final categorized = categorizeTasks([task], referenceTime);
      expect(categorized.upcoming.length, equals(1));
      expect(categorized.upcoming.first.id, equals(3));
      expect(categorized.today, isEmpty);
      expect(categorized.pastDue, isEmpty);
      expect(categorized.completed, isEmpty);
    });

    test('due yesterday is categorized as Past Due', () {
      final task = Task(
        id: 4,
        title: 'Overdue from yesterday',
        dueAt: DateTime(2026, 10, 12, 17, 0, 0),
        isCompleted: false,
      );

      final categorized = categorizeTasks([task], referenceTime);
      expect(categorized.pastDue.length, equals(1));
      expect(categorized.pastDue.first.id, equals(4));
      expect(categorized.today, isEmpty);
      expect(categorized.upcoming, isEmpty);
      expect(categorized.completed, isEmpty);
    });

    test('completed overdue task belongs to Completed, NOT Past Due', () {
      final task = Task(
        id: 5,
        title: 'Completed overdue',
        dueAt: DateTime(2026, 10, 10, 10, 0, 0),
        completedAt: DateTime(2026, 10, 11, 12, 0, 0),
        isCompleted: true,
      );

      final categorized = categorizeTasks([task], referenceTime);
      expect(categorized.completed.length, equals(1));
      expect(categorized.completed.first.id, equals(5));
      expect(categorized.pastDue, isEmpty);
      expect(categorized.today, isEmpty);
      expect(categorized.upcoming, isEmpty);
    });

    test('midnight crossover: due at 23:59:59 is Today, due at 00:00:00 next day is Upcoming', () {
      final dueTodayEnd = Task(
        id: 6,
        title: 'End of today',
        dueAt: DateTime(2026, 10, 13, 23, 59, 59),
        isCompleted: false,
      );
      final dueTomorrowStart = Task(
        id: 7,
        title: 'Start of tomorrow',
        dueAt: DateTime(2026, 10, 14, 0, 0, 0),
        isCompleted: false,
      );

      final categorized = categorizeTasks([dueTodayEnd, dueTomorrowStart], referenceTime);
      expect(categorized.today.length, equals(1));
      expect(categorized.today.first.id, equals(6));
      expect(categorized.upcoming.length, equals(1));
      expect(categorized.upcoming.first.id, equals(7));
    });

    test('preserves server list ordering within each category', () {
      final t1 = Task(
        id: 10,
        title: 'First server item (Today)',
        dueAt: DateTime(2026, 10, 13, 16, 0),
        isCompleted: false,
      );
      final t2 = Task(
        id: 9,
        title: 'Second server item (Today)',
        dueAt: DateTime(2026, 10, 13, 15, 0),
        isCompleted: false,
      );

      final categorized = categorizeTasks([t1, t2], referenceTime);
      expect(categorized.today.map((e) => e.id).toList(), equals([10, 9]));
    });
  });
}
