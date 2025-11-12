import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../mock/profile_mock/mock_user.dart';

class PersonalInformationCard extends StatefulWidget {
  const PersonalInformationCard({super.key});

  @override
  State<PersonalInformationCard> createState() => _PersonalInformationCardState();
}

class _PersonalInformationCardState extends State<PersonalInformationCard> {
  String? _savedEmail;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");
    setState(() {
      _savedEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use saved email if available, otherwise use mocked email
    final displayEmail = _savedEmail ?? userInfo.email;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary,
            blurRadius: 0.2,
            offset: const Offset(0, 0.2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Text(
            "Personal Information",
           style: TextStyle(fontWeight: FontWeight.bold,
               fontSize: 20),
          ),
          const SizedBox(height: 16),
          _infoRow(context, "Email", displayEmail),
          const SizedBox(height: 8),
          _infoRow(context, "Gender", userInfo.gender),
          const SizedBox(height: 8),
          _infoRow(context, "Birth Date", userInfo.formattedBirthDate()),
          const SizedBox(height: 8),
          _infoRow(context, "Nationality", userInfo.nationality),
          const SizedBox(height: 8),
          _infoRow(context, "Phone Number", userInfo.phoneNumber),
          const SizedBox(height: 8),
          _infoRow(context, "Address", userInfo.address),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String title, String subTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              subTitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
