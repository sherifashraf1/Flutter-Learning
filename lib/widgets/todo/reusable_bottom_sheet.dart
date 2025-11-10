import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final bottomSheetButtonEnabledProvider = StateProvider.autoDispose<bool>((ref) => false);

void showReusableBottomSheet({
  required BuildContext context,
  required String title,
  required void Function(String title, String description) onSave,
  // Customizable texts
  String? titleLabel,
  String? descriptionLabel,
  String? buttonText,
  // Customizable text styles
  TextStyle? titleTextStyle,
  TextStyle? buttonTextStyle,
  // Other customizable options
  double? bottomSheetHeight,
}) {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _BottomSheetContent(
      title: title,
      titleController: titleController,
      descriptionController: descriptionController,
      onSave: onSave,
      titleLabel: titleLabel,
      descriptionLabel: descriptionLabel,
      buttonText: buttonText,
      titleTextStyle: titleTextStyle,
      buttonTextStyle: buttonTextStyle,
      bottomSheetHeight: bottomSheetHeight,
    ),
  );
}

class _BottomSheetContent extends ConsumerStatefulWidget {
  final String title;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final void Function(String title, String description) onSave;
  // Customizable texts
  final String? titleLabel;
  final String? descriptionLabel;
  final String? buttonText;
  // Customizable text styles
  final TextStyle? titleTextStyle;
  final TextStyle? buttonTextStyle;
  // Other customizable options
  final double? bottomSheetHeight;

  const _BottomSheetContent({
    required this.title,
    required this.titleController,
    required this.descriptionController,
    required this.onSave,
    this.titleLabel,
    this.descriptionLabel,
    this.buttonText,
    this.titleTextStyle,
    this.buttonTextStyle,
    this.bottomSheetHeight,
  });

  @override
  ConsumerState<_BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends ConsumerState<_BottomSheetContent> {
  @override
  Widget build(BuildContext context) {
    final isSaveButtonEnabled = ref.watch(bottomSheetButtonEnabledProvider);

    void updateButtonState() {
      ref.read(bottomSheetButtonEnabledProvider.notifier).state =
          widget.titleController.text.trim().isNotEmpty ||
          widget.descriptionController.text.trim().isNotEmpty;
    }

    final defaultTitleStyle = widget.titleTextStyle ??
        const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        );
    final defaultButtonTextStyle = widget.buttonTextStyle ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: widget.bottomSheetHeight ?? MediaQuery.of(context).size.height * 0.5,
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
                        style: defaultTitleStyle,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: widget.titleController,
                        onChanged: (_) => updateButtonState(),
                        decoration: InputDecoration(
                          labelText: widget.titleLabel ?? 'Title',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: widget.descriptionController,
                        onChanged: (_) => updateButtonState(),
                        decoration: InputDecoration(
                          labelText: widget.descriptionLabel ?? 'Description',
                          border: const OutlineInputBorder(),
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
                      child: Text(
                        widget.buttonText ?? 'Save',
                        style: defaultButtonTextStyle,
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
