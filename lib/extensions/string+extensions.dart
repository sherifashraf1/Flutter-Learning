import 'package:intl/intl.dart';
import '../shared-enums/shared_enums.dart';

extension FormattedDateString on String {
  String formattedDate([DateFormatStyle style = DateFormatStyle.dMyyyy]) {
    try {
      final date = DateTime.parse(this);
      return DateFormat(style.pattern).format(date);
    } catch (_) {
      // Return an empty string or a placeholder for invalid dates.
      return '';
    }
  }
}
