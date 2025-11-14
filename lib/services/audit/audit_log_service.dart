import 'package:hive_flutter/hive_flutter.dart';
import '../../models/audit/audit_log_model.dart';
import '../../utils/secure_error_handler.dart';

class AuditLogService {
  static const String _boxName = 'auditLogsBox';
  Box? _auditBox;

  Box get _box {
    _auditBox ??= Hive.box(_boxName);
    return _auditBox!;
  }

  /// Logs an audit event
  Future<void> logEvent({
    required String action,
    required String entityType,
    required String entityId,
    String? userId,
    required String outcome,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final auditLog = AuditLog(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        action: action,
        entityType: entityType,
        entityId: entityId,
        userId: userId ?? 'system', // Default to 'system' for single-user app
        timestamp: DateTime.now(),
        outcome: outcome,
        errorMessage: errorMessage,
        metadata: metadata,
      );

      await _box.put(auditLog.id, auditLog.toMap());
    } catch (e, stackTrace) {
      // Silently fail audit logging to not break the main functionality
      // In production, you might want to log this to a remote service
      SecureErrorHandler.logError(
        e,
        context: 'logEvent - failed to log audit event',
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets all audit logs
  List<AuditLog> getAllLogs() {
    try {
      final List<AuditLog> logs = [];
      for (var key in _box.keys) {
        try {
          final value = _box.get(key);
          if (value != null) {
            final log = AuditLog.fromMap(Map<String, dynamic>.from(value));
            logs.add(log);
          }
        } catch (e) {
          continue;
        }
      }
      // Sort by timestamp descending (newest first)
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    } catch (e) {
      return [];
    }
  }

  /// Gets audit logs for a specific entity
  List<AuditLog> getLogsForEntity(String entityId) {
    final allLogs = getAllLogs();
    return allLogs.where((log) => log.entityId == entityId).toList();
  }

  /// Gets audit logs for a specific action
  List<AuditLog> getLogsByAction(String action) {
    final allLogs = getAllLogs();
    return allLogs.where((log) => log.action == action).toList();
  }

  /// Clears old audit logs (optional cleanup method)
  Future<void> clearOldLogs({int daysToKeep = 90}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final cutoffMicros = cutoffDate.microsecondsSinceEpoch;
      final keysToDelete = <dynamic>[];

      for (var key in _box.keys) {
        try {
          // The key is the timestamp in microseconds since epoch as a string.
          final logMicros = int.parse(key.toString());
          if (logMicros < cutoffMicros) {
            keysToDelete.add(key);
          }
        } catch (e) {
          // Fallback for keys that are not valid timestamps.
          final value = _box.get(key);
          if (value != null) {
            final log = AuditLog.fromMap(Map<String, dynamic>.from(value));
            if (log.timestamp.isBefore(cutoffDate)) {
              keysToDelete.add(key);
            }
          }
        }
      }

      if (keysToDelete.isNotEmpty) {
        await _box.deleteAll(keysToDelete);
      }
    } catch (e, stackTrace) {
      SecureErrorHandler.logError(
        e,
        context: 'clearOldLogs - failed to clear old audit logs',
        stackTrace: stackTrace,
      );
    }
  }
}

