import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final bottomSheetButtonEnabledProvider = StateProvider.autoDispose.family<bool, bool>((ref, initialValue) => initialValue);

void showTodoBottomSheet({
  required BuildContext context,
  required String title,
  String? existingTitle,
  String? existingDescription,
  required void Function(String title, String description) onSave,
}) {
  final titleController = TextEditingController(text: existingTitle ?? '');
  final descriptionController = TextEditingController(text: existingDescription ?? '');
  final hasExistingContent = (existingTitle ?? '').trim().isNotEmpty ||
      (existingDescription ?? '').trim().isNotEmpty;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _BottomSheetContent(
      title: title,
      titleController: titleController,
      descriptionController: descriptionController,
      isSaveButtonEnabled: hasExistingContent,
      onSave: onSave,
    ),
  );
}

class _BottomSheetContent extends ConsumerStatefulWidget {
  final String title;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool isSaveButtonEnabled;
  final void Function(String title, String description) onSave;

  const _BottomSheetContent({
    required this.title,
    required this.titleController,
    required this.descriptionController,
    required this.isSaveButtonEnabled,
    required this.onSave,
  });

  @override
  ConsumerState<_BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends ConsumerState<_BottomSheetContent> {
  @override
  Widget build(BuildContext context) {
    final isSaveButtonEnabled = ref.watch(bottomSheetButtonEnabledProvider(widget.isSaveButtonEnabled));

    void updateButtonState() {
      ref.read(bottomSheetButtonEnabledProvider(widget.isSaveButtonEnabled).notifier).state =
          widget.titleController.text.trim().isNotEmpty ||
              widget.descriptionController.text.trim().isNotEmpty;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                behavior: HitTestBehavior.translucent,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: widget.titleController,
                        onChanged: (_) => updateButtonState(),
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: widget.descriptionController,
                        onChanged: (_) => updateButtonState(),
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    final isDarkMode = theme.brightness == Brightness.dark;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.black : Colors.white,
                        backgroundColor: isSaveButtonEnabled
                            ? (isDarkMode ? Colors.white : Colors.orangeAccent)
                            : Colors.grey,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: isSaveButtonEnabled
                          ? () {
                        Navigator.pop(context);
                        widget.onSave(
                          widget.titleController.text.trim(),
                          widget.descriptionController.text.trim(),
                        );
                      }
                          : null,
                      child: const Text('Save',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
