import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import 'Venue.dart';
import 'create_event.dart';
import 'event_provider.dart';

class Event_type extends StatefulWidget {
  const Event_type({Key? key}) : super(key: key);

  @override
  State<Event_type> createState() => _Event_typeState();
}

class _Event_typeState extends State<Event_type> {
  List<Category> categories = [];
  final token = UserController.getToken();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/resources/categories'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
        'Accept-Language': 'ar',
      },
      body: json.encode({"type": "categories"}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Category> loadedCategories = [];
      for (var item in data['Categories']) {
        loadedCategories.add(Category.fromJson(item));
      }
      setState(() {
        categories = loadedCategories;
      });
    } else {
      print('Failed to load categories');
    }
  }

  Future<void> submitEvent(int categoryId, String categoryName, String description) async {
    final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);
    final eventData = eventProvider.getEventData();

    final String attendanceType = eventData['attendanceType']['isInvitation'] ? 'INVITATION' : 'TICKET';

    final String formattedStartDate = eventData['startDate'] as String;
    final String formattedEndDate = eventData['endDate'] as String;

    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/events/step1'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
        'Accept-Language': 'ar',
      },
      body: json.encode({
        "categoryId": categoryId,
        "title": eventData['title'] as String,
        "description": eventData['description'] as String,
        "minAge": eventData['minAge'] as int,
        "isPaid": eventData['isPaid'] as bool,
        "isPrivate": eventData['isPrivate'] as bool,
        "attendanceType": attendanceType,
        "image": eventData['image'] as String,
        "startDate": formattedStartDate,
        "endDate": formattedEndDate,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      print('Event submitted successfully: ${data['message']}');
      print('Event ID from response: ${data['event']['eventId']}');

      final eventId = data['event']['eventId'];
      eventProvider.setEventId(eventId);

      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Venue(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ));
    } else if (response.statusCode == 500) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Internal Server Error. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  submitEvent(categoryId, categoryName, description);
                },
                child: Text(
                  'Resend',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ],
          );
        },
      );
    } else {
      print('Failed to submit event');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Your Event Type',
            style: TextStyle(
              fontFamily: 'Satisfy',
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 1500),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    CreateEvent(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
        ),
      ),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: categories.length,
              itemBuilder: (ctx, index) {
                return ListItem(
                  imageUrl: categories[index].icon,
                  text: categories[index].name,
                  description: categories[index].description,
                  onSelect: () => submitEvent(
                    categories[index].id,
                    categories[index].name,
                    categories[index].description,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation,
                      secondaryAnimation) =>
                      CreateEvent(),
                  transitionsBuilder: (context, animation,
                      secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(
                        begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                        position: offsetAnimation, child: child);
                  },
                ));
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 15.0),
              ),
              child: Text(
                'Cancel Create Event',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20.0,
                  fontFamily: 'Satisfy',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final String imageUrl;
  final String text;
  final String description;
  final VoidCallback onSelect;

  ListItem({
    required this.imageUrl,
    required this.text,
    required this.description,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(text),
              content: Text(description),
              actions: <Widget>[
                TextButton(
                  onPressed: onSelect,
                  child: Text(
                    'Select',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: Colors.white70.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String description;
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}
