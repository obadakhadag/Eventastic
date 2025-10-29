import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/EventProvider.dart';
import '../controllers/Theme_Provider.dart';
import '../models/most_p_events.dart';
import 'detailsScreenforMostPopular.dart';



class MostPopular extends StatefulWidget {
  @override
  _MostPopularState createState() => _MostPopularState();
}

class _MostPopularState extends State<MostPopular> {
  late Future<void> _fetchEventsFuture;
   bool IsFav = false  ;


  @override
  void initState() {
    super.initState();
    _fetchEventsFuture = _fetchEvents();


  }

  Future<void> _fetchEvents() async {
    print('Calling fetchEvents...');
    await Provider.of<EventProvider>(context, listen: false).fetchEvents();
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy/MM/dd').format(parsedDate);
  }



  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FutureBuilder<void>(
      future: _fetchEventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load events'));
        } else {
          return Consumer<EventProvider>(
            builder: (context, eventProvider, child) {
              if (eventProvider.events.isEmpty) {
                return Center(child: Text('No events found'));
              } else {
                final events = eventProvider.events;
                return Container(
                  margin: EdgeInsets.all(3),
                  height: 215.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsScreenForMostPopular(event: event),
                              ),
                            );
                          },
                          child: Stack(children: [
                            // Background
                            Positioned(
                              child: Container(
                                width: 240,
                                height: 220,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey, width: 1.0),
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: themeProvider.isDarkTheme ? Colors.grey[700] : Colors.white ,
                                ),
                              ),
                            ),

                            // Image Container
                            Positioned(
                              top: 2,
                              right: 2,
                              left: 2,
                              bottom: 52,
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                  ),
                                  margin: EdgeInsets.all(2),
                                  child: Image.network(
                                    event.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                      return Container(
                                        color: Colors.black,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.white,
                                            size: 50.0,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            // Event Category
                            Positioned(
                              top: 2.0,
                              left: 4.0,
                              child: Container(
                                margin: EdgeInsets.all(8),
                                height: 25,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: themeProvider.isDarkTheme ? Colors.grey[300] : Colors.white ,
                                  borderRadius: BorderRadius.all(Radius.circular(40)),
                                ),
                                child: Center(
                                  child: FittedBox(
                                    child: Text(
                                      event.categoryId.toString(),
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        fontFamily: 'PlayfairDisplay',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Favorite Icon
                            Positioned(
                              bottom: 60,
                              right: 9.0,
                              child: Container(
                                height: 39,
                                width: 39,
                                decoration: BoxDecoration(
                                  color: themeProvider.isDarkTheme ? Colors.grey[300] : Colors.white ,
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                ),
                                child: Consumer<EventProvider>(
                                  builder: (context, eventProvider, child) {
                                    // event.isFavorite
                                    return IconButton(
                                      icon: Icon(
                                        event.isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
                                        color: event.isFavorite ? Colors.red : Colors.black,
                                      ),
                                      onPressed: () {
                                        eventProvider.toggleFavorite(event);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Event Details
                            Positioned(
                              top: 155,
                              right: 5,
                              left: 5,
                              bottom: 0,
                              child: Container(
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: themeProvider.isDarkTheme ? Colors.grey[700] : Colors.white ,
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                ),
                                margin: EdgeInsets.all(2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row for title and start date
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            event.title,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontFamily: 'PlayfairDisplay',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          _formatDate(event.startDate),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontFamily: 'PlayfairDisplay',
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Ticket price
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                         'Ticket Price :  ${event.ticketPrice.toString()} \$ ',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            // fontFamily: 'PlayfairDisplay',
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 3),
                                          child: Icon(
                                            event.isPrivate == 0 ? Icons.lock_open : Icons.lock,
                                            color: Colors.black,
                                            size: 20, // Adjust the size as needed
                                          ),

                                        ),

                                        // SizedBox(width: 0,)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
