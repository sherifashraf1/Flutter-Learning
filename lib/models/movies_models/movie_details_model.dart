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
    final voteAverageRaw = json['vote_average'];
    final runtimeRaw = json['runtime'];
    final idRaw = json['id'];

    return MovieDetails(
        id: idRaw is num ? idRaw.toInt() : (idRaw as int? ?? 0),
        title: json['title'] ?? '',
        overview: json['overview'],
        backdropPath: json['backdrop_path'],
        releaseDate: json['release_date'],
        runtime: runtimeRaw is num ? runtimeRaw.toInt() : null,
        voteAverage: voteAverageRaw is num ? voteAverageRaw.toDouble() : null,
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
    final idRaw = json['id'];
    return Genre(
      id: idRaw is num ? idRaw.toInt() : (idRaw as int? ?? 0),
      name: json['name'] ?? '',
    );
  }
}
