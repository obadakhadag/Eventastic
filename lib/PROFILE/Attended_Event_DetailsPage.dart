import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AttendedEventDetailsPage extends StatefulWidget {
  final int eventId;
  final String? token;

  AttendedEventDetailsPage({required this.eventId, required this.token});

  @override
  _AttendedEventDetailsPageState createState() => _AttendedEventDetailsPageState();
}

class _AttendedEventDetailsPageState extends State<AttendedEventDetailsPage> {
  Future<Map<String, dynamic>> fetchEventDetails() async {
    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/events/getEvent'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json'
      },
      body: json.encode({'eventId': widget.eventId}),
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

  Future<void> _rateEvent(int eventId) async {
    double venueRating = 5;
    double decorRating = 5;
    double musicRating = 5;
    double foodRating = 5;
    double drinkRating = 5;
    String comment = '';

    bool rateVenue = false;
    bool rateDecor = false;
    bool rateMusic = false;
    bool rateFood = false;
    bool rateDrink = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Rate the Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: Text('Rate Venue'),
                      value: rateVenue,
                      onChanged: (bool? value) {
                        setState(() {
                          rateVenue = value ?? false;
                        });
                      },
                    ),
                    if (rateVenue)
                      Slider(
                        value: venueRating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: venueRating.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            venueRating = value;
                          });
                        },
                      ),
                    CheckboxListTile(
                      title: Text('Rate Decor'),
                      value: rateDecor,
                      onChanged: (bool? value) {
                        setState(() {
                          rateDecor = value ?? false;
                        });
                      },
                    ),
                    if (rateDecor)
                      Slider(
                        value: decorRating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: decorRating.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            decorRating = value;
                          });
                        },
                      ),
                    CheckboxListTile(
                      title: Text('Rate Music'),
                      value: rateMusic,
                      onChanged: (bool? value) {
                        setState(() {
                          rateMusic = value ?? false;
                        });
                      },
                    ),
                    if (rateMusic)
                      Slider(
                        value: musicRating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: musicRating.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            musicRating = value;
                          });
                        },
                      ),
                    CheckboxListTile(
                      title: Text('Rate Food'),
                      value: rateFood,
                      onChanged: (bool? value) {
                        setState(() {
                          rateFood = value ?? false;
                        });
                      },
                    ),
                    if (rateFood)
                      Slider(
                        value: foodRating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: foodRating.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            foodRating = value;
                          });
                        },
                      ),
                    CheckboxListTile(
                      title: Text('Rate Drinks'),
                      value: rateDrink,
                      onChanged: (bool? value) {
                        setState(() {
                          rateDrink = value ?? false;
                        });
                      },
                    ),
                    if (rateDrink)
                      Slider(
                        value: drinkRating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: drinkRating.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            drinkRating = value;
                          });
                        },
                      ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Comment',
                      ),
                      onChanged: (value) {
                        comment = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),


                TextButton(

                  onPressed: () async {
                    // Prepare the rating data dynamically based on the user's selection
                    Map<String, dynamic> ratingData = {
                      'event_id': eventId,
                      'comment': comment,
                    };

                    if (rateVenue) ratingData['venue_rating'] = venueRating;
                    if (rateDecor) ratingData['decor_rating'] = decorRating;
                    if (rateMusic) ratingData['music_rating'] = musicRating;
                    if (rateFood) ratingData['food_rating'] = foodRating;
                    if (rateDrink) ratingData['drink_rating'] = drinkRating;

                    // Send the rating to the API
                    final response = await http.post(
                      Uri.parse('http://192.168.7.39:8000/api/events/rateEvent'),
                      headers: {
                        'Authorization': 'Bearer ${widget.token}',
                        'Content-Type': 'application/json'
                      },
                      body: json.encode(ratingData),
                    );

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Rating submitted successfully!')),
                      );
                    } else {
                      // Print the response body if the status code is not 200
                      print('Error: ${response.statusCode}');
                      print('Response body: ${response.body}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to submit rating')),
                      );
                    }

                    Navigator.of(context).pop();
                  },
                  child: Text('Submit' , style: TextStyle(color: Colors.deepPurple , fontWeight: FontWeight.bold  ),),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Event Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                      child: Text(
                        event['title'] ?? 'Event Title',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(92, 75, 153, 1),
                        ),
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
                          Text(
                            'Start Date: ${event['start_date']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(159, 145, 204, 1),
                            ),
                          ),
                          Text(
                            'End Date: ${event['end_date']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(159, 145, 204, 1),
                            ),
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
                          Text(
                            'Total Cost: ${event['total_cost']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(159, 145, 204, 1),
                            ),
                          ),
                          Text(
                            'Ticket Price: ${event['ticket_price']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(159, 145, 204, 1),
                            ),
                          ),
                          Text(
                            'VIP Ticket Price: ${event['vip_ticket_price']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(159, 145, 204, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _rateEvent(widget.eventId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(159, 145, 204, 1),
                    ),
                    child: Text(
                      'Rate Event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
