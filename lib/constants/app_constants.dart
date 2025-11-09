class AppConstants {
  // TMDB Image Base URL
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
  
  // Image sizes
  static const String imageSmallSize = 'w200';
  static const String imageMediumSize = 'w780';
  static const String imageLargeSize = 'w1280';
  
  // Helper method to build image URL
  static String buildImageUrl(String? imagePath, String size) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    return '$tmdbImageBaseUrl/$size$imagePath';
  }
}

