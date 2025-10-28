class GenericResponse<T> {
  final int? page;
  final List<T>? results;
  final int? totalPages;
  final int? totalResults;

  GenericResponse({
    this.page,
    this.results,
    this.totalPages,
    this.totalResults,
  });

  factory GenericResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return GenericResponse<T>(
      page: json['page'],
      results: (json['results'] as List?)
          ?.map((result) => fromJsonT(result))
          .toList(),
      totalPages: json['total_pages'],
      totalResults: json['total_results'],
    );
  }
}
