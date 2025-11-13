import 'package:flutter/material.dart';
import '../movies/network_image_with_placeholder.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String profileImageUrl;
  final String userBio;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.profileImageUrl,
    required this.userBio,
  });

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
                  imageUrl: profileImageUrl,
                  placeholder: 'assets/images/profilePlaceHolder.png',
                ),
              ],
            ),
          ),
        ),
        Text(
          userName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          userBio,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
