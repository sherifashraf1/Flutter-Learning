import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../movies/network_image_with_placeholder.dart';
import '../movies/rating_widget.dart';

class MovieCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final double? rating;
  final VoidCallback? onTap;
  final String placeholderImage;

  const MovieCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.rating,
    this.onTap,
    this.placeholderImage = 'assets/images/moviePlaceholder.png',
  });

  // Factory constructor for Movie
  factory MovieCard.fromMovie({
    required dynamic movie,
    VoidCallback? onTap,
  }) {
    // Handle both Movie model and any object with movie properties
    final imageUrl = movie.posterPath != null && (movie.posterPath as String).isNotEmpty
        ? AppConstants.buildImageUrl(movie.posterPath, AppConstants.imageMediumSize)
        : null;
    
    return MovieCard(
      title: movie.title ?? '',
      subtitle: movie.releaseDate,
      imageUrl: imageUrl,
      rating: movie.voteAverage,
      onTap: onTap,
    );
  }

  // Factory constructor for Book
  factory MovieCard.fromBook({
    required dynamic book,
    VoidCallback? onTap,
  }) {
    return MovieCard(
      title: book.title ?? '',
      subtitle: book.subtitle,
      imageUrl: book.thumbnail,
      rating: null, // Books don't have ratings
      onTap: onTap,
      placeholderImage: 'assets/images/moviePlaceholder.png', // Use movie placeholder as fallback
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: NetworkImageWithPlaceholder(
            imageUrl: imageUrl,
            placeholder: placeholderImage,
            aspectRatio: 1 / 1,
            width: 100,
            height: 100,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            : null,
        trailing: rating != null
            ? RatingWidget(
                rating: rating,
                starSize: 14,
                ratingTextStyle: Theme.of(context).textTheme.bodySmall,
              )
            : null,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
