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
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      voteAverage: json['vote_average'],
      releaseDate: json['release_date'],
    );
  }
}
