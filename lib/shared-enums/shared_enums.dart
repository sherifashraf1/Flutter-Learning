
enum DateFormatStyle {
  dMyyyy('d/M/yyyy'),
  MMMd('MMM d');

  final String pattern;
  const DateFormatStyle(this.pattern);
}

enum ViewState { loading, success, empty, error }
enum LoadingType { defaultLoading, placeholder, pullToRefresh, loadMore, overlayLoading }
enum ErrorType { emptyState, alert }
