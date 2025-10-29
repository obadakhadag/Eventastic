import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/PROFILE/profilesearch.dart';
import 'package:provider/provider.dart';

import '../controllers/User_Things_Provider.dart';
import '../controllers/user_controller.dart';
import 'edit_profile.dart';
import 'event_attended_page.dart';
import 'followers_screen.dart';
import 'following_screen.dart';
import 'my_events.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> blockeduser = [];
  String joinDate = 'Joined: N/A';
  Map<String, dynamic> userpro = {};
  bool isLoading = true;
  final token = UserController.getToken();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUserProfile();
    fetchBlockedUsers();
  }

  Future<void> fetchUserProfile() async {
    try {
      print('Token: $token');
      print('Attempting to fetch user profile...');

      final response = await http.get(
        Uri.parse('http://192.168.7.39:8000/api/users/getProfile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('user')) {
          setState(() {
            userpro = data['user'];
            joinDate =
                'Joined: ${userpro['created_at'] ?? 'N/A'}'; // Update joinDate
            isLoading = false;
          });
        } else {
          print('Unexpected response format');
          setState(() {
            isLoading = false;
          });
        }
        print('User profile fetched successfully');
        print('Extracted user: $userpro');
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

  Future<void> fetchBlockedUsers() async {
    try {
      print('Token: $token');

      final response = await http.get(
        Uri.parse('http://192.168.7.39:8000/api/users/getBlocked'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('BlockedUsers')) {
          setState(() {
            blockeduser = data['BlockedUsers'];
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









  Future<void> unblockUser(int targetId) async {
    final url = Uri.parse('http://192.168.7.39:8000/api/users/blockUser');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'targetId': targetId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        blockeduser.removeWhere((user) => user['id'] == targetId);
        Navigator.of(context).pop();

      });
      print('User unblocked successfully');
    } else {

      print(response.body);
      print('Failed to unblock user: ${response.statusCode}');
      Navigator.of(context).pop();

    }
  }


  void _showQrCodeDialog() {
    final userThingsProvider = context.read<UserThingsProvider>(); // Access the provider
    final qrCodeBase64 = userThingsProvider.QRcode;

    if (qrCodeBase64.isNotEmpty) {
      try {
        final decodedQrCode = base64Decode(qrCodeBase64);
        final qrCodeSvg = SvgPicture.memory(decodedQrCode, width: 250, height: 250);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Your QR Code'),
            content: qrCodeSvg,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      } catch (e) {
        print('Error decoding QR code: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load QR code')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No QR code available')),
      );
    }
  }




  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBlockedUsers() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Blocked Users',
            style: TextStyle(
              color: Color.fromRGBO(92, 75, 153, 1),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: blockeduser.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = blockeduser[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical:10),
                        child: ListTile(


                          leading: CircleAvatar(
                            backgroundImage: (user['profile_pic'] != null && user['profile_pic'].isNotEmpty)
                                ? MemoryImage(base64Decode(user['profile_pic'])) as ImageProvider
                                : AssetImage('assets/images/undraw_Profile_pic_re_iwgo.png'),
                            backgroundColor: Colors.deepPurple,
                          ),
                          




                          title: Text(
                            '${user['first_name']} ${user['last_name'] }',
                            style: TextStyle(
                              color: Color.fromRGBO(92, 75, 153, 1),
                              fontSize: 11,
                            ),
                          ),
                          subtitle: Text('Address: ${user['address']}' , style: TextStyle(fontSize: 11),),
                          trailing: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                unblockUser(user['id']);
                              });
                            },
                            child: Text('Unblock'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            // color: Color.fromRGBO(92, 75, 153, 1),
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileSearch()));
            },
            icon: Icon(Icons.search , color:  Colors.white,),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white), // Set the icon color here
            onSelected: (String value) {
              if (value == 'Blocked Users') {
                _showBlockedUsers();
              } else if (value == 'Join Date') {
                _showJoinDate();
              } else if (value == 'Show QR Code') {
                _showQrCodeDialog();
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Blocked Users', 'Join Date', 'Show QR Code'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),

        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    iconTheme: IconThemeData(color: Colors.black),
                    expandedHeight: MediaQuery.of(context).size.height * 0.35,
                    pinned: true,
                    floating: true,
                    snap: true,
                    leading: Container(),  // This removes the back button
                    flexibleSpace: FlexibleSpaceBar(
                      background: ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CircleAvatar(
                                radius: 50, // Adjust size as needed
                                backgroundImage: (userpro['profile_pic'] != null && userpro['profile_pic'].isNotEmpty)
                                    ? MemoryImage(base64Decode(userpro['profile_pic'])) as ImageProvider
                                    : AssetImage('assets/images/undraw_Profile_pic_re_iwgo.png'),
                                backgroundColor: Colors.deepPurple,
                              ),



                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FollowersListScreen()));
                                },
                                child: Column(
                                  children: [
                                    Text('Followers',
                                        style: TextStyle(fontSize: 18)),
                                    Text(
                                        userpro['followers']?.toString() ?? '0',
                                        style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FollowingListScreen()));
                                },
                                child: Column(
                                  children: [
                                    Text('Following',
                                        style: TextStyle(fontSize: 18)),
                                    Text(
                                        userpro['following']?.toString() ?? '0',
                                        style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    '${userpro['first_name'] ?? 'No'} ${userpro['last_name'] ?? 'Name'}',
                                    style: TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.bold,
                                      // color: Color.fromRGBO(92, 75, 153, 1),
                                    ),
                                  ),




                                  RatingBar.builder(
                                    itemSize: 20,
                                    minRating: 1,
                                    initialRating: (userpro['rating']?.toDouble() ?? 0.0),
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemPadding: EdgeInsets.symmetric(horizontal: 1),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    ignoreGestures: true, // Make the RatingBar read-only
                                    onRatingUpdate: (rating) {
                                      print(rating); // This won't be triggered because ignoreGestures is true
                                    },
                                  )






                                ],
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'Age: ${userpro['age']?.toString() ?? '0'}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(width: 12,),
                                  Text(
                                    'Points: ${userpro['points']?.toString() ?? '0'}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),

                              // SizedBox(height: 8),
                            ],
                          ),
                          SizedBox(height: 10),
                          SizedBox(height: 20),
                          Center(
                            child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditProfile()));
                                },
                                child: Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: <Widget>[
                        Tab(text: 'My Events'),
                        Tab(text: 'Attended Events'),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  MyEventsPage(),
                  EventsAttendedPage(),
                ],
              ),
            ),
    );
  }

  void _showJoinDate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Join Date',
            style: TextStyle(
              color: Color.fromRGBO(92, 75, 153, 1),
            ),
          ),
          content: Text(joinDate),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: Color.fromRGBO(92, 75, 153, 1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
