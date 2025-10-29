import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 decoding
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/controllers/user_controller.dart';

import 'TicketDetailScreen.dart';

class TicketScreenNow extends StatefulWidget {
  @override
  _TicketScreenNowState createState() => _TicketScreenNowState();
}

class _TicketScreenNowState extends State<TicketScreenNow> {
  List<dynamic> tickets = [];

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    final token = UserController.getToken(); // Replace with your actual token
    final response = await http.get(
      Uri.parse('http://192.168.7.39:8000/api/events/getPurchasedTickets'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        tickets = data['purchasedTickets'];
      });
    } else {
      print(response.body);
      print(response.statusCode);

      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tickets'),
      ),
      body: tickets.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Event ID: ${ticket['event_id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seat Number: ${ticket['seat_number']}'),
                  Text('Ticket Type: ${ticket['ticket_type']}'),
                  Text('Purchase Date: ${ticket['purchase_date']}'),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketDetailScreen(ticket),
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
