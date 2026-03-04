import 'package:flutter/material.dart';

class FollowingVideo extends StatefulWidget {
  const FollowingVideo({super.key});

  @override
  State<FollowingVideo> createState() => _FollowingVideoState();
}

class _FollowingVideoState extends State<FollowingVideo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Following"),)
    );
  }
}