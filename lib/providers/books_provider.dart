import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../shared/empty_state/data_state.dart';
import '../shared-enums/shared_enums.dart';
import '../services/books_services/books_services.dart';
import '../utils/secure_error_handler.dart';
import '../models/books_models/book_model.dart';

final booksServiceProvider = Provider<BooksService>((ref) {
  return BooksService();
});

final booksStateProvider = StateNotifierProvider<BooksNotifier, DataState<List<Book>>>(
  (ref) {
    return BooksNotifier(ref.read(booksServiceProvider), ref);
  },
);

// Separate provider for loading more state to trigger rebuilds
final booksLoadingMoreProvider = StateProvider<bool>((ref) => false);

// Provider for search query
final booksSearchQueryProvider = StateProvider<String>((ref) => 'flutter');

// Provider for book details - uses family to handle different volumeIds
// autoDispose ensures provider is disposed when screen closes, forcing reload on next open
final bookDetailsStateProvider = StateNotifierProvider.autoDispose.family<BookDetailsNotifier, DataState<Book>, String>(
  (ref, volumeId) {
    return BookDetailsNotifier(ref.read(booksServiceProvider), volumeId);
  },
);

class BooksNotifier extends StateNotifier<DataState<List<Book>>> {
  final BooksService _service;
  final Ref _ref;
  final List<Book> _books = [];
  int _startIndex = 0;
  bool _loadMoreEnabled = true;
  bool _isLoading = false; // Prevent duplicate loads

  BooksNotifier(this._service, this._ref) : super(DataState.loading()) {
    // Don't auto-load - let the screen handle it
  }

  bool get _isLoadingMore => _ref.read(booksLoadingMoreProvider);
  
  void _setLoadingMore(bool value) {
    _ref.read(booksLoadingMoreProvider.notifier).state = value;
  }

  String get _searchQuery => _ref.read(booksSearchQueryProvider);

  Future<void> loadBooks(LoadingType loadingType) async {
    final isLoadMore = loadingType == LoadingType.loadMore;
    final isRefresh = loadingType == LoadingType.pullToRefresh;

    // Prevent duplicate loads
    if (!isLoadMore && _isLoading) return;
    if (isLoadMore) {
      if (!_loadMoreEnabled || _isLoadingMore) return;
      _setLoadingMore(true); // This will trigger rebuild via StateProvider
    } else {
      _isLoading = true;
    }

    if (isRefresh) {
      final hasContent = state.state == ViewState.success && _books.isNotEmpty;
      if (!hasContent) {
        state = DataState.loading(LoadingType.pullToRefresh);
      }
    } else if (!isLoadMore) {
      state = DataState.loading(loadingType);
      _books.clear();
      _startIndex = 0;
      _loadMoreEnabled = true;
    }

    if (isRefresh) {
      _books.clear();
      _startIndex = 0;
      _loadMoreEnabled = true;
    }

    try {
      // Load books with current search query
      final searchQuery = _searchQuery.trim();
      final query = searchQuery.isEmpty ? 'flutter' : searchQuery;
      final response = await _service.getBooks(
        query: query,
        subject: null,
        startIndex: _startIndex,
        maxResults: 20,
      );

      if (response.books.isEmpty && _startIndex == 0) {
        state = DataState.empty(
          title: "Oops!",
          description: "No books found.",
        );
      } else {
        if (isRefresh) _books.clear();
        _books.addAll(response.books);
        _startIndex = response.nextStartIndex;
        _loadMoreEnabled = response.hasMore;
        state = DataState.success(List.from(_books));
      }
    } catch (e, stackTrace) {
      SecureErrorHandler.logNonFatalError(
        e,
        context: 'loadBooks',
        stackTrace: stackTrace,
        additionalInfo: {
          'query': _searchQuery,
          'startIndex': _startIndex,
        },
      );
      
      // Handle 429 (rate limit) specifically
      final errorMessage = e.toString();
      final isRateLimit = errorMessage.contains('429');
      
      state = DataState.error(
        title: "Error loading books",
        description: isRateLimit 
            ? "Too many requests. Please wait a moment and try again."
            : SecureErrorHandler.handleError(e, context: 'book list'),
        onRetry: isRateLimit ? null : () => loadBooks(LoadingType.defaultLoading),
      );
    } finally {
      if (isLoadMore) {
        _setLoadingMore(false); // This will trigger rebuild via StateProvider
      } else {
        _isLoading = false;
      }
    }
  }

  Future<void> refresh() async {
    // Add a small delay to prevent rate limiting
    await Future.delayed(const Duration(milliseconds: 300));
    await loadBooks(LoadingType.pullToRefresh);
  }

  Future<void> loadMore() async {
    if (_loadMoreEnabled && !_isLoadingMore) {
      await loadBooks(LoadingType.loadMore);
    }
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get loadMoreEnabled => _loadMoreEnabled;

  void updateSearchQuery(String query) {
    _ref.read(booksSearchQueryProvider.notifier).state = query;
    // Reset and reload with new query
    _books.clear();
    _startIndex = 0;
    _loadMoreEnabled = true;
    loadBooks(LoadingType.defaultLoading);
  }
}

class BookDetailsNotifier extends StateNotifier<DataState<Book>> {
  final BooksService _service;
  final String _volumeId;

  BookDetailsNotifier(this._service, this._volumeId) : super(DataState.loading(LoadingType.defaultLoading)) {
    // Auto-load book details on initialization
    loadBookDetails();
  }

  Future<void> loadBookDetails() async {
    state = DataState.loading(LoadingType.defaultLoading);
    try {
      final book = await _service.getBookDetails(_volumeId);
      state = DataState.success(book);
    } catch (error, stackTrace) {
      SecureErrorHandler.logNonFatalError(
        error,
        context: 'loadBookDetails',
        stackTrace: stackTrace,
        additionalInfo: {'volumeId': _volumeId},
      );
      state = DataState.error(
        title: "Failed to load book details",
        description: SecureErrorHandler.handleError(error, context: 'book details'),
        onRetry: loadBookDetails,
      );
    }
  }
}

