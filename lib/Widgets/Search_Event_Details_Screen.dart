import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/controllers/user_controller.dart';

class SearchEventDetailsScreen extends StatefulWidget {
  final int eventId;

  SearchEventDetailsScreen({required this.eventId});

  @override
  _SearchEventDetailsScreenState createState() => _SearchEventDetailsScreenState();
}

class _SearchEventDetailsScreenState extends State<SearchEventDetailsScreen> {
  Map<String, dynamic>? eventDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    final token = UserController.getToken();

    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/events/searchEventsByQR'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        'eventId': widget.eventId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        eventDetails = jsonDecode(response.body)['event'][0];
        isLoading = false;
      });
    } else {
      // Handle error
      print('Failed to fetch event details: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${eventDetails!['title']}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Image.network(eventDetails!['image']),
            SizedBox(height: 16),
            Text('Description (EN): ${eventDetails!['description_en']}'),
            Text('Description (AR): ${eventDetails!['description_ar']}'),
            Text('Start Date: ${eventDetails!['start_date']}'),
            Text('End Date: ${eventDetails!['end_date']}'),
            Text('Minimum Age: ${eventDetails!['min_age']}'),
            Text('Is Paid: ${eventDetails!['is_paid'] == 1 ? "Yes" : "No"}'),
            Text('Attendance Type: ${eventDetails!['attendance_type']}'),
            Text('Total Cost: \$${eventDetails!['total_cost']}'),
            Text('Ticket Price: \$${eventDetails!['ticket_price']}'),
            Text('VIP Ticket Price: \$${eventDetails!['vip_ticket_price']}'),
            Text('Rating: ${eventDetails!['rating']}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
