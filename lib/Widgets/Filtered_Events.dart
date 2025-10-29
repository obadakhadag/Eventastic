import 'package:flutter/material.dart';
import './Event_DetailsPage.dart';

class FilteredEvents extends StatelessWidget {
  final List<dynamic> events;

  const FilteredEvents({
    Key? key,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 190,
              child: Image.asset('assets/images/newZ.png', fit: BoxFit.cover),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height*0.45,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final imageUrl = event['image'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                margin: EdgeInsets.all(2),
                width: 100.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(23.0),
                ),
                child: Container(
                  child: ListTile(
                    leading: Hero(
                      tag: 'eventImage_$index',
                      child: Container(
                        height: 53,
                        width: 65,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    title: Text(
                      event['title'],
                      style: TextStyle(
                        fontSize: 25,  // Adjusted to a more standard size
                        fontFamily: 'PlayfairDisplay',
                        fontWeight: FontWeight.bold,  // Added bold for emphasis
                      ),
                    ),
                    // subtitle: Text(
                    //   event['description_en'] ?? 'No description available',
                    //   style: TextStyle(
                    //     fontSize: 19,  // Adjusted for a readable subtitle size
                    //     color: Colors.black54,  // Slightly darker for better contrast
                    //   ),
                    // ),
                    trailing: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 500),
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return FadeTransition(
                                opacity: animation,
                                child: EventDetailsPage(
                                  EventId: event['id'],
                                  imageUrl: event['image'],
                                  eventName: event['title'],
                                  eventDescription: event['description_en'] ?? 'No description available',
                                  startDate: event['start_date'],
                                  endDate: event['end_date'],
                                  minAge: event['min_age'],
                                  isPaid: event['is_paid'],
                                  isPrivate: event['is_private'],
                                  attendanceType: event['attendance_type'],
                                  totalCost: event['total_cost'],
                                  ticketPrice: event['ticket_price'],
                                  vipTicketPrice: event['vip_ticket_price'],
                                  qrCode: event['qr_code'],
                                  rating: event['rating'],
                                  isFavourite: event['isFavourite'],
                                  heroTag: 'eventImage_$index',
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: Text(
                        'Join ',
                        style: TextStyle(fontSize: 15, color: Colors.purple),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
