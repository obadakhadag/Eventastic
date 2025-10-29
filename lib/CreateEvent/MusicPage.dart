import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/CreateEvent/security.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import 'create_event.dart';
import 'event_provider.dart';

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<Map<String, dynamic>>> musicCategories = {};
  List<String> tabLabels = [];
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  Map<String, dynamic>? _selectedMusicItem;
  final token =UserController.getToken();

  @override
  void initState() {
    super.initState();
    _fetchMusicData();
  }

  Future<void> _fetchMusicData() async {
    final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);
    final eventId = eventProvider.eventId;

    if (eventId == null) {
      print('No event ID found');
      return;
    }

    print('Fetching music for eventId: $eventId');
    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/resources/available'),
      headers: {
        "Authorization": "Bearer $token",
        'Content-Type': 'application/json',
        'Accept-Language': 'ar',
      },
      body: json.encode({
        'eventId': eventId,
        'resourceName': 'sound',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final availableSounds = data['AvailableSounds'] as List<dynamic>?;

      if (availableSounds == null) {
        print('No available sounds found');
        return;
      }

      final tempCategories = <String, List<Map<String, dynamic>>>{};
      final tempLabels = <String>[];

      for (var item in availableSounds) {
        final type = item['type'] as String?;
        if (type == null) {
          print('Null type found in available sounds');
          continue;
        }

        if (!tempCategories.containsKey(type)) {
          tempCategories[type] = [];
          tempLabels.add(type);
        }

        tempCategories[type]!.add(item as Map<String, dynamic>);
      }

      setState(() {
        musicCategories = tempCategories;
        tabLabels = tempLabels;
        _tabController = TabController(length: tabLabels.length, vsync: this);
      });
    } else {
      print('Failed to load music data');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);
    final startDate = eventProvider.startDate;
    final endDate = eventProvider.endDate;

    final DateTime initialDate = DateTime.now().isBefore(startDate ?? DateTime(2000))
        ? startDate!
        : DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: startDate ?? DateTime(2000),
      lastDate: endDate ?? DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light().copyWith(primary: Colors.deepPurple),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light().copyWith(primary: Colors.deepPurple),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (isStartDate && endDate != null && selectedDateTime.isAfter(endDate!)) {
          _showErrorDialog('Start date cannot be after the end date.');
        } else if (!isStartDate && startDate != null && selectedDateTime.isBefore(startDate!)) {
          _showErrorDialog('End date cannot be before the start date.');
        } else {
          setState(() {
            if (isStartDate) {
              _selectedStartDate = selectedDateTime;
            } else {
              _selectedEndDate = selectedDateTime;
            }
          });
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invalid Date'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

  void _showDetailsDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(item['artist'] ?? 'No artist', style: TextStyle(fontSize: 22)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(item['image'] ?? '', width: 100, height: 100),
                  SizedBox(height: 8),
                  Text('Genre: ${item['genre'] ?? 'N/A'}'),
                  Text('Rating: ${item['rating'] ?? 'N/A'}'),
                  Text('Cost: \$${item['cost'] ?? 'N/A'}'),
                  InkWell(
                    onTap: () {
                      _selectDate(context, true);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.calendar_today, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          'Select Start Date',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      _selectDate(context, false);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.calendar_today, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          'Select End Date',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (_selectedStartDate != null && _selectedEndDate != null) {
                      final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);


                      print('Saving Sound Details:');
                      final soundDetails = {
                        "Sound": [
                          {
                            "id": item['id'] as int,
                            "eventId": eventProvider.eventId!,
                            "startDate": _selectedStartDate!.toIso8601String(),
                            "endDate": _selectedEndDate!.toIso8601String(),
                          }
                        ]
                      };
                      print(json.encode(soundDetails));

                      eventProvider.setSoundDetails(
                        id: item['id'] as int,
                        eventId: eventProvider.eventId!,
                        startDate: _selectedStartDate!,
                        endDate: _selectedEndDate!,
                      );
                      Navigator.pop(context);
                    } else {
                      _showErrorDialog('Please select both start and end dates.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: Text('Reserve', style: TextStyle(fontSize: 18)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                  child: Text('Cancel', style: TextStyle(fontSize: 18)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMusicList(List<Map<String, dynamic>> musicList) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: musicList.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () => _showDetailsDialog(musicList[index]),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Image.network(musicList[index]['image'] ?? '', width: 70, height: 70),
                title: Text(
                  musicList[index]['artist'] ?? 'No artist',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Genre: ${musicList[index]['genre'] ?? 'N/A'}', style: TextStyle(color: Colors.grey)),
                    Text('Rating: ${musicList[index]['rating'] ?? 'N/A'}', style: TextStyle(color: Colors.grey)),
                    Text('Cost: \$${musicList[index]['cost'] ?? 'N/A'}', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  Future<String> _cancelEvent() async {
    try {
      final eventId = Provider.of<CreateEventProvider>(context, listen: false).eventId;

      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/events/remove'),
        headers: {
          'Content-Type': 'application/json',
"Authorization": "Bearer $token",      },
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
        title: Center(child: Text('Sound Selection',style: TextStyle(fontFamily: 'Satisfy',fontWeight: FontWeight.bold,fontSize: 30),)), backgroundColor: Colors.deepPurple,
        bottom: tabLabels.isEmpty
            ? null
            : TabBar(
          controller: _tabController,
          tabs: tabLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: tabLabels.isEmpty
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: tabLabels.map((label) {
          final musicList = musicCategories[label] ?? [];
          return _buildMusicList(musicList);
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(onPressed: () => _showSuccessDialog('Are you sure you want to cancel the event?'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Cancel Event',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Satisfy'),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SecurityPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation,
                        child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end).chain(
                          CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: Text('Next', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Satisfy')),
              ),
            ),
          ],
        ),
      ),
    );
  }}
