import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowButton extends StatefulWidget {
  final String userId;
  final double width;
  final double height;

  const FollowButton({
    super.key,
    required this.userId,
    this.width = 80,
    this.height = 40,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowing = false;
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  /// Load followers count from Supabase
  Future<void> _loadFollowers() async {
    try {
      final user = await Supabase.instance.client
          .from('users')
          .select('followers_count')
          .eq('uid', widget.userId)
          .maybeSingle();

      if (user != null) {
        setState(() {
          followersCount = user['followers_count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error loading followers: $e");
    }
  }

  /// Toggle follow/unfollow safely
  Future<void> _toggleFollow() async {
    setState(() {
      if (isFollowing) {
        // Unfollow: subtract only if count > 0
        if (followersCount > 0) followersCount -= 1;
        isFollowing = false;
      } else {
        // Follow
        followersCount += 1;
        isFollowing = true;
      }
    });

    // Update followers_count in Supabase
    try {
      await Supabase.instance.client
          .from('users')
          .update({'followers_count': followersCount})
          .eq('uid', widget.userId);
    } catch (e) {
      debugPrint("Error updating followers_count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Follow Button
        GestureDetector(
          onTap: _toggleFollow,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.grey : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              isFollowing ? 'Following' : 'Follow',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        // Followers count
        Text(
          '$followersCount followers',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}