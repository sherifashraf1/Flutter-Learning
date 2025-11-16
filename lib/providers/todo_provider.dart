import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo/todo_model.dart';
import '../services/audit/audit_log_service.dart';
import '../utils/secure_error_handler.dart';

final todoNotifierProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

class TodoNotifier extends StateNotifier<List<Todo>> {
  static const String _todosStorageKey = 'todos_list';
  Box? _todoBox;
  final AuditLogService _auditLogService = AuditLogService();

  Box? get _box {
    if (kIsWeb) {
      // Hive is not supported on web
      return null;
    }
    _todoBox ??= Hive.box('todosBox');
    return _todoBox;
  }

  TodoNotifier(): super([]) {
    _loadTodos();
  }

  void _loadTodos() {
    if (kIsWeb) {
      // Use SharedPreferences for web (async, but we can't await in constructor)
      _loadTodosFromSharedPreferences();
      return;
    }
    
    // Since Hive box is guaranteed to be open from main(),
    // we can load synchronously without delays or retries.
    try {
      final todos = _readTodosFromBox();
      state = todos;
      
      // Audit log: successful read/list operation
      _auditLogService.logEvent(
        action: 'read',
        entityType: 'todo',
        entityId: 'all',
        userId: _getUserId(),
        outcome: 'success',
        metadata: {
          'count': todos.length,
          'operation': 'list',
        },
      );
    } catch (e, stackTrace) {
      // Log critical error and initialize with empty state
      SecureErrorHandler.logNonFatalError(
        e,
        context: '_loadTodos - failed to load todos',
        stackTrace: stackTrace,
      );
      state = [];
      
      // Audit log: failed read/list operation
      _auditLogService.logEvent(
        action: 'read',
        entityType: 'todo',
        entityId: 'all',
        userId: _getUserId(),
        outcome: 'failure',
        errorMessage: e.toString(),
        metadata: {
          'operation': 'list',
        },
      );
    }
  }

  /// Gets user identifier for audit logging
  /// In a multi-user app, this would return the actual user ID
  /// For now, returns a system identifier with device info
  String _getUserId() {
    try {
      if (kIsWeb) {
        return 'system_web';
      }
      // On non-web platforms, include operating system
      return 'system_${defaultTargetPlatform.name.toLowerCase()}';
    } catch (_) {
      return 'system';
    }
  }

  /// Loads todos from SharedPreferences (for web)
  Future<void> _loadTodosFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString(_todosStorageKey);
      
      if (todosJson == null || todosJson.isEmpty) {
        state = [];
        return;
      }
      
      final List<dynamic> todosList = jsonDecode(todosJson);
      final todos = todosList
          .map((json) => Todo.fromMap(Map<String, dynamic>.from(json)))
          .toList();
      
      state = todos;
      
      // Audit log: successful read/list operation
      _auditLogService.logEvent(
        action: 'read',
        entityType: 'todo',
        entityId: 'all',
        userId: _getUserId(),
        outcome: 'success',
        metadata: {
          'count': todos.length,
          'operation': 'list',
          'platform': 'web',
        },
      );
    } catch (e, stackTrace) {
      SecureErrorHandler.logNonFatalError(
        e,
        context: '_loadTodosFromSharedPreferences - failed to load todos',
        stackTrace: stackTrace,
      );
      state = [];
      
      // Audit log: failed read/list operation
      _auditLogService.logEvent(
        action: 'read',
        entityType: 'todo',
        entityId: 'all',
        userId: _getUserId(),
        outcome: 'failure',
        errorMessage: e.toString(),
        metadata: {
          'operation': 'list',
          'platform': 'web',
        },
      );
    }
  }

  /// Saves todos to SharedPreferences (for web)
  Future<void> _saveTodosToSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = jsonEncode(state.map((todo) => todo.toMap()).toList());
      await prefs.setString(_todosStorageKey, todosJson);
    } catch (e, stackTrace) {
      SecureErrorHandler.logNonFatalError(
        e,
        context: '_saveTodosToSharedPreferences - failed to save todos',
        stackTrace: stackTrace,
      );
    }
  }

  List<Todo> _readTodosFromBox() {
    final box = _box;
    if (box == null) {
      return [];
    }
    final List<Todo> todos = [];
    
    for (var key in box.keys) {
      try {
        final value = box.get(key);
        if (value is Map) {
          final todo = Todo.fromMap(Map<String, dynamic>.from(value));
          todos.add(todo);
        } else if (value != null) {
          SecureErrorHandler.logNonFatalError(
            'Unexpected todo value type: ${value.runtimeType}',
            context: 'Loading todo with key: $key',
            stackTrace: StackTrace.current,
          );
        }
      } catch (e, stackTrace) {
        // Log error for individual todo item but continue loading others
        SecureErrorHandler.logNonFatalError(
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
    final todo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: description,
    );
    
    if (kIsWeb) {
      // Use SharedPreferences for web
      state = [...state, todo];
      await _saveTodosToSharedPreferences();
      
      // Audit log: successful creation
      await _auditLogService.logEvent(
        action: 'create',
        entityType: 'todo',
        entityId: todo.id,
        userId: _getUserId(),
        outcome: 'success',
        metadata: {
          'title': title,
          'description': description,
        },
      );
      return;
    }
    
    try {
      final box = _box;
      if (box == null) return;
      
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
        userId: _getUserId(),
        outcome: 'success',
        metadata: {
          'title': title,
          'description': description,
        },
      );
    } catch (e, stackTrace) {
      // Log error for monitoring
      SecureErrorHandler.logNonFatalError(
        e,
        context: 'addTodo',
        stackTrace: stackTrace,
        additionalInfo: {'title': title, 'description': description},
      );
      // Audit log: failed creation
      await _auditLogService.logEvent(
        action: 'create',
        entityType: 'todo',
        entityId: 'unknown',
        userId: _getUserId(),
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
    if (kIsWeb) {
      // Use SharedPreferences for web
      final oldTodo = state.firstWhere((t) => t.id == updatedTodo.id);
      state = [
        for (final t in state)
          if (t.id == updatedTodo.id) updatedTodo else t
      ];
      await _saveTodosToSharedPreferences();
      
      // Audit log: successful update
      await _auditLogService.logEvent(
        action: 'update',
        entityType: 'todo',
        entityId: updatedTodo.id,
        userId: _getUserId(),
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
      return;
    }
    
    try {
      final box = _box;
      if (box == null) return;
      
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
        userId: _getUserId(),
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
    } catch (e, stackTrace) {
      // Log error for monitoring
      SecureErrorHandler.logNonFatalError(
        e,
        context: 'updateTodo',
        stackTrace: stackTrace,
        additionalInfo: {'todoId': updatedTodo.id},
      );
      // Audit log: failed update
      await _auditLogService.logEvent(
        action: 'update',
        entityType: 'todo',
        entityId: updatedTodo.id,
        userId: _getUserId(),
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
    if (kIsWeb) {
      // Use SharedPreferences for web
      final todo = state.firstWhere((t) => t.id == id);
      state = state.where((t) => t.id != id).toList();
      await _saveTodosToSharedPreferences();
      
      // Audit log: successful deletion
      await _auditLogService.logEvent(
        action: 'delete',
        entityType: 'todo',
        entityId: id,
        userId: _getUserId(),
        outcome: 'success',
        metadata: {
          'title': todo.title,
          'description': todo.description,
          'completed': todo.completed,
        },
      );
      return;
    }
    
    try {
      final box = _box;
      if (box == null) return;
      
      final todo = state.firstWhere((t) => t.id == id);
      
      await box.delete(id);
      state = state.where((t) => t.id != id).toList();
      
      // Audit log: successful deletion
      await _auditLogService.logEvent(
        action: 'delete',
        entityType: 'todo',
        entityId: id,
        userId: _getUserId(),
        outcome: 'success',
        metadata: {
          'title': todo.title,
          'description': todo.description,
          'completed': todo.completed,
        },
      );
    } catch (e, stackTrace) {
      // Log error for monitoring
      SecureErrorHandler.logNonFatalError(
        e,
        context: 'removeTodo',
        stackTrace: stackTrace,
        additionalInfo: {'todoId': id},
      );
      // Audit log: failed deletion
      await _auditLogService.logEvent(
        action: 'delete',
        entityType: 'todo',
        entityId: id,
        userId: _getUserId(),
        outcome: 'failure',
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> toggleTodoCompletion(String id) async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      final todo = state.firstWhere((t) => t.id == id);
      final updated = todo.copyWith(completed: !todo.completed);
      state = [
        for (final t in state)
          if (t.id == id) updated else t
      ];
      await _saveTodosToSharedPreferences();
      
      // Audit log: successful toggle
      await _auditLogService.logEvent(
        action: 'toggle',
        entityType: 'todo',
        entityId: id,
        userId: _getUserId(),
        outcome: 'success',
        metadata: {
          'title': todo.title,
          'oldCompleted': todo.completed,
          'newCompleted': updated.completed,
        },
      );
      return;
    }
    
    try {
      final box = _box;
      if (box == null) return;
      
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
        userId: _getUserId(),
        outcome: 'success',
        metadata: {
          'title': todo.title,
          'oldCompleted': todo.completed,
          'newCompleted': updated.completed,
        },
      );
    } catch (e, stackTrace) {
      // Log error for monitoring
      SecureErrorHandler.logNonFatalError(
        e,
        context: 'toggleTodoCompletion',
        stackTrace: stackTrace,
        additionalInfo: {'todoId': id},
      );
      // Audit log: failed toggle
      await _auditLogService.logEvent(
        action: 'toggle',
        entityType: 'todo',
        entityId: id,
        userId: _getUserId(),
        outcome: 'failure',
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}