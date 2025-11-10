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

  Future<void> _loadTodos() async {
    try {
      // Wait a bit to ensure box is ready
      await Future.delayed(const Duration(milliseconds: 50));
      final box = _box;
      final List<Todo> todos = [];
      final List<String> failedKeys = [];
      
      for (var key in box.keys) {
        try {
          final value = box.get(key);
          if (value != null) {
            final todo = Todo.fromMap(Map<String, dynamic>.from(value));
            todos.add(todo);
          }
        } catch (e, stackTrace) {
          // Log error for individual todo item with context
          failedKeys.add(key.toString());
          SecureErrorHandler.logError(
            e,
            context: 'Loading todo with key: $key',
            stackTrace: stackTrace,
          );
          // Continue loading other todos even if one fails
          continue;
        }
      }

      // Log summary if any items failed to load
      if (failedKeys.isNotEmpty) {
        SecureErrorHandler.logError(
          'Failed to load ${failedKeys.length} todo(s)',
          context: '_loadTodos - initial attempt',
        );
        if (kDebugMode) {
          debugPrint('Failed todo keys: $failedKeys');
        }
      }

      state = todos;
    } catch (e, stackTrace) {
      // Log the initial error with full context
      SecureErrorHandler.logError(
        e,
        context: '_loadTodos - initial attempt failed, retrying...',
        stackTrace: stackTrace,
      );
      
      // Retry after a delay with diagnostics
      await Future.delayed(const Duration(milliseconds: 200));
      
      try {
        final box = _box;
        final List<Todo> todos = [];
        final List<String> failedKeys = [];
        
        for (var key in box.keys) {
          try {
            final value = box.get(key);
            if (value != null) {
              final todo = Todo.fromMap(Map<String, dynamic>.from(value));
              todos.add(todo);
            }
          } catch (e, stackTrace) {
            // Log error for individual todo item in retry
            failedKeys.add(key.toString());
            SecureErrorHandler.logError(
              e,
              context: 'Loading todo with key: $key (retry attempt)',
              stackTrace: stackTrace,
            );
            continue;
          }
        }
        
        // Log retry summary
        if (failedKeys.isNotEmpty) {
          SecureErrorHandler.logError(
            'Retry: Failed to load ${failedKeys.length} todo(s)',
            context: '_loadTodos - retry attempt',
          );
          if (kDebugMode) {
            debugPrint('Failed todo keys on retry: $failedKeys');
          }
        } else {
          if (kDebugMode) {
            debugPrint('Retry successful: Loaded ${todos.length} todos');
          }
        }
        
        state = todos;
      } catch (e2, stackTrace2) {
        // Log final failure with full context
        SecureErrorHandler.logError(
          e2,
          context: '_loadTodos - retry attempt also failed, initializing empty state',
          stackTrace: stackTrace2,
        );
        
        // Gracefully degrade to empty state
        state = [];
        
        // Log audit event for critical failure
        await _auditLogService.logEvent(
          action: 'load',
          entityType: 'todo',
          entityId: 'all',
          outcome: 'failure',
          errorMessage: 'Failed to load todos after retry: ${e2.toString()}',
          metadata: {
            'initialError': e.toString(),
            'retryError': e2.toString(),
          },
        );
      }
    }
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