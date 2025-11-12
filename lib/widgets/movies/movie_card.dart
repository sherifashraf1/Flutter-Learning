import 'package:flutter/material.dart';
import '../../models/movies_models/movie_model.dart';
import '../../constants/app_constants.dart';
import 'network_image_with_placeholder.dart';
import 'rating_widget.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              NetworkImageWithPlaceholder(
                imageUrl: (movie.posterPath ?? '').isNotEmpty
                ? AppConstants.buildImageUrl(movie.posterPath, AppConstants.imageMediumSize)
                : null,
                placeholder: 'assets/images/moviePlaceholder.png',
                aspectRatio: 1/1,
                width: 100,
                height: 100,
              ),
            ],
          ),
        ),
        title: Text(
            movie.title,
            style: Theme
                .of(context)
                .textTheme
                .titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
            movie.releaseDate ?? "",
          style: Theme
              .of(context)
              .textTheme
              .bodyMedium,

        ),
        trailing: RatingWidget(
          rating: movie.voteAverage,
          starSize: 14,
          ratingTextStyle: Theme
              .of(context)
              .textTheme
              .bodySmall,
        ),
      ),
    );
  }
}
