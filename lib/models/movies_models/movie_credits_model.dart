class MovieCredits {
  final int? id;
  final List<Actor>? cast;

  MovieCredits({this.id, this.cast});

  factory MovieCredits.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    return MovieCredits(
      id: idRaw is num ? idRaw.toInt() : null,
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
    final castIdRaw = json['cast_id'];
    final genderRaw = json['gender'];
    final idRaw = json['id'];
    final orderRaw = json['order'];

    return Actor(
      castId: castIdRaw is num ? castIdRaw.toInt() : null,
      character: json['character'],
      creditId: json['credit_id']?.toString(),
      gender: genderRaw is num ? genderRaw.toInt() : null,
      id: idRaw is num ? idRaw.toInt() : null,
      name: json['name'],
      order: orderRaw is num ? orderRaw.toInt() : null,
      profilePath: json['profile_path'],
    );
  }
}
