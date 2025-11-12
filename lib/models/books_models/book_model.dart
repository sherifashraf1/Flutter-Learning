class BookResponse {
  final List<Book> books;
  final int totalItems;
  final int startIndex;

  BookResponse({
    required this.books,
    required this.totalItems,
    required this.startIndex,
  });

  bool get hasMore => (startIndex + books.length) < totalItems;
  int get nextStartIndex => startIndex + books.length;
}

class Book {
  final String id;
  final String title;
  final String? subtitle;
  final String? thumbnail;
  final List<String>? categories;
  final String? description;

  Book({
    required this.id,
    required this.title,
    this.subtitle,
    this.thumbnail,
    this.categories,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'No Title',
      subtitle: volumeInfo['subtitle'],
      thumbnail: volumeInfo['imageLinks']?['thumbnail'],
      categories: volumeInfo['categories'] != null
          ? List<String>.from(volumeInfo['categories'])
          : null,
      description: volumeInfo['description'],
    );
  }
}

