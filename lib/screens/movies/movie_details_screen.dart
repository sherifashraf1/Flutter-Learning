import 'package:flutter/material.dart';
import '../../models/movies_models/generic_response_model.dart';
import '../../services/movies_services/movies_services.dart';
import '../../shared-enums/shared_enums.dart';
import '../../shared/empty_state/data_state_widget.dart';
import '../../widgets/movies/network_image_with_placeholder.dart';
import '../../utils/secure_error_handler.dart';
import '../../constants/app_constants.dart';
import '/models/movies_models/movie_details_model.dart';
import '../../models/movies_models/movie_credits_model.dart';
import '../../models/movies_models/movie_model.dart';
import '/shared/loading/loading_widget.dart';
import '/shared/empty_state/data_state.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;
  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final _service = MoviesService();

  DataState<MovieDetails> _detailsState = DataState.loading(LoadingType.defaultLoading);
  DataState<MovieCredits> _creditsState = DataState.loading(LoadingType.placeholder);
  DataState<GenericResponse<Movie>> _similarState = DataState.loading(LoadingType.placeholder);
  DataState<GenericResponse<Movie>> _recommendationsState = DataState.loading(LoadingType.placeholder);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    _loadMovieDetails();
    _loadCredits();
    _loadSimilarMovies();
    _loadRecommendations();
  }

  void _loadMovieDetails({bool isRetry = false}) async {
    // Use defaultLoading only on first load, placeholder on retry
    final loadingType = isRetry ? LoadingType.placeholder : LoadingType.defaultLoading;
    setState(() => _detailsState = DataState.loading(loadingType));
    try {
      final details = await _service.getMovieDetails(widget.movieId);
      setState(() => _detailsState = DataState.success(details));
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'loadMovieDetails');
      setState(() => _detailsState = DataState.error(
        title: "Failed to load movie details",
        description: SecureErrorHandler.handleError(error, context: 'movie details'),
        onRetry: () => _loadMovieDetails(isRetry: true),
      ));
    }
  }

  void _loadCredits() async {
    setState(() => _creditsState = DataState.loading(LoadingType.placeholder));
    try {
      final credits = await _service.getActorsForMovie(widget.movieId);
      setState(() => _creditsState = DataState.success(credits));
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'loadCredits');
      setState(() => _creditsState = DataState.error(
        title: "Failed to load cast",
        description: SecureErrorHandler.handleError(error, context: 'cast information'),
        onRetry: _loadCredits,
      ));
    }
  }

  void _loadSimilarMovies() async {
    setState(() => _similarState = DataState.loading(LoadingType.placeholder));
    try {
      final similar = await _service.getSimilarMovies(widget.movieId, 1);
      if (similar.results == null || similar.results!.isEmpty) {
        setState(() => _similarState = DataState.empty(
          title: "No Similar Movies",
          description: "There are no similar movies to show.",
        ));
      } else {
        setState(() => _similarState = DataState.success(similar));
      }
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'loadSimilarMovies');
      setState(() => _similarState = DataState.error(
        title: "Failed to load similar movies",
        description: SecureErrorHandler.handleError(error, context: 'similar movies'),
        onRetry: _loadSimilarMovies,
      ));
    }
  }

  void _loadRecommendations() async {
    setState(() => _recommendationsState = DataState.loading(LoadingType.placeholder));
    try {
      final recommendations = await _service.getRecommendations(widget.movieId, 1);
      if (recommendations.results == null || recommendations.results!.isEmpty) {
        setState(() => _recommendationsState = DataState.empty(
          title: "No Recommendations",
          description: "There are no recommendations to show.",
        ));
      } else {
        setState(() => _recommendationsState = DataState.success(recommendations));
      }
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'loadRecommendations');
      setState(() => _recommendationsState = DataState.error(
        title: "Failed to load recommendations",
        description: SecureErrorHandler.handleError(error, context: 'recommendations'),
        onRetry: _loadRecommendations,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Movie Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _detailsState.state == ViewState.loading && _detailsState.loadingType == LoadingType.defaultLoading
          ? const Center(child: LoadingWidget())
          : SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Details section
            DataStateWidget<MovieDetails>(
              dataState: _detailsState,
              isInsideScrollable: true,
              childBuilder: (details) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetworkImageWithPlaceholder(
                    imageUrl: details.backdropPath?.isNotEmpty == true
                        ? AppConstants.buildImageUrl(details.backdropPath, AppConstants.imageLargeSize)
                        : null,
                    placeholder: 'assets/images/moviePlaceholder.png',
                    aspectRatio: 16 / 9,
                  ),
                  _buildOverview(details),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Cast Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Cast"),
                const SizedBox(height: 12),
                DataStateWidget<MovieCredits>(
                  dataState: _creditsState,
                  containerHeight: 220,
                  isInsideScrollable: true,
                  childBuilder: (credits) => SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (_, index) {
                        final actor = credits.cast?[index];
                        final hasProfile = (actor?.profilePath ?? '').isNotEmpty;
                        final imageUrl = hasProfile ? AppConstants.buildImageUrl(actor!.profilePath, AppConstants.imageSmallSize) : null;
                        return _buildCard(
                          imageUrl: imageUrl ?? '',
                          name: actor?.name ?? 'Unknown',
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: credits.cast?.length ?? 0,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            // Similar Movies
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Similar Movies"),
                const SizedBox(height: 12),
                DataStateWidget<GenericResponse<Movie>>(
                  dataState: _similarState,
                  containerHeight: 220,
                  isInsideScrollable: true,
                  childBuilder: (resp) => SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (_, index) => _buildCard(
                        imageUrl: AppConstants.buildImageUrl(resp.results![index].posterPath, AppConstants.imageSmallSize),
                        name: resp.results![index].title,
                      ),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: resp.results?.length ?? 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recommendations
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Recommendations"),
                const SizedBox(height: 12),
                DataStateWidget<GenericResponse<Movie>>(
                  dataState: _recommendationsState,
                  containerHeight: 220,
                  isInsideScrollable: true,
                  childBuilder: (resp) => SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (_, index) => _buildCard(
                        imageUrl: AppConstants.buildImageUrl(resp.results![index].posterPath, AppConstants.imageSmallSize),
                        name: resp.results![index].title,
                      ),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: resp.results?.length ?? 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(width: 4, height: 24, color: Colors.greenAccent),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildOverview(MovieDetails movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (movie.title.isNotEmpty)
            Text(movie.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
          const SizedBox(height: 8),
          if ((movie.overview ?? '').isNotEmpty)
            Text(
              movie.overview!,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String imageUrl,
    required String? name,
    double width = 120,
    double height = 180,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: NetworkImageWithPlaceholder(
                imageUrl: imageUrl,
                placeholder: 'assets/images/moviePlaceholder.png',
                height: height,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
