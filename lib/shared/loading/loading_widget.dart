import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  final Color indicatorColor;
  final double size;
  final double strokeWidth;

  const LoadingWidget({
    super.key,
    this.indicatorColor = Colors.greenAccent,
    this.size = 50,
    this.strokeWidth = 4,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  bool _showIndicator = false;

  @override
  void initState() {
    super.initState();
    // Add a small delay to prevent the initial dot from showing
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _showIndicator = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use dark blue in light mode, otherwise use provided color or default
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final color = widget.indicatorColor == Colors.greenAccent
        ? (isLightMode ? const Color(0xFF1565C0) : Colors.greenAccent) // Dark blue for light mode
        : widget.indicatorColor;

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: _showIndicator
            ? CircularProgressIndicator(
                color: color,
                strokeWidth: widget.strokeWidth,
              )
            : const SizedBox.shrink(), // Show nothing until ready
      ),
    );
  }
}