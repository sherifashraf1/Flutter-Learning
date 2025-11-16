import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../models/books_models/book_model.dart';
import '../../providers/books_provider.dart';
import '../../shared/empty_state/data_state_widget.dart';
import '../../widgets/movies/network_image_with_placeholder.dart';

class BookDetailsScreen extends ConsumerStatefulWidget {
  final String volumeId;
  const BookDetailsScreen({super.key, required this.volumeId});

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Reload book details every time screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(bookDetailsStateProvider(widget.volumeId).notifier).loadBookDetails();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookDetailsStateProvider(widget.volumeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          bookState.data?.title ?? '',
        ),
      ),
      body: DataStateWidget<Book>(
        dataState: bookState,
        childBuilder: (book) => _buildBookDetails(book, context),
      ),
    );
  }

  static Widget _buildBookDetails(Book book, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetworkImageWithPlaceholder(
            imageUrl: book.thumbnail?.isNotEmpty == true
                ? book.thumbnail
                : null,
            placeholder: 'assets/images/moviePlaceholder.png',
            height: screenHeight * 0.35,
            fit: BoxFit.fill,
          ),

          const SizedBox(height: 16),

          Padding(padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (book.subtitle != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 12),
                  Text(
                    book.subtitle!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],

                if (book.categories != null && book.categories!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 16),
                  Text(
                    "Categories: ",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.labelLarge?.color
                    )
                  ),
                  const SizedBox(height: 16 ,),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: book.categories!.map((category) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                if (book.description != null) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 16),
                  Html(
                    data: book.description!,
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(16),
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      "p": Style(
                        margin: Margins.only(bottom: 8),
                      ),
                    },
                  ),
                ],
              ]
            ),
          )
        ],
      ),
    );
  }
}
