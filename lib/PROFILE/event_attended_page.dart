import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import 'Attended_Event_DetailsPage.dart';
import 'Event_Details.dart';

class EventsAttendedPage extends StatefulWidget {
  EventsAttendedPage({super.key});

  @override
  State<EventsAttendedPage> createState() => _EventsAttendedPageState();
}

class _EventsAttendedPageState extends State<EventsAttendedPage> {
  List<dynamic> _eventsAttend = [];
  bool isLoading = true;
  final token = UserController.getToken();
  int? _expandedEventIndex;

  @override
  void initState() {
    super.initState();
    fetchAttendedEvent();
  }

  Future<void> fetchAttendedEvent() async {
    try {
      print('Token: $token');
      print('Attempting to fetch events...');

      final response = await http.get(
        Uri.parse('http://192.168.7.39:8000/api/users/getAttendedEvents'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('AttendedEvents')) {
          setState(() {
            _eventsAttend = data['AttendedEvents'];
            isLoading = false;
          });
        } else {
          print('Unexpected response format');
          setState(() {
            isLoading = false;
          });
        }
        print('Events fetched successfully');
        print('Extracted events: $_eventsAttend');
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

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedEventIndex == index) {
        _expandedEventIndex = null; // Collapse if already expanded
      } else {
        _expandedEventIndex = index; // Expand the selected item
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.purple.withAlpha(15),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : _eventsAttend.isEmpty
            ? Center(child: Text('No events found'))
            : ListView.builder(
          itemCount: _eventsAttend.length,
          itemBuilder: (context, index) {
            var event = _eventsAttend[index];

            final ticketType = event['ticket_type'];

            final isExpanded = _expandedEventIndex == index;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  AttendedEventDetailsPage(eventId: event['id'], token: token),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // CircleAvatar(
                            //   radius: 30,
                            //   backgroundImage: event['image'] != null && event['image']!.isNotEmpty
                            //       ? NetworkImage(event['image']!)
                            //       : AssetImage('assets/images/backimageticket.jpg') as ImageProvider,
                            // ),

                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Event ID: ${event['event_id']}',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 75, 153, 1),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text('Seat Number : ${event['seat_number']}',
                                    style: TextStyle(
                                        color: Color.fromRGBO(92, 75, 153, 1),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Icon(
                                    event['isFavourite'] ? Icons.favorite : Icons.favorite_border,
                                    color: event['isFavourite'] ? Colors.red : Colors.black,
                                  )

                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                              onPressed: () => _toggleExpand(index),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: isExpanded ? 50 : 0,
                        curve: Curves.easeInOut,
                        child: isExpanded
                            ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: Text(
                                'Ticket Type: $ticketType',
                                style: TextStyle(color: Color.fromRGBO(92, 75, 153, 1), fontSize: 16),
                              ),
                            ),
                          ),
                        )
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
