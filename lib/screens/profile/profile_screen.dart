import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../mock/profile_mock/mock_user.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/personal_information_card.dart';
import '../../widgets/profile/edit_profile_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _savedName;
  String? _savedEmail;
  String? _savedProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString("name");
    final email = prefs.getString("email");
    final profileImageUrl = prefs.getString("profileImageUrl");

    setState(() {
      _savedName = name;
      _savedEmail = email;
      _savedProfileImageUrl = profileImageUrl;
    });
  }
  @override
  Widget build(BuildContext context) {
    final displayName = _savedName ?? userInfo.name;
    final displayUserBio = userInfo.bio;
    final displayEmail = _savedEmail ?? userInfo.email;
    final displayProfileImageUrl = _savedProfileImageUrl ?? userInfo.profileImageUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: LayoutBuilder(
        builder: (_, constraints) {
          return ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 32),
            children: [
              ProfileHeader(
                userName: displayName,
                profileImageUrl: displayProfileImageUrl,
                userBio: displayUserBio,
              ),
              const SizedBox(height: 20),
              PersonalInformationCard(
                email: displayEmail,
                phoneNumber: userInfo.phoneNumber,
              ),
            ],
          );
        },
      )
    );
  }
}