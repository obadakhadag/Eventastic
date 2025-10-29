import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:our_mobile_app/controllers/user_controller.dart';
import 'package:our_mobile_app/screens/home/components/Fav_Screen.dart';
import 'package:provider/provider.dart';

import '../PROFILE/profile_page.dart';
import '../controllers/User_Things_Provider.dart';
import '../screens/onboding/components/SignUPform.dart';

class InfoCard extends StatefulWidget {
  const InfoCard({
    Key? key,
    required this.name,
    required this.profession,
  }) : super(key: key);

  final String name, profession;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProfilePage()),
        );
      },
      child: ListTile(
        leading: Consumer<UserThingsProvider>(
          builder: (context, userProvider, child) {
            return CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 30, // Adjust size as needed
              backgroundImage: UserController.user?.photoURL != null &&
                      UserController.user!.photoURL!.isNotEmpty
                  ? NetworkImage(UserController.user!.photoURL!)
                  : (userProvider.profilePic != null &&
                          userProvider.profilePic.isNotEmpty)
                      ? MemoryImage(base64Decode(userProvider.profilePic))
                      : AssetImage('assets/images/images.jpeg')
                          as ImageProvider,
              child: (UserController.user?.photoURL == null ||
                          UserController.user!.photoURL!.isEmpty) &&
                      (userProvider.profilePic == null ||
                          userProvider.profilePic.isEmpty)
                  ? ClipOval(
                      child: Image.asset(
                        'assets/images/images.jpeg', // Your default asset image
                        fit: BoxFit.cover,
                        width: 40.0,
                        height: 40.0,
                      ),
                    )
                  : null,
            );
          },
        ),
        title: Consumer<UserThingsProvider>(
          builder: (context, userProvider, child) {
            return Text(
              userProvider.firstName,
              style: TextStyle(color: Colors.white, fontSize: 16),
            );
          },
        ),
        subtitle: Consumer<UserThingsProvider>(
          builder: (context, userProvider, child) {
            return Text(
              userProvider.lastName,
              style: TextStyle(color: Colors.white, fontSize: 16),
            );
          },
        ),
      ),
    );
  }
}
