class AuditLog {
  final String id;
  final String action; // 'create', 'update', 'delete', 'toggle'
  final String entityType; // 'todo'
  final String entityId;
  final String? userId; // For future multi-user support
  final DateTime timestamp;
  final String outcome; // 'success', 'failure'
  final String? errorMessage;
  final Map<String, dynamic>? metadata; // Additional context

  AuditLog({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.userId,
    required this.timestamp,
    required this.outcome,
    this.errorMessage,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'outcome': outcome,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] as String,
      action: map['action'] as String,
      entityType: map['entityType'] as String,
      entityId: map['entityId'] as String,
      userId: map['userId'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      outcome: map['outcome'] as String,
      errorMessage: map['errorMessage'] as String?,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }
}

