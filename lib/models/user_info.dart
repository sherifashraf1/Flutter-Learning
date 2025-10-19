
import 'package:profile_demo_app_with_flutter/extensions/string+extensions.dart';
import '../shared-enums/date_format_style_enum.dart';

class UserInfo {
  final String name;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  final String gender;
  final String nationality;
  final String address;
  final String bio;
  final String profileImageUrl;

  UserInfo({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.address,
    required this.bio,
    required this.profileImageUrl
  });

  String formattedBirthDate({DateFormatStyle style = DateFormatStyle.dMyyyy}) {
    return dateOfBirth.formattedDate(style);
  }
}
