
enum DateFormatStyle {
  dMyyyy('d/M/yyyy'),
  MMMd('MMM d');

  final String pattern;
  const DateFormatStyle(this.pattern);
}
