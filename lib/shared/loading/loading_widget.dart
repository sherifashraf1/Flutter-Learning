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
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: _showIndicator
            ? CircularProgressIndicator(
                color: widget.indicatorColor,
                strokeWidth: widget.strokeWidth,
              )
            : const SizedBox.shrink(), // Show nothing until ready
      ),
    );
  }
}