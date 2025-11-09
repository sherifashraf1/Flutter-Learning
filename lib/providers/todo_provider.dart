import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo/todo_model.dart';

final todoNotifierProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

class TodoNotifier extends StateNotifier<List<Todo>> {
  Box? _todoBox;

  Box get _box {
    _todoBox ??= Hive.box('todosBox');
    return _todoBox!;
  }

  TodoNotifier(): super([]) {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      // Wait a bit to ensure box is ready
      await Future.delayed(const Duration(milliseconds: 50));
      final box = _box;
      final List<Todo> todos = [];
      for (var key in box.keys) {
        try {
          final value = box.get(key);
          if (value != null) {
            final todo = Todo.fromMap(Map<String, dynamic>.from(value));
            todos.add(todo);
          }
        } catch (e) {
          continue;
        }
      }

      state = todos;
    } catch (e) {
      // Retry after a delay
      await Future.delayed(const Duration(milliseconds: 200));
      try {
        final box = _box;
        final List<Todo> todos = [];
        for (var key in box.keys) {
          try {
            final value = box.get(key);
            if (value != null) {
              final todo = Todo.fromMap(Map<String, dynamic>.from(value));
              todos.add(todo);
            }
          } catch (e) {
            continue;
          }
        }
        state = todos;
      } catch (e2) {
        state = [];
      }
    }
  }

  Future<void> addTodo(String title, String description) async {
    final box = _box;
    final todo = Todo(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        description: description
    );
    await box.put(todo.id, todo.toMap());
    state = [...state, todo];
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    final box = _box;
    await box.put(updatedTodo.id, updatedTodo.toMap());
    state = [
      for (final t in state)
        if (t.id == updatedTodo.id) updatedTodo else t
    ];
  }

  Future<void> removeTodo(String id) async {
    final box = _box;
    await box.delete(id);
    state = state.where((t) => t.id != id).toList();
  }

  Future<void> toggleTodoCompletion(String id) async {
    final box = _box;
    final todo = state.firstWhere((t) => t.id == id);
    final updated = todo.copyWith(completed: !todo.completed);
    await box.put(id, updated.toMap());
    state = [
      for (final t in state)
        if(t.id == id) updated else t
    ];
  }
}