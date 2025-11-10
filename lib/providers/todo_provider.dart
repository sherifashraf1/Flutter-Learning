import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo/todo_model.dart';
import '../services/audit/audit_log_service.dart';
import '../utils/secure_error_handler.dart';

final todoNotifierProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

class TodoNotifier extends StateNotifier<List<Todo>> {
  Box? _todoBox;
  final AuditLogService _auditLogService = AuditLogService();

  Box get _box {
    _todoBox ??= Hive.box('todosBox');
    return _todoBox!;
  }

  TodoNotifier(): super([]) {
    _loadTodos();
  }

  void _loadTodos() {
    // Since Hive box is guaranteed to be open from main(),
    // we can load synchronously without delays or retries.
    try {
      state = _readTodosFromBox();
    } catch (e, stackTrace) {
      // Log critical error and initialize with empty state
      SecureErrorHandler.logError(
        e,
        context: '_loadTodos - failed to load todos',
        stackTrace: stackTrace,
      );
      state = [];
    }
  }

  List<Todo> _readTodosFromBox() {
    final box = _box;
    final List<Todo> todos = [];
    
    for (var key in box.keys) {
      try {
        final value = box.get(key);
        if (value is Map) {
          final todo = Todo.fromMap(Map<String, dynamic>.from(value));
          todos.add(todo);
        } else if (value != null) {
          SecureErrorHandler.logError(
            'Unexpected todo value type: ${value.runtimeType}',
            context: 'Loading todo with key: $key',
          );
        }
      } catch (e, stackTrace) {
        // Log error for individual todo item but continue loading others
        SecureErrorHandler.logError(
          e,
          context: 'Loading todo with key: $key',
          stackTrace: stackTrace,
        );
        continue;
      }
    }
    
    return todos;
  }

  Future<void> addTodo(String title, String description) async {
    try {
      final box = _box;
      final todo = Todo(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title,
          description: description
      );
      await box.put(todo.id, todo.toMap());
      state = [...state, todo];
      
      // Audit log: successful creation
      await _auditLogService.logEvent(
        action: 'create',
        entityType: 'todo',
        entityId: todo.id,
        outcome: 'success',
        metadata: {
          'title': title,
          'description': description,
        },
      );
    } catch (e) {
      // Audit log: failed creation
      await _auditLogService.logEvent(
        action: 'create',
        entityType: 'todo',
        entityId: 'unknown',
        outcome: 'failure',
        errorMessage: e.toString(),
        metadata: {
          'title': title,
          'description': description,
        },
      );
      rethrow;
    }
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    try {
      final box = _box;
      final oldTodo = state.firstWhere((t) => t.id == updatedTodo.id);
      
      await box.put(updatedTodo.id, updatedTodo.toMap());
      state = [
        for (final t in state)
          if (t.id == updatedTodo.id) updatedTodo else t
      ];
      
      // Audit log: successful update
      await _auditLogService.logEvent(
        action: 'update',
        entityType: 'todo',
        entityId: updatedTodo.id,
        outcome: 'success',
        metadata: {
          'oldTitle': oldTodo.title,
          'newTitle': updatedTodo.title,
          'oldDescription': oldTodo.description,
          'newDescription': updatedTodo.description,
          'oldCompleted': oldTodo.completed,
          'newCompleted': updatedTodo.completed,
        },
      );
    } catch (e) {
      // Audit log: failed update
      await _auditLogService.logEvent(
        action: 'update',
        entityType: 'todo',
        entityId: updatedTodo.id,
        outcome: 'failure',
        errorMessage: e.toString(),
        metadata: {
          'title': updatedTodo.title,
          'description': updatedTodo.description,
        },
      );
      rethrow;
    }
  }

  Future<void> removeTodo(String id) async {
    try {
      final box = _box;
      final todo = state.firstWhere((t) => t.id == id);
      
      await box.delete(id);
      state = state.where((t) => t.id != id).toList();
      
      // Audit log: successful deletion
      await _auditLogService.logEvent(
        action: 'delete',
        entityType: 'todo',
        entityId: id,
        outcome: 'success',
        metadata: {
          'title': todo.title,
          'description': todo.description,
          'completed': todo.completed,
        },
      );
    } catch (e) {
      // Audit log: failed deletion
      await _auditLogService.logEvent(
        action: 'delete',
        entityType: 'todo',
        entityId: id,
        outcome: 'failure',
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> toggleTodoCompletion(String id) async {
    try {
      final box = _box;
      final todo = state.firstWhere((t) => t.id == id);
      final updated = todo.copyWith(completed: !todo.completed);
      
      await box.put(id, updated.toMap());
      state = [
        for (final t in state)
          if(t.id == id) updated else t
      ];
      
      // Audit log: successful toggle
      await _auditLogService.logEvent(
        action: 'toggle',
        entityType: 'todo',
        entityId: id,
        outcome: 'success',
        metadata: {
          'title': todo.title,
          'oldCompleted': todo.completed,
          'newCompleted': updated.completed,
        },
      );
    } catch (e) {
      // Audit log: failed toggle
      await _auditLogService.logEvent(
        action: 'toggle',
        entityType: 'todo',
        entityId: id,
        outcome: 'failure',
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}