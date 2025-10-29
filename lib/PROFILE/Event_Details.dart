import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventDetailsPage extends StatelessWidget {
  final int eventId;
  final String? token;

  EventDetailsPage({required this.eventId, required this.token});

  Future<Map<String, dynamic>> fetchEventDetails() async {
    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/events/getEvent'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({'eventId': eventId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data.containsKey('event')) {
        return data['event'];
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load event details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Event Details',
        style: TextStyle(
          color:  Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchEventDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No event data found'));
          } else {
            final event = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: event['image'] != null && event['image'].isNotEmpty
                            ? NetworkImage(event['image'])
                            : AssetImage('assets/images/backimageticket.jpg') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text('Title: ${event['title']}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                          color:  Color.fromRGBO(92, 75, 153, 1),)),

                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Date: ${event['start_date']}', style: TextStyle(fontSize: 16,
                          color: Color.fromRGBO(159, 145, 204, 1),)),
                          Text('End Date: ${event['end_date']}', style: TextStyle(fontSize: 16,
                           color:  Color.fromRGBO(159, 145, 204, 1),)),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Paid: ${event['is_paid'] }', style: TextStyle(fontSize: 16,
                          color: Color.fromRGBO(159, 145, 204, 1),)),
                          Text('Private: ${event['is_private'] }', style: TextStyle(fontSize: 16,
                            color: Color.fromRGBO(159, 145, 204, 1),)),
                          Text('Attendance Type: ${event['attendance_type']}', style: TextStyle(fontSize: 16,
                            color: Color.fromRGBO(159, 145, 204, 1),),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Cost: ${event['total_cost']}', style: TextStyle(fontSize: 16,
                            color: Color.fromRGBO(159, 145, 204, 1),)),
                          Text('Ticket Price: ${event['ticket_price']}', style: TextStyle(fontSize: 16,
                            color: Color.fromRGBO(159, 145, 204, 1),)),
                          Text('VIP Ticket Price: ${event['vip_ticket_price']}', style: TextStyle(fontSize: 16,
                            color: Color.fromRGBO(159, 145, 204, 1),)),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rating: ${event['rating']}',
                              style: TextStyle(fontSize: 16,
                                color: Color.fromRGBO(159, 145, 204, 1),)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
