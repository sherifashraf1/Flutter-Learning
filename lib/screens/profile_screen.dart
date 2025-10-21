import 'package:flutter/material.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/personal_information_card.dart';
import '../widgets/profile/edit_profile_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: LayoutBuilder(
        builder: (_, constraints) {
          return ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 32),
            children: const [
              ProfileHeader(),
              SizedBox(height: 20),
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
    );
  }
}