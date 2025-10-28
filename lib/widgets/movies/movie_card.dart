import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import 'network_image_with_placholder.dart';
import 'rating_widget.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
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
                ? 'https://image.tmdb.org/t/p/w780${movie.posterPath}'
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
            movie.releaseDate ?? "",
            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)
        ),
        trailing: RatingWidget(
          rating: movie.voteAverage,
          starSize: 14,
          filledStarColor: Colors.greenAccent,
          emptyStarColor: Colors.grey.shade600,
          ratingTextStyle: const TextStyle(
            color: Colors.lightBlueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
