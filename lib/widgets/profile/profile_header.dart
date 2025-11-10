import 'package:flutter/material.dart';
import '../../mock/profile_mock/mock_user.dart';
import '../movies/network_image_with_placeholder.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange, width: 1),
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetworkImageWithPlaceholder(
                  imageUrl: userInfo.profileImageUrl,
                  placeholder: 'assets/images/profilePlaceHolder.png',
                ),
              ],
            ),
          ),
        ),
        Text(
          userInfo.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          userInfo.bio,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
