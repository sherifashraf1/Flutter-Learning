import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

        if (imageUrl != null && imageUrl!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: fit,
            placeholder: (context, url) => const SizedBox.shrink(),
            errorWidget: (context, url, error) {
              // Log error for debugging (in production, use proper logging)
              debugPrint('Image load error: $error');
              return Container(
                color: Colors.grey.shade800,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.red,
                    size: 100,
                  ),
                ),
              );
            },
            // Add headers for better security
            httpHeaders: const {
              'User-Agent': 'Flutter Movie App',
            },
            // Enable caching with high resolution
            memCacheWidth: null, 
            memCacheHeight: null,
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
