import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserProfilePage extends StatefulWidget {
  final int userId;
  final String? token;

  UserProfilePage({required this.userId, required this.token});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  String friendShipStatus = 'UNKNOWN'; // Track the friendship status

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/users/getUser'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'userId': widget.userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          user = data['user'];
          friendShipStatus = user!['friendShipStatus'] ?? 'UNKNOWN';
          isLoading = false;
          print('User data: $user');
        });
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

  Future<void> followUser() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/users/sendFollowRequest'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'receiverId': widget.userId}),
      );

      if (response.statusCode == 201) {
        setState(() {
          if (friendShipStatus == 'NOT_FOLLOWING') {
            friendShipStatus = 'FOLLOWING';
          }
        });
        await fetchUserDetails(); // Refresh user details to get updated friendship status
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  Future<void> cancelFollowingUser() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/users/cancelFollowing'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'receiverId': widget.userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (friendShipStatus == 'FOLLOWING') {
            friendShipStatus = 'NOT_FOLLOWING';
          }
        });
        await fetchUserDetails(); // Refresh user details to get updated friendship status
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  Future<void> blockUser() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/users/blockUser'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'targetId': widget.userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          friendShipStatus = 'BLOCKED';
        });
        await fetchUserDetails(); // Refresh user details to get updated friendship status
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  Widget buildFriendshipActions() {
    if (user == null) return Container();

    switch (friendShipStatus) {
      case 'MUTUAL':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                blockUser();
              },
              child: Text('Block', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(159, 145, 204, 1)),
            ),
            ElevatedButton(
              onPressed: () {
                cancelFollowingUser();
              },
              child: Text('UnFollow', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(159, 145, 204, 1)),
            ),
          ],
        );

      case 'FOLLOWING':
        return Center(
          child: ElevatedButton(
            onPressed: () {
              cancelFollowingUser();
            },
            child:
            Text('UnFollow', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(159, 145, 204, 1)),
          ),
        );

      case 'NOT_FOLLOWING':
        return Center(
          child: ElevatedButton(
            onPressed: () {
              followUser();
            },
            child: Text('Follow', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(159, 145, 204, 1)),
          ),
        );

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${user?['first_name'] ?? 'N/A'} ${user?['last_name'] ?? 'N/A'}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(92, 75, 153, 1),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : user == null
          ? Center(child: Text('User not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user!['profile_pic'] != null &&
                    user!['profile_pic'].isNotEmpty
                    ? NetworkImage(user!['profile_pic'])
                    : AssetImage('assets/default_avatar.png')
                as ImageProvider,
              ),
            ),
            SizedBox(height: 16),
            // Name and Email without container
            Center(
              child: Column(
                children: [
                  Text(
                    '${user!['first_name'] ?? 'N/A'} ${user!['last_name'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(92, 75, 153, 1),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email: ${user!['email'] ?? 'N/A'}',
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            buildFriendshipActions(),
            SizedBox(height: 16),
            // Information in containers
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Age: ${user!['age'] ?? 'N/A'}',
                    style: TextStyle(
                        color: Color.fromRGBO(159, 145, 204, 1),
                        fontSize: 15),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Followers: ${user!['followers'] ?? 'N/A'}',
                    style: TextStyle(
                        color: Color.fromRGBO(159, 145, 204, 1),
                        fontSize: 15),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Following: ${user!['following'] ?? 'N/A'}',
                    style: TextStyle(
                        color: Color.fromRGBO(159, 145, 204, 1),
                        fontSize: 15),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'City: ${user!['city'] ?? 'N/A'}',
                    style: TextStyle(
                        color: Color.fromRGBO(159, 145, 204, 1),
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
