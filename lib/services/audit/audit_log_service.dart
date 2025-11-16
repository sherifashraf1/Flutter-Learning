import 'package:hive_flutter/hive_flutter.dart';
import '../../models/audit/audit_log_model.dart';
import '../../utils/secure_error_handler.dart';

class AuditLogService {
  static const String _boxName = 'auditLogsBox';
  Box? _auditBox;

  /// Safely opens the Hive box asynchronously
  /// Checks if box is already open before attempting to open it
  Future<Box> get _boxAsync async {
    // Return cached box if it's open
    if (_auditBox?.isOpen == true) {
      return _auditBox!;
    }
    
    // Check if box is already open by another instance
    if (!Hive.isBoxOpen(_boxName)) {
      // Box is not open, open it asynchronously
      _auditBox = await Hive.openBox(_boxName);
    } else {
      // Box is open, get the existing instance
      _auditBox = Hive.box(_boxName);
    }
    
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

      final box = await _boxAsync;
      await box.put(auditLog.id, auditLog.toMap());
    } catch (e, stackTrace) {
      // Silently fail audit logging to not break the main functionality
      // In production, you might want to log this to a remote service
      SecureErrorHandler.logNonFatalError(
        e,
        context: 'logEvent - failed to log audit event',
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets all audit logs
  Future<List<AuditLog>> getAllLogs() async {
    try {
      final box = await _boxAsync;
      final List<AuditLog> logs = [];
      for (var key in box.keys) {
        try {
          final value = box.get(key);
          if (value != null) {
            final log = AuditLog.fromMap(Map<String, dynamic>.from(value));
            logs.add(log);
          }
        } catch (_) {
          // Skip unreadable entries
          continue;
        }
      }
      // Sort by timestamp descending (newest first)
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    } catch (_) {
      return [];
    }
  }

  /// Gets audit logs for a specific entity
  Future<List<AuditLog>> getLogsForEntity(String entityId) async {
    final allLogs = await getAllLogs();
    return allLogs.where((log) => log.entityId == entityId).toList();
  }

  /// Gets audit logs for a specific action
  Future<List<AuditLog>> getLogsByAction(String action) async {
    final allLogs = await getAllLogs();
    return allLogs.where((log) => log.action == action).toList();
  }

  /// Clears old audit logs (optional cleanup method)
  /// Checks timestamp from the log value rather than parsing the key
  Future<void> clearOldLogs({int daysToKeep = 90}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final keysToDelete = <dynamic>[];
      final box = await _boxAsync;

      for (var key in box.keys) {
        try {
          final value = box.get(key);
          if (value == null) continue;
          
          // Read timestamp from the log value, not from the key
          final log = AuditLog.fromMap(Map<String, dynamic>.from(value));
          if (log.timestamp.isBefore(cutoffDate)) {
            keysToDelete.add(key);
          }
        } catch (_) {
          // Skip unreadable entries
          continue;
        }
      }

      if (keysToDelete.isNotEmpty) {
        await box.deleteAll(keysToDelete);
      }
    } catch (e, stackTrace) {
      SecureErrorHandler.logNonFatalError(
        e,
        context: 'clearOldLogs - failed to clear old audit logs',
        stackTrace: stackTrace,
      );
    }
  }
}

