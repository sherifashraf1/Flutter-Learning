import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: indicatorColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}