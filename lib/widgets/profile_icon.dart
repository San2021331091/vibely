import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:vibely/screens/profile_screen.dart';

class ProfileIcon extends StatelessWidget {
  final String userId;
  final double size;

  const ProfileIcon({super.key, required this.userId, this.size = 50});

  Future<Map<String, dynamic>?> _getUserData() async {
    final response = await Supabase.instance.client
        .from('users')
        .select('image, name')
        .eq('uid', userId)
        .maybeSingle();

    if (response == null) {
      debugPrint("User not found");
      return null;
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final imageUrl = data?['image'] as String?;
        final userName = data?['name'] as String? ?? "Unknown";

        return Tooltip(
          message: userName,
          child: GestureDetector(
            onTap: () {
              Get.to(() => ProfileScreen(userId: userId));
            },
            child: CircleAvatar(
              radius: size / 2,
              backgroundColor: Colors.grey.shade800,
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        );
      },
    );
  }
}