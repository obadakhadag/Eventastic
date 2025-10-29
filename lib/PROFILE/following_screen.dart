import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/PROFILE/profile_user.dart';

import '../controllers/user_controller.dart';

class FollowingListScreen extends StatefulWidget {
  @override
  _FollowersListScreenState createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends State<FollowingListScreen> {
  List<dynamic> followings = [];
  bool isLoading = true;
  final token = UserController.getToken();

  @override
  void initState() {
    super.initState();
    fetchFollowing();
  }

  Future<void> fetchFollowing() async {
    try {
      print('Token: $token');

      final response = await http.get(
        Uri.parse('http://192.168.7.39:8000/api/users/getFollowing'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('Following')) {
          setState(() {
            followings = data['Following'];
            isLoading = false;
          });
        } else {
          print('Unexpected response format');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception caught: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Following',
        style: TextStyle(
          color: Color.fromRGBO(92, 75, 153, 1),
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : followings.isEmpty
          ? Center(
        child: Text(
          'No user is following me',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      )
          :ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: followings.length,
        itemBuilder: (context, index) {
          final following =followings[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading:

              CircleAvatar(
                radius: 50, // Adjust size as needed
                backgroundImage: (following['profile_pic'] != null && following['profile_pic'].isNotEmpty)
                    ? MemoryImage(base64Decode(following['profile_pic'])) as ImageProvider
                    : AssetImage('assets/images/undraw_Profile_pic_re_iwgo.png'),
                backgroundColor: Colors.deepPurple,
              ),




              //
              //
              // CircleAvatar(
              //   backgroundImage: NetworkImage(following['profile_pic']),B
              // ),
              //


              title: Text(
                '${following['first_name']} ${following['last_name']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(following['email']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(userId: following['id'], token: token),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

