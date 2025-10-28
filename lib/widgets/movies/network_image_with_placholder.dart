import 'package:flutter/material.dart';

class NetworkImageWithPlaceholder extends StatelessWidget {
  final String? imageUrl;
  final String placeholder;
  final double? height;
  final double? width;
  final double? aspectRatio;
  final BoxFit fit;

  const NetworkImageWithPlaceholder({
    super.key,
    required this.imageUrl,
    required this.placeholder,
    this.height,
    this.width,
    this.aspectRatio,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageContent = Stack(
      fit: StackFit.expand,
      children: [
        // Placeholder
        Image.asset(
          placeholder,
          fit: fit,
        ),

        if (imageUrl != null)
          Image.network(
            imageUrl!,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox.shrink();
            },
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
      ],
    );

    if (aspectRatio != null) {
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: imageContent,
      );
    } else {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? 100,
        child: imageContent,
      );
    }
  }
}
