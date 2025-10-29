import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../controllers/CalendarEventsProvider.dart';
import '../../../controllers/Language_Provider.dart';
import '../../../models/CalendarEvents.dart';
import '../../../models/Localization.dart';

class MyCalendarPage extends StatefulWidget {
  @override
  _MyCalendarPageState createState() => _MyCalendarPageState();
}

class _MyCalendarPageState extends State<MyCalendarPage> {
  late Future<void> _fetchEventsFuture;

  @override
  void initState() {
    super.initState();
    _fetchEventsFuture = _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    await Provider.of<CalendarEventsProvider>(context, listen: false).fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    var calendarEventsProvider = Provider.of<CalendarEventsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title:  Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            String mostPopularText = languageProvider.isEnglish
                ? Localization.en['calendarEvents']!
                : Localization.ar['calendarEvents']!;

            return Text(
              mostPopularText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                fontFamily: 'PlayfairDisplay',
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _fetchEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          } else {
            if (calendarEventsProvider.events.isEmpty) {
              return Center(child: Text('There are no events right now'));
            }
            return Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TableCalendar<CalendarEvent>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  eventLoader: (day) => _getEventsForDay(day, calendarEventsProvider.events),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      final eventImages = events.map((e) => e.image).toList();
                      if (eventImages.isNotEmpty) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: GestureDetector(
                                  onTap: () => _showEventDetails(context, events),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(eventImages[0]), // Show the first image
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  List<CalendarEvent> _getEventsForDay(DateTime day, List<CalendarEvent> allEvents) {
    return allEvents.where((event) => _isSameDay(event.startDate, day)).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void _showEventDetails(BuildContext context, List<CalendarEvent> events) {
    // For simplicity, show a dialog with event details
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Event Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: events.map((event) {
              return Column(
                children: [
                  Image.network(event.image),
                  SizedBox(height: 10),
                  Text('Title: ${event.title}'),
                  Text('Date: ${event.startDate.toString()}'), // Display the start date as a string
                ],
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
