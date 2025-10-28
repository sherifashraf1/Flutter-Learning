import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import 'network_image_with_placholder.dart';

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
        contentPadding: EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              NetworkImageWithPlaceholder(
                imageUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        subtitle: Text(
            movie.releaseDate ?? "",
            style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)
        ),
        trailing: Text(
            movie.voteAverage.toString(),
            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}
