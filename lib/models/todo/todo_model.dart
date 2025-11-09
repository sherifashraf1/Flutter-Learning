class Todo {
  final String id;
  final String title;
  final String description;
  final bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
  });

  Todo copyWith({String? id, String? title, String? description, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }

  // Convert Todo -> Map (for Hive)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed
    };
  }

  // Convert Map -> Todo
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        completed: map['completed'] as bool? ?? false
    );
  }
}
