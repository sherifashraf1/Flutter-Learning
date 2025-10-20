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
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Always show placeholder first (at the bottom)
                Image.asset(
                  "assets/images/profilePlaceHolder.png",
                  fit: BoxFit.cover,
                ),
                // Then overlay the network image on top when available
                Image.network(
                  userInfo.profileImageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // show image when done
                    } else {
                      return const SizedBox.shrink(); // hide while loading
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink(); // keep placeholder on error
                  },
                ),
              ],
            )
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
