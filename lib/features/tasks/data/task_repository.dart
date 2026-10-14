import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'task_model.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(dioProvider));
});

class TaskRepository {
  final Dio _dio;

  TaskRepository(this._dio);

  Task _extractTask(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        if (data['task'] is Map<String, dynamic>) {
          return Task.fromJson(data['task'] as Map<String, dynamic>);
        }
        return Task.fromJson(data);
      }
      if (raw['task'] is Map<String, dynamic>) {
        return Task.fromJson(raw['task'] as Map<String, dynamic>);
      }
      return Task.fromJson(raw);
    }
    throw const ServerException('Malformed task response from server.');
  }

  List<Task> _extractTaskList(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        if (data['tasks'] is List) {
          return (data['tasks'] as List)
              .map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      if (data is List) {
        return data
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (raw['tasks'] is List) {
        return (raw['tasks'] as List)
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    if (raw is List) {
      return raw
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<({List<Task> tasks, String? username})> getTasksWithMeta() async {
    try {
      final response = await _dio.get('/tasks');
      final tasks = _extractTaskList(response.data);
      String? username;
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'];
        if (data is Map<String, dynamic> && data['username'] is String) {
          username = data['username'] as String;
        } else if (response.data['username'] is String) {
          username = response.data['username'] as String;
        }
      }
      return (tasks: tasks, username: username);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw mapDioException(e);
    }
  }

  Future<List<Task>> getTasks() async {
    final result = await getTasksWithMeta();
    return result.tasks;
  }

  Future<Task> createTask({
    required String title,
    String? description,
    required DateTime dueAt,
  }) async {
    try {
      // Convert picked local date/time to UTC and send an ISO 8601 string to the server.
      final payload = {
        'title': title,
        'description': description,
        'due_at': dueAt.toUtc().toIso8601String(),
      };

      final response = await _dio.post('/tasks', data: payload);
      return _extractTask(response.data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw mapDioException(e);
    }
  }

  Future<Task> updateTask({
    required int id,
    required String title,
    String? description,
    required DateTime dueAt,
  }) async {
    try {
      // Convert picked local date/time to UTC and send an ISO 8601 string to the server.
      final payload = {
        'title': title,
        'description': description,
        'due_at': dueAt.toUtc().toIso8601String(),
      };

      final response = await _dio.patch('/tasks/$id', data: payload);
      return _extractTask(response.data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw mapDioException(e);
    }
  }

  Future<Task> toggleCompletion(int id) async {
    try {
      final response = await _dio.patch('/tasks/$id/completion', data: {});
      return _extractTask(response.data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw mapDioException(e);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _dio.delete('/tasks/$id');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw mapDioException(e);
    }
  }
}
