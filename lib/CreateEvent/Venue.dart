import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import 'create_event.dart';
import 'event_provider.dart';
import 'FurniturePage.dart';

class Venue extends StatefulWidget {
  const Venue({Key? key}) : super(key: key);

  @override
  State<Venue> createState() => _VenueState();
}

class _VenueState extends State<Venue> {
  List<Map<String, dynamic>> venues = [];
  final token =UserController.getToken();


  @override
  void initState() {
    super.initState();
    fetchVenues();
  }

  Future<void> fetchVenues() async {
    final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);
    final eventId = eventProvider.eventId;

    if (eventId == null) {
      print('No event ID found');
      return;
    }

    print('Fetching venues for eventId: $eventId');

    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/resources/available'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
        'Accept-Language': 'ar',
      },
      body: jsonEncode({
        'eventId': eventId,
        'resourceName': 'venue',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched data: $data');
      setState(() {
        venues = List<Map<String, dynamic>>.from(data['AvailableVenues']);
      });
    } else {
      print('Failed to load venues');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
  void _showDetailsDialog(Map<String, dynamic> venue) {
    final venueId = venue['id'];

    if (venueId == null) {
      print('VenueId is null in venue data');
      return;
    }

    // تحقق من أن venueId هو int
    if (venueId is! int) {
      print('VenueId is not an integer');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(venue['name']),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  venue['image'],
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 8),
                _buildDetail('Location', venue['location']),
                _buildDetail('Max Capacity', venue['max_capacity_no_chairs'].toString()),
                _buildDetail('Rating', venue['rating'].toString()),
                _buildDetail('Price', venue['cost'].toString()),
                _buildDetail('Location on Map', venue['location_on_map']),
                _buildDetail('Max Capacity with Chairs', venue['max_capacity_chairs'].toString()),
                _buildDetail('Chairs', venue['max_capacity_chairs'].toString()),
                _buildDetail('VIP Chairs', venue['vip_chairs'].toString()),
                _buildDetail('VIP', venue['is_vip'] == 1 ? 'Yes' : 'No'),
                _buildDetail('Website', venue['website']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close', style: TextStyle(color: Colors.deepPurple)),
            ),
            TextButton(
              onPressed: () {
                final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);
                eventProvider.setVenueId(venueId);
                print('Selected Venue ID: $venueId');

                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => FurniturePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                ));
              },
              child: Text('Select', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  Future<String> _cancelEvent() async {
    try {
      final eventId = Provider.of<CreateEventProvider>(context, listen: false).eventId;

      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/events/remove'),
        headers: {
          'Content-Type': 'application/json',
"Authorization": "Bearer $token",       },
        body: jsonEncode({
          'eventId': eventId,
          'desire': 'cancel',
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Event cancelled successfully!');
        return jsonResponse['message'] ?? 'Event cancelled successfully!';
      } else {
        print('Failed to cancel event. Status code: ${response.statusCode}');
        return 'Failed to cancel event: ${response.statusCode}';
      }
    } catch (e) {
      print('Error cancelling event: $e');
      return 'Error cancelling event: $e';
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Event'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.deepPurple)),
              onPressed: () async {

                final responseMessage = await _cancelEvent();


                Navigator.of(context).pop();


                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(responseMessage)),
                  );


                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CreateEvent()),
                  );
                });
              },
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
        title: Center(child: Text('Venue',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Satisfy',fontSize: 30),)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: venues.length,
            itemBuilder: (context, index) {
              final venue = venues[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text(
                    venue['name'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    venue['location'],
                    style: TextStyle(fontSize: 18),
                  ),
                  leading: venue['image'] != null
                      ? Image.network(
                    venue['image'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                      : null,
                  onTap: () {
                    _showDetailsDialog(venue);
                  },
                ),
              );
            },

          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:ElevatedButton(
                onPressed: () => _showSuccessDialog('Are you sure you want to cancel the event?'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Cancel Event',
                  style: TextStyle(fontSize: 20,fontFamily: 'Satisfy',fontWeight: FontWeight.bold),
                ),

              ),
            ),
          )

        ],
      ),
    );
  }}
