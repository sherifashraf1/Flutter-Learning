class MovieCredits {
  final int? id;
  final List<Actor>? cast;

  MovieCredits({this.id, this.cast});

  factory MovieCredits.fromJson(Map<String, dynamic> json) {
    return MovieCredits(
      id: json['id'],
      cast: (json['cast'] as List<dynamic>?)
          ?.map((actorJson) => Actor.fromJson(actorJson))
          .toList(),
    );
  }
}

class Actor {
  final int? castId;
  final String? character;
  final String? creditId;
  final int? gender;
  final int? id;
  final String? name;
  final int? order;
  final String? profilePath;

  Actor({
    this.castId,
    this.character,
    this.creditId,
    this.gender,
    this.id,
    this.name,
    this.order,
    this.profilePath,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      castId: json['cast_id'],
      character: json['character'],
      creditId: json['credit_id']?.toString(),
      gender: json['gender'],
      id: json['id'],
      name: json['name'],
      order: json['order'],
      profilePath: json['profile_path'],
    );
  }
}
