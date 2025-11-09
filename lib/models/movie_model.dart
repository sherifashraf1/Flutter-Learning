class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final double? voteAverage;
  final String? releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final voteAverageRaw = json['vote_average'];

    return Movie(
      id: idRaw is num ? idRaw.toInt() : (idRaw as int? ?? 0),
      title: json['title'] ?? '',
      posterPath: json['poster_path'],
      voteAverage: voteAverageRaw is num ? voteAverageRaw.toDouble() : null,
      releaseDate: json['release_date'],
    );
  }
}
