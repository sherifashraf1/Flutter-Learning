import 'package:flutter/material.dart';
import '../../mock/mock_user.dart';

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
            child: Image.network(
              userInfo.profileImageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Image.asset(
                  "assets/images/profilePlaceHolder.png",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/images/profilePlaceHolder.png",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
              },
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
