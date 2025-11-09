import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class network_image_with_placeholder extends StatelessWidget {
  final String? imageUrl;
  final String placeholder;
  final double? height;
  final double? width;
  final double? aspectRatio;
  final BoxFit fit;

  const network_image_with_placeholder({
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
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    Widget buildPlaceholder() => Image.asset(placeholder, fit: fit);

    Widget content = hasImage
        ? CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: fit,
            placeholder: (context, url) => buildPlaceholder(),
            errorWidget: (context, url, error) {
              debugPrint('Image load error: $error');
              return Container(
                color: Colors.grey.shade800,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.red, size: 100),
                ),
              );
            },
            httpHeaders: const {'User-Agent': 'Flutter Movie App'},
            memCacheWidth: null,
            memCacheHeight: null,
          )
        : buildPlaceholder();

    if (aspectRatio != null) {
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: content,
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 100,
      child: content,
    );
  }
}
