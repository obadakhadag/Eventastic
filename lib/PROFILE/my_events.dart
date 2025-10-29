import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/PROFILE/profile_page.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';

import '../controllers/user_controller.dart';
import 'EventReservationsPage.dart';
import 'Event_Details.dart';
import 'InviteToEventPage.dart';
import 'User_event_provider.dart';

class MyEventsPage extends StatefulWidget {
  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  List<dynamic> _events = [];
  List<dynamic> _updateevents = [];
  bool isLoading = true;
  final token = UserController.getToken();

  @override
  void initState() {
    super.initState();
    fetchCreatedEvent();
    fetchUpdateEvent();
  }

  Future<void> fetchCreatedEvent() async {
    try {
      print('Token: $token');
      print('Attempting to fetch events...');

      final response = await http.get(
        Uri.parse('http://192.168.7.39:8000/api/users/eventsCreatedHistory'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('createdEvents')) {
          setState(() {
            _events = data['createdEvents'];
            isLoading = false;
          });
        } else {
          print('Unexpected response format');
          setState(() {
            isLoading = false;
          });
        }
        print('Events fetched successfully');
        print('Extracted events: $_events');
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

  Future<void> fetchUpdateEvent() async {
    try {
      print('Token: $token');
      print('Attempting to fetch events...');

      final response = await http.get(
        Uri.parse('http://192.168.7.39:8000/api/users/getCreatedUpdatableEvents'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('upComingEvents')) {
          setState(() {
            _updateevents = data['upComingEvents'];
            isLoading = false;
          });
        } else {
          print('Unexpected response format');
          setState(() {
            isLoading = false;
          });
        }
        print('Events fetched successfully');
        print('Extracted events: $_updateevents');
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

  Future<void> deleteEvent(int eventId) async {
    final String url = 'http://192.168.7.39:8000/api/events/remove';
    final token = UserController.getToken();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'eventId': eventId,
          'desire': 'delete',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Event deleted: ${data['message']}');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );

        // Optionally, refresh the list of events
        setState(() {
          _updateevents.removeWhere((event) => event['id'] == eventId);
        });
      } else {
        print('Failed to delete event. Status code: ${response.statusCode}');
        print(response.body);
        // Show failure message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete the event. Please try again.')),
        );
      }
    } catch (e) {
      print('Exception caught while deleting event: $e');
      // Show exception message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  Future<Map<String, dynamic>> fetchEventReservations(int eventId) async {
    final token = UserController.getToken();
    final url = Uri.parse('http://192.168.7.39:8000/api/events/getEventReservations');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({'eventId': eventId}),
    );

    if (response.statusCode == 200) {
      print('fetching event reservation works with status code: 200');
      return jsonDecode(response.body);
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load reservations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.purple.withAlpha(15),
        body: Column(
          children: [
            SizedBox(height: 30),
            Text(
              'Events Created',
              style: TextStyle(
                fontSize: 25,
                color: Color.fromRGBO(92, 75, 153, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 150,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _events.isEmpty
                  ? Center(child: Text('No events found'))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _events.length,
                itemBuilder: (_, index) {
                  var event = _events[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(eventId: event['id'], token: token),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey.withAlpha(60),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              child: Image.network(
                                event['image'],
                                height: 80,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                    width:110,
                                    child: FittedBox(child: Text(event['title'] ?? 'No title'))),
                                Icon(
                                  event['isFavourite'] ? Icons.favorite : Icons.favorite_border,
                                  color: event['isFavourite'] ? Colors.red : Colors.black,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              'Updatable Events',
              style: TextStyle(
                color: Color.fromRGBO(92, 75, 153, 1),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _updateevents.isEmpty
                  ? Center(child: Text('No events found'))
                  : ListView.builder(
                itemCount: _updateevents.length,
                itemBuilder: (context, index) {
                  var event = _updateevents[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(eventId: event['id'], token: token),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(event['image'],
                                    height: 100, width: 100, fit: BoxFit.cover),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['title'] ?? "No title",
                                      style: TextStyle(
                                        color: Color.fromRGBO(92, 75, 153, 1),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),


                                    Text(
                                      event['start_date'].toString() ?? "0",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.update),
                                    onPressed: () async {
                                      final reservations = await fetchEventReservations(event['id']);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EventReservationsPage(
                                            reservations: reservations,
                                            eventId: event['id'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.person_add),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => InviteToEventPage( eventId: event['id']),
                                            ),
                                          );
                                        },
                                      ),



                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          bool? confirmDelete = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Confirm Deletion'),
                                                content: Text('Are you sure you want to delete this event?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context).pop(false);
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Yes'),
                                                    onPressed: () {
                                                      Navigator.of(context).pop(true);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirmDelete == true) {
                                            await deleteEvent(event['id']);
                                          }
                                        },
                                      ),




                                    ],
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
