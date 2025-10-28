class MovieDetails {
  final int id;
  final String title;
  final String? overview;
  final String? backdropPath;
  final String? releaseDate;
  final int? runtime;
  final double? voteAverage;
  final List<Genre>? genres;
  final String? posterPath;

  MovieDetails({
    required this.id,
    required this.title,
    this.overview,
    this.backdropPath,
    this.releaseDate,
    this.runtime,
    this.voteAverage,
    this.genres,
    this.posterPath
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
        id: json['id'],
        title: json['title'],
        overview: json['overview'],
        backdropPath: json['backdrop_path'],
        releaseDate: json['release_date'],
        runtime: json['runtime'],
        voteAverage: (json['vote_average'] ?? 0).toDouble(),
        genres: (json['genres'] as List<dynamic>?)
            ?.map((genreJson) => Genre.fromJson(genreJson))
            .toList(),
        posterPath: json['poster_path']
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'], name: json['name']);
  }
}
