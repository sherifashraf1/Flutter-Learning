import 'package:flutter/material.dart';
import 'package:profile_demo_app_with_flutter/shared/empty_state/data_state_widget.dart';
import '../../router/app_router.dart';
import '../../services/movies_services/movies_services.dart';
import '../../shared-enums/shared_enums.dart';
import '../../widgets/movies/movie_card.dart';
import '../../utils/secure_error_handler.dart';
import '../../models/movies_models/movie_model.dart';
import '/shared/empty_state/data_state.dart';
import '/shared/loading/loading_widget.dart';

class MoviesListScreen extends StatefulWidget {
  const MoviesListScreen({super.key});

  @override
  State<MoviesListScreen> createState() => _MoviesListScreenState();
}

class _MoviesListScreenState extends State<MoviesListScreen> {
  final MoviesService _service = MoviesService();
  final ScrollController _scrollController = ScrollController();

  final List<Movie> _movies = [];
  int _pageIndex = 1;
  bool _loadMoreEnabled = true;
  bool _isLoadingMore = false;

  DataState<List<Movie>> _moviesState = DataState.loading();

  bool get _isLoading =>
      _moviesState.state == ViewState.loading && !_isLoadingMore;

  @override
  void initState() {
    super.initState();
    _loadDataWith(LoadingType.defaultLoading);
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 150 &&
        !_isLoading &&
        !_isLoadingMore &&
        _loadMoreEnabled) {
      _loadDataWith(LoadingType.loadMore);
    }
  }

  Future<void> _loadDataWith(LoadingType loadingType) async {
    final isLoadMore = loadingType == LoadingType.loadMore;
    final isRefresh = loadingType == LoadingType.pullToRefresh;

    if (isLoadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      // For refresh: keep existing content visible if it exists, only clear error/empty states
      // For other loading types: clear movies and show loading
      if (isRefresh) {
        // Only change to loading state if we're NOT in success state with movies
        // This keeps the list visible during refresh, but clears error/empty states
        final hasContent = _moviesState.state == ViewState.success && _movies.isNotEmpty;
        if (!hasContent) {
          setState(() => _moviesState = DataState.loading(LoadingType.pullToRefresh));
        }
      } else {
        setState(() => _moviesState = DataState.loading(loadingType));
        _movies.clear();
      }
    }

    if (isRefresh) _pageIndex = 1;

    try {
      final response = await _service.getNowPlayingMovies(_pageIndex);
      final movies = response.results ?? [];

      if (movies.isEmpty && _pageIndex == 1) {
        setState(
          () => _moviesState = DataState.empty(
            title: "Ooops",
            description: "No movies available at the moment.",
          ),
        );
      } else {
        if (isRefresh) _movies.clear();
        _movies.addAll(movies);
        _pageIndex++;
        _loadMoreEnabled = (_pageIndex <= (response.totalPages ?? 1));
        setState(() => _moviesState = DataState.success(_movies));
      }
    } catch (e) {
      SecureErrorHandler.logError(e, context: 'loadMovies');
      setState(
        () => _moviesState = DataState.error(
          title: "Error loading movies",
          description: SecureErrorHandler.handleError(e, context: 'movie list'),
          onRetry: () => _loadDataWith(LoadingType.defaultLoading),
        ),
      );
    } finally {
      if (isLoadMore) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async => _loadDataWith(LoadingType.pullToRefresh);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Now Playing",
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: Colors.greenAccent,
        backgroundColor: const Color(0xFF0F172A),
        onRefresh: _onRefresh,
        child: DataStateWidget<List<Movie>>(
          dataState: _moviesState,
          childBuilder: (_) => _buildMovieList(),
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow),
        ),
      ),
    );
  }

  Widget _buildMovieList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _movies.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _movies.length && _isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: LoadingWidget(size: 24)),
          );
        }
        final movie = _movies[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRouter.movieDetails,
            arguments: movie.id,
          ),
          child: MovieCard(movie: movie),
        );
      },
    );
  }
}
