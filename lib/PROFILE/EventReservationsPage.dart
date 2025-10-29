import 'package:flutter/material.dart';

import 'ReservationDetailsPage.dart';

class EventReservationsPage extends StatelessWidget {
  final Map<String, dynamic> reservations;
  final int eventId;

  EventReservationsPage({required this.reservations, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Reservations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.chair, color: Colors.brown),
                title: Text('Furniture Reservations'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationDetailsPage(
                        eventId: eventId,
                        reservations: reservations['furniture_reservations'],
                        category: 'Furniture',
                      ),
                    ),
                  );
                },
              ),
            ),
            // Card(
            //   elevation: 2,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: ListTile(
            //     leading: Icon(Icons.music_note, color: Colors.blue),
            //     title: Text('Music Reservations'),
            //     onTap: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => ReservationDetailsPage(
            //             reservations: reservations['music_reservations'],
            //             category: 'Music',
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.security, color: Colors.red),
                title: Text('Security Reservations'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationDetailsPage(
                        eventId: eventId,

                        reservations: reservations['security_reservations'],
                        category: 'Security',
                      ),
                    ),
                  );
                },
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.fastfood, color: Colors.green),
                title: Text('Food Reservations'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationDetailsPage(
                        eventId: eventId,

                        reservations: reservations['food_reservations'],
                        category: 'Food',
                      ),
                    ),
                  );
                },
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.local_drink, color: Colors.blueAccent),
                title: Text('Drink Reservations'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationDetailsPage(
                        eventId: eventId,

                        reservations: reservations['drink_reservations'],
                        category: 'Drinks',
                      ),
                    ),
                  );
                },
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.celebration, color: Colors.purple),
                title: Text('Decoration Item Reservations'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationDetailsPage(
                        eventId: eventId,

                        reservations: reservations['decoration_item_reservations'],
                        category: 'Decorations',
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
