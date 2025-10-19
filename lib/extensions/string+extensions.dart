import 'package:intl/intl.dart';
import '../shared-enums/date_format_style_enum.dart';

extension FormattedDateString on String {
  String formattedDate([DateFormatStyle style = DateFormatStyle.dMyyyy]) {
    try {
      final date = DateTime.parse(this);
      return DateFormat(style.pattern).format(date);
    } catch(_) {
      return this;
    }
  }
}
