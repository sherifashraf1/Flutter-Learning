import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../models/todo/todo_model.dart';
import '../../providers/todo_provider.dart';

// Provider for task details completed state
final taskDetailsCompletedProvider = StateProvider.autoDispose<bool>((ref) => false);

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final Todo todo;

  const TaskDetailsScreen({super.key, required this.todo});

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description,
    );
    // Initialize completed state in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskDetailsCompletedProvider.notifier).state = widget.todo.completed;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final completed = ref.read(taskDetailsCompletedProvider);
    final updated = widget.todo.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      completed: completed,
    );
    try {
      await ref.read(todoNotifierProvider.notifier).updateTodo(updated);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Optionally show a snackbar/toast to inform the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save changes')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = ref.watch(taskDetailsCompletedProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(title: const Text("Task Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: completed,
                  onChanged: (val) {
                    if (val == null) return;
                    ref.read(taskDetailsCompletedProvider.notifier).state = val;
                  },
                ),
                const Text("Mark as completed"),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text("Save Changes"),
        ),
      ),
    );
  }
}
