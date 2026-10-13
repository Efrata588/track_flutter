import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/task_model.dart';
import '../data/task_repository.dart';

final tasksControllerProvider =
    AsyncNotifierProvider<TasksController, List<Task>>(TasksController.new);

class TasksController extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return _fetch();
  }

  Future<List<Task>> _fetch() async {
    final repository = ref.read(taskRepositoryProvider);
    return repository.getTasks();
  }

  Future<void> refresh() async {
    // Keep previous data while reloading if available to prevent flashing
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<Task> createTask({
    required String title,
    String? description,
    required DateTime dueAt,
  }) async {
    final repository = ref.read(taskRepositoryProvider);
    final created = await repository.createTask(
      title: title,
      description: description,
      dueAt: dueAt,
    );

    state = state.whenData((tasks) => [created, ...tasks]);
    return created;
  }

  Future<Task> updateTask({
    required int id,
    required String title,
    String? description,
    required DateTime dueAt,
  }) async {
    final repository = ref.read(taskRepositoryProvider);
    final updated = await repository.updateTask(
      id: id,
      title: title,
      description: description,
      dueAt: dueAt,
    );

    state = state.whenData((tasks) =>
        tasks.map((t) => t.id == id ? updated : t).toList());
    return updated;
  }

  Future<void> toggleCompletion(int id) async {
    final previousState = state;
    final currentTasks = state.asData?.value ?? [];
    final targetIndex = currentTasks.indexWhere((t) => t.id == id);
    if (targetIndex == -1) return;

    final target = currentTasks[targetIndex];
    final optimisticCompleted = !target.isCompleted;
    final optimisticTask = target.copyWith(
      isCompleted: optimisticCompleted,
      completedAt: optimisticCompleted ? DateTime.now() : null,
      clearCompletedAt: !optimisticCompleted,
    );

    // Optimistically update
    final updatedList = List<Task>.from(currentTasks);
    updatedList[targetIndex] = optimisticTask;
    state = AsyncValue.data(updatedList);

    try {
      final serverTask =
          await ref.read(taskRepositoryProvider).toggleCompletion(id);
      state = state.whenData((tasks) =>
          tasks.map((t) => t.id == id ? serverTask : t).toList());
    } catch (e) {
      // Roll back immediately
      state = previousState;
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    final previousState = state;
    final currentTasks = state.asData?.value ?? [];
    final targetIndex = currentTasks.indexWhere((t) => t.id == id);
    if (targetIndex == -1) return;

    // Optimistically remove
    state = AsyncValue.data(currentTasks.where((t) => t.id != id).toList());

    try {
      await ref.read(taskRepositoryProvider).deleteTask(id);
    } catch (e) {
      // Roll back immediately
      state = previousState;
      rethrow;
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
