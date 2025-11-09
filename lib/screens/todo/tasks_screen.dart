import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo/todo_model.dart';
import '../../providers/todo_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/todo/task_card.dart';
import '../../widgets/todo/reusable_bottom_sheet.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo Task'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTaskBottomSheet(),
        child: const Icon(Icons.add),
      ),
      body: Consumer(
        builder: (context, wiRef, child) {
          final todos = wiRef.watch(todoNotifierProvider);

          if (todos.isEmpty) {
            return const Center(
              child: Text("No todos yet..", style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return Dismissible(
                key: Key(todo.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return true;
                },
                background: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                onDismissed: (direction) {
                  ref.read(todoNotifierProvider.notifier).removeTodo(todo.id);
                },
                child: TaskCard(
                  todo: todo,
                  onTap: () => showTaskDetails(todo),
                  onComplete: () => onCompleteTask(ref, todo),
                  onDelete: () async {
                    final shouldDelete = await showCupertinoDialog<bool>(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Delete Todo'),
                        content: const Text(
                          'Are you sure you want to delete this task?',
                        ),
                        actions: [
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    );
                    if (shouldDelete == true) {
                      ref.read(todoNotifierProvider.notifier).removeTodo(todo.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  showAddTaskBottomSheet() {
    showReusableBottomSheet(
      context: context,
      title: "Add Todo Task",
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      onSave: (title, description) {
        ref.read(todoNotifierProvider.notifier).addTodo(title, description);
      },
    );
  }

  showTaskDetails(Todo todo) {
    Navigator.pushNamed(context, AppRouter.taskDetails, arguments: todo);
  }

  onCompleteTask(WidgetRef ref, Todo todo) {
    ref.read(todoNotifierProvider.notifier)
        .toggleTodoCompletion(todo.id);
  }
}
