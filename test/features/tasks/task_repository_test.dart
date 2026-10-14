import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_mobile/features/tasks/data/task_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late TaskRepository repository;

  setUp(() {
    mockDio = MockDio();
    repository = TaskRepository(mockDio);
  });

  group('TaskRepository response extraction tests', () {
    test('getTasksWithMeta extracts tasks and username from Laravel payload', () async {
      when(() => mockDio.get('/tasks')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/tasks'),
          data: {
            'message': 'Tasks retrieved successfully.',
            'data': {
              'tasks': [
                {
                  'id': 101,
                  'title': 'Test Task',
                  'description': 'Description',
                  'due_at': '2026-10-15T12:00:00Z',
                  'completed_at': null,
                }
              ],
              'username': 'Ephraim',
            },
          },
        ),
      );

      final result = await repository.getTasksWithMeta();
      expect(result.username, 'Ephraim');
      expect(result.tasks.length, 1);
      expect(result.tasks.first.id, 101);
      expect(result.tasks.first.title, 'Test Task');
    });

    test('createTask extracts task wrapped inside data.task', () async {
      when(() => mockDio.post('/tasks', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/tasks'),
          data: {
            'message': 'Task created successfully.',
            'data': {
              'task': {
                'id': 202,
                'title': 'Created Task',
                'description': 'Created Description',
                'due_at': '2026-10-16T15:00:00Z',
                'completed_at': null,
              },
            },
          },
        ),
      );

      final task = await repository.createTask(
        title: 'Created Task',
        description: 'Created Description',
        dueAt: DateTime.utc(2026, 10, 16, 15, 0),
      );

      expect(task.id, 202);
      expect(task.title, 'Created Task');
      expect(task.isCompleted, false);
    });

    test('toggleCompletion extracts task wrapped inside data.task', () async {
      when(() => mockDio.patch('/tasks/202/completion', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/tasks/202/completion'),
          data: {
            'message': 'Task completion updated successfully.',
            'data': {
              'task': {
                'id': 202,
                'title': 'Created Task',
                'due_at': '2026-10-16T15:00:00Z',
                'completed_at': '2026-10-14T05:00:00Z',
              },
            },
          },
        ),
      );

      final task = await repository.toggleCompletion(202);
      expect(task.id, 202);
      expect(task.isCompleted, true);
    });
  });
}
