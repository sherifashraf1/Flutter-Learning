import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/empty_state/data_state_widget.dart';
import '../../shared-enums/shared_enums.dart';
import '../../widgets/reusable_widgets/reusable_card.dart';
import '../../models/books_models/book_model.dart';
import '../../shared/loading/loading_widget.dart';
import '../../providers/books_provider.dart';
import '../../utils/secure_error_handler.dart';
import '../../shared/empty_state/data_state.dart';
import 'book_details_screen.dart';

class BookListScreen extends ConsumerStatefulWidget {
  const BookListScreen({super.key});

  @override
  ConsumerState<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends ConsumerState<BookListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);

    // Load books on first appearance (like movie list)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(booksStateProvider.notifier)
            .loadBooks(LoadingType.defaultLoading);
      }
    });
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    ref.read(booksStateProvider.notifier).updateSearchQuery(query);
    _searchFocusNode.unfocus();
  }

  void _clearSearch() {
    _searchController.clear();
    final currentQuery = ref.read(booksSearchQueryProvider);
    // Only update query if it's different from default
    if (currentQuery != 'flutter') {
      ref.read(booksStateProvider.notifier).updateSearchQuery('flutter');
    }
    _searchFocusNode.unfocus();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (!_scrollController.position.hasContentDimensions) return;

    final notifier = ref.read(booksStateProvider.notifier);
    final booksState = ref.read(booksStateProvider);
    final isLoadingMore = ref.read(booksLoadingMoreProvider);

    final isLoading = booksState.state == ViewState.loading && !isLoadingMore;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 150 &&
        !isLoading &&
        !isLoadingMore &&
        notifier.loadMoreEnabled) {
      notifier.loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(booksStateProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksState = ref.watch(booksStateProvider);
    final notifier = ref.read(booksStateProvider.notifier);
    final isLoadingMore = ref.watch(
      booksLoadingMoreProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              axisAlignment: 2,
              child: child,
            );
          },
          child: _isSearchExpanded
              ? SizedBox(
                  height: 40,
                  child: TextField(
                    key: const ValueKey('searchField'),
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      hintText: 'Search books...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey, width: 2),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                    onSubmitted: _handleSearch,
                    onChanged: (value) {
                      setState(() {}); // Rebuild to show/hide clear button
                    },
                  ),
                )
              : const Text(
                  'Book Store',
                  key: ValueKey('titleText'),
                ),
        ),
        centerTitle: !_isSearchExpanded,
        actions: [
          if (!_isSearchExpanded)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _toggleSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _closeSearch,
            ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.greenAccent,
        backgroundColor: const Color(0xFF0F172A),
        onRefresh: _onRefresh,
        child: DataStateWidget<List<Book>>(
          dataState: booksState,
          childBuilder: (_) => _buildBookList(
            booksState.data ?? [],
            notifier,
            isLoadingMore,
          ),
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ),
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      } else {
        // When closing, check if we need to reset query
        final searchText = _searchController.text.trim();
        if (searchText.isEmpty) {
          // Just close, don't reload
          _searchController.clear();
          _searchFocusNode.unfocus();
        } else {
          // Clear search and reset
          _clearSearch();
        }
      }
    });
  }

  void _closeSearch() {
    final searchText = _searchController.text.trim();
    // If search field is empty, just close without reloading
    if (searchText.isEmpty) {
      setState(() {
        _isSearchExpanded = false;
        _searchController.clear();
      });
      _searchFocusNode.unfocus();
      return;
    }
    // If search field has text, clear it and reset to default
    _clearSearch();
  }

  Widget _buildBookList(
    List<Book> books,
    BooksNotifier notifier,
    bool isLoadingMore,
  ) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: books.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == books.length && isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: LoadingWidget(size: 24)),
          );
        }
        final book = books[index];
        return MovieCard.fromBook(
          book: book,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailsScreen(volumeId: book.id),
              ),
            );
          },
        );
      },
    );
  }
}
