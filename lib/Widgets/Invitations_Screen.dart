import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:our_mobile_app/controllers/user_controller.dart';

class InvitationScreen extends StatefulWidget {
  @override
  _InvitationScreenState createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  final String apiUrl = 'http://192.168.7.39:8000/api/users/getInvitations';
  final String? token = UserController.getToken(); // Replace with your token
  List<dynamic> invitedList = [];
  List<dynamic> otherList = [];
  bool isLoading = true;
  bool isProcessing = false; // Handles both deleting and confirming

  @override
  void initState() {
    super.initState();
    fetchInvitations('INVITED');
    fetchInvitations('OTHER');
  }

  Future<void> fetchInvitations(String type) async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'type': type,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        if (type == 'INVITED') {
          invitedList = data['invitations'];
        } else {
          otherList = data['invitations'];
        }
        isLoading = false;
      });

      print('fetching invitations works perfectly: ');
      print(response.statusCode);
      print(response.body);

    } else if (response.statusCode == 404) {
      setState(() {
        isLoading = false;
      });

      print('there are no invitations');
      print(response.statusCode);
      print(response.body);

    } else {
      throw Exception('Failed to load invitations');
    }
  }

  Future<void> confirmInvitation(int invitationId) async {
    setState(() {
      isProcessing = true;
    });

    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/attendees/confirmInvitation'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'attendeeId': invitationId}),
    );

    setState(() {
      isProcessing = false;
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text(data['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                fetchInvitations('INVITED');
                fetchInvitations('OTHER');
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      print (response.body);
      print (response.statusCode);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Failed'),
          content: Text('Failed to confirm this invitation. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      print('Failed to confirm invitation');
    }
  }

  Future<void> showConfirmInvitationDialog(int invitationId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Invitation'),
        content: Text('Are you sure you want to confirm this invitation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              confirmInvitation(invitationId);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteInvitation(int invitationId) async {
    setState(() {
      isProcessing = true;
    });

    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/attendees/cancelInvitation'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'attendeeId': invitationId}),
    );

    setState(() {
      isProcessing = false;
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text(data['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                fetchInvitations('INVITED');
                fetchInvitations('OTHER');
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Failed'),
          content: Text('Failed to delete this invitation. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      print('Failed to delete invitation');
    }
  }

  void showDeleteConfirmationDialog(int invitationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this invitation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteInvitation(invitationId);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Invitations'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Invited' ),
              Tab(text: 'Other'),
            ],
            labelColor: Colors.white, // Sets the color of the selected tab text
            unselectedLabelColor: Colors.white, // Sets the color of the unselected tab text
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            TabBarView(
              children: [
                buildInvitationList(invitedList, true),
                buildInvitationList(otherList, false),
              ],
            ),
            if (isProcessing)
              Center(
                child: Container(
                  color: Colors.black54,
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildInvitationList(List<dynamic> invitations, bool isInvited) {
    if (invitations.isEmpty) {
      return Center(child: Text('No invitations found.'));
    }

    return ListView.builder(
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final invitation = invitations[index];
        return Card(
          elevation: 2,
          child: ListTile(
            title: Text('Invitation ID: ${invitation['id']}'),
            subtitle: Text('Event ID: ${invitation['event_id']}'),
            trailing: isInvited
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check  , color:  Colors.green,),
                  onPressed: () => showConfirmInvitationDialog(invitation['id']),
                ),
                IconButton(
                  icon: Icon(Icons.delete  , color:  Colors.red,),
                  onPressed: () => showDeleteConfirmationDialog(invitation['id']),
                ),
              ],
            )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvitationDetailScreen(invitation: invitation),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class InvitationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> invitation;

  InvitationDetailScreen({required this.invitation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invitation Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invitation ID: ${invitation['id']}'),
            Text('Status: ${invitation['status']}'),
            Text('Event ID: ${invitation['event_id']}'),
            Text('QR Code: ${invitation['qr_code']}'),
            Text('User ID: ${invitation['user_id']}'),
            Text('Checked In: ${invitation['checked_in']}'),
            Text('Purchase Date: ${invitation['purchase_date']}'),
            Text('Ticket Price: ${invitation['ticket_price']}'),
            Text('Seat Number: ${invitation['seat_number']}'),
            Text('Discount: ${invitation['discount']}'),
            Text('Is Main Scanner: ${invitation['is_main_scanner']}'),
            Text('Is Scanner: ${invitation['is_scanner']}'),
          ],
        ),
      ),
    );
  }
}
