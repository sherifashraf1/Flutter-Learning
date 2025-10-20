import 'package:flutter/material.dart';
import '../../mock/mock_user.dart';

class PersonalInformationCard extends StatelessWidget {
  const PersonalInformationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personal Information",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 12),
          _infoRow(context, "Email", userInfo.email),
          _infoRow(context, "Gender", userInfo.gender),
          _infoRow(context, "Birth Date", userInfo.formattedBirthDate()),
          _infoRow(context, "Nationality", userInfo.nationality),
          _infoRow(context, "Phone Number", userInfo.phoneNumber),
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
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              subTitle,
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
