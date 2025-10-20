import 'package:flutter/material.dart';
import '../mock/mock_user.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/personal_information_card.dart';
import '../widgets/profile/edit_profile_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFef5F3),
        appBar: AppBar(
          title: const Text("Profile Information"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // ensure readable contrast
        ),
        body: LayoutBuilder(
          builder: (_, constraints) {
            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                ProfileHeader(),
                SizedBox(height: 16),
                PersonalInformationCard()
              ],
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: EditProfileButton(),
          ),
        ),
      ),
    );
  }
}