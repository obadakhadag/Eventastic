import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../controllers/user_controller.dart';
import '../models/Follower.dart';

class InviteToEventPage extends StatefulWidget {
  final int eventId;

  InviteToEventPage({required this.eventId});

  @override
  _InviteToEventPageState createState() => _InviteToEventPageState();
}

class _InviteToEventPageState extends State<InviteToEventPage> {
  List<dynamic> _invitedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvitedUsers();
  }

  Future<void> fetchInvitedUsers() async {
    final token = UserController.getToken();
    final url = Uri.parse('http://192.168.7.39:8000/api/attendees/getInvitedUsers');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'eventId': widget.eventId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _invitedUsers = data['invitedUsers'];
          isLoading = false;
        });
      } else {
        print('Failed to load invited users. Status code: ${response.statusCode}');
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


  Future<void> sendInvitation(int userId, int eventId, String ticketType) async {
    final token = UserController.getToken();
    final url = Uri.parse('http://192.168.7.39:8000/api/attendees/sendInvitation');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'eventId': eventId,
          'ticketType': ticketType,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print(responseData['message']);
      } else {
        print (response.body);
        // print (response.b);
        print('Failed to send invitation. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }



  Future<List<Follower>> fetchFollowers() async {
    final token = UserController.getToken();
    final url = Uri.parse('http://192.168.7.39:8000/api/users/getFollowers');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('fetching followers is work ');
        final data = json.decode(response.body);
        List<dynamic> followersJson = data['Followers'];
        return followersJson.map((json) => Follower.fromJson(json)).toList();
      } else {
        print(response.body);
        print(response.statusCode);
        throw Exception('Failed to load followers');
      }
    } catch (e) {
      print('Ecception part ');
      print('Exception caught: $e');
      return [];
    }
  }




  void showInviteDialog(BuildContext context, int eventId) async {
    List<Follower> followers = await fetchFollowers();
    Map<int, String> selectedFollowers = {};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Invite Followers'),
              content: followers.isEmpty
                  ? Text('No followers available.')
                  : Container(
                // Added a fixed height to avoid the layout error
                height: 300.0,
                width: double.maxFinite, // To make sure it takes the available width
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: followers.length,
                        itemBuilder: (context, index) {
                          var follower = followers[index];
                          return CheckboxListTile(
                            title: Text('${follower.firstName} ${follower.lastName}'),
                            subtitle: Text('Rating: ${follower.rating}'),
                            value: selectedFollowers.containsKey(follower.id),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  selectedFollowers[follower.id] = 'VIP';
                                } else {
                                  selectedFollowers.remove(follower.id);
                                }
                              });
                            },
                            secondary: DropdownButton<String>(
                              value: selectedFollowers[follower.id],
                              items: <String>['VIP', 'Regular'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  if (selectedFollowers.containsKey(follower.id)) {
                                    selectedFollowers[follower.id] = newValue!;
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    for (var entry in selectedFollowers.entries) {
                      await sendInvitation(entry.key, eventId, entry.value);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Send Invitations'),
                ),
              ],
            );
          },
        );
      },
    );
  }



  void showInviteMoreDialog(BuildContext context, int eventId) async {
    List<Follower> followers = await fetchNotInvitedFollowers(eventId);
    Map<int, String> selectedFollowers = {};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Invite More Followers'),
              content: followers.isEmpty
                  ? Text('No more followers to invite.')
                  : Container(
                height: 300.0,
                width: double.maxFinite,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: followers.length,
                        itemBuilder: (context, index) {
                          var follower = followers[index];
                          return CheckboxListTile(
                            title: Text('${follower.firstName} ${follower.lastName}'),
                            subtitle: Text('Rating: ${follower.rating}'),
                            value: selectedFollowers.containsKey(follower.id),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  selectedFollowers[follower.id] = 'VIP';
                                } else {
                                  selectedFollowers.remove(follower.id);
                                }
                              });
                            },
                            secondary: DropdownButton<String>(
                              value: selectedFollowers[follower.id],
                              items: <String>['VIP', 'Regular'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  if (selectedFollowers.containsKey(follower.id)) {
                                    selectedFollowers[follower.id] = newValue!;
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    for (var entry in selectedFollowers.entries) {
                      await sendInvitation(entry.key, eventId, entry.value);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Invit More'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Follower>> fetchNotInvitedFollowers(int eventId) async {
    final token = UserController.getToken();
    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/attendees/getFollowingToInvite'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'eventId': eventId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Follower> followers = (data['Following'] as List)
          .map((followerJson) => Follower.fromJson(followerJson))
          .toList();
      return followers;
    } else {
      throw Exception('Failed to load followers');
    }
  }

  void showResponseDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invitation Status'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }



  Future<void> _refreshPage() async {
    setState(() {
      isLoading = true;
    });
    await fetchInvitedUsers();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite to Event'),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.saved_search_outlined, color:  Colors.white,))
        ],
      ),
      body:  isLoading
          ? Center(child: CircularProgressIndicator())
         : RefreshIndicator(
           onRefresh: _refreshPage,
               child: _invitedUsers.isEmpty
               ? Center(
             child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text(
              'There are no invited people. Try to invite someone to your event.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Aligns the button to the right
              children: [
                Padding(

                  padding: EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () {
                      showInviteDialog(context, widget.eventId);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Text color
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding inside the button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Rounded corners
                      ),
                      elevation: 5, // Shadow elevation
                    ),
                    child: Text(
                      'Invite',
                      style: TextStyle(
                        fontSize: 16, // Text size
                        fontWeight: FontWeight.bold, // Text style
                      ),
                    ),
                  ),
                ),
              ],
            )


          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _invitedUsers.length,
              itemBuilder: (context, index) {
                var user = _invitedUsers[index];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text('User Name: ${user['userFullName']}'),
                    subtitle: Text('Ticket Type: ${user['ticket_type']}'),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Aligns the button to the right
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: () {
                    showInviteMoreDialog(context, widget.eventId);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding inside the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                    ),
                    elevation: 5, // Shadow elevation
                  ),
                  child: Text('Invite More',
                    style: TextStyle(
                      fontSize: 16, // Text size
                      fontWeight: FontWeight.bold, // Text style
                    ),
                  ),
                ),
              ),
            ],
          )

        ],
      ),)
    );
  }
}
