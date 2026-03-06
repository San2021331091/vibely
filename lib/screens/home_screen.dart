import 'package:flutter/material.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:vibely/screens/following_video_screen.dart';
import 'package:vibely/screens/for_you_video_screen.dart';
import 'package:vibely/screens/profile_screen.dart';
import 'package:vibely/screens/search_screen.dart';
import 'package:vibely/screens/upload_video_screen.dart';
import 'package:vibely/widgets/upload_custom_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final String currentUserId;
  int screenIndex = 0;
  late final List<Widget> screenList;

  @override
  void initState() {
    super.initState();
    // Make sure currentUserId is initialized when the widget is created
    currentUserId = SupabaseAuth.supabase.auth.currentUser?.id ?? "";
    
    // Initialize the screen list with the proper userId
    screenList = [
      const ForYouVideoScreen(),
      const SearchScreen(),
      const UploadVideoScreen(),
      const FollowingVideoScreen(),
      ProfileScreen(userId: currentUserId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            screenIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white12,
        currentIndex: screenIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30),
            label: "Discover",
          ),
          BottomNavigationBarItem(
            icon: UploadCustomIcon(),
            label: "Upload",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_sharp, size: 30),
            label: "Following",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: "Me",
          ),
        ],
      ),
      body: screenList[screenIndex],
    );
  }
}