import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import 'FoodPage.dart';
import 'MusicPage.dart';
import 'create_event.dart';
import 'event_provider.dart';

class SecurityPage extends StatefulWidget {
  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  List<dynamic> securityItems = [];
  Map<int, int> selectedGuards = {};
  final token =UserController.getToken();


  @override
  void initState() {
    super.initState();
    fetchSecurityData();
  }

  Future<void> fetchSecurityData() async {
    final eventId = Provider.of<CreateEventProvider>(context, listen: false).eventId;


    print('Fetching security for eventId: $eventId');

    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/resources/available/quantity'),
      headers: {
        'Content-Type': 'application/json',
         "Authorization": "Bearer $token",
        // 'Accept-Language': 'ar',
      },
      body: jsonEncode({
        'eventId': eventId,
        'resourceName': 'Security',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          securityItems = data['security_items'];
        });
      }
    } else {
      print(response.body);
      print(response.statusCode);
      print('Failed to load security data');
    }
  }

  void _chooseNumberOfGuards(int itemId, int numberOfGuards, int cost) {
    if (mounted) {
      setState(() {
        selectedGuards[itemId] = numberOfGuards;
      });
    }

    print('Chose $numberOfGuards guard(s) for item ID $itemId at a total cost of \$${numberOfGuards * cost}');


    Provider.of<CreateEventProvider>(context, listen: false).setSelectedSecurity(itemId, numberOfGuards);


    print('Selected security data: ${Provider.of<CreateEventProvider>(context, listen: false).selectedSecurity}');

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showGuardSelectionDialog(int itemId, String color, int available, int cost) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedGuardsCount = selectedGuards[itemId] ?? 1;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select number of $color guards'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int i = 1; i <= available; i++)
                      if (i == 1 || i % 5 == 0)
                        RadioListTile(
                          title: Text('$i guard${i > 1 ? 's' : ''}'),
                          subtitle: Text('Cost: \$${i * cost}'),
                          value: i,
                          groupValue: selectedGuardsCount,
                          activeColor: Colors.deepPurple,
                          onChanged: (value) {
                            setState(() {
                              selectedGuardsCount = value!;
                            });
                          },
                        ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _chooseNumberOfGuards(itemId, selectedGuardsCount, cost);
                      },
                      child: Text(
                        'Choose',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
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
        Navigator.of(context).pop();


        final responseMessage = await _cancelEvent();


        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage)),
        );


        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CreateEvent()),
        );
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
        title: Center(child: Text('Security',style: TextStyle(fontFamily: 'Satisfy',fontWeight: FontWeight.bold,fontSize: 30),)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(MusicPage());
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        height: 600,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Security Settings',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              SizedBox(height: 20),
                              if (securityItems.isNotEmpty)
                                ...securityItems.map((item) {
                                  var securityItem = item['item'][0];
                                  return ListTile(
                                    title: Text(
                                      '${securityItem['clothes_color']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Available: ${item['availableQuantity']}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'Cost per guard: \$${securityItem['cost']}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: InkWell(
                                      onTap: () {
                                        _showGuardSelectionDialog(
                                          securityItem['id'],
                                          securityItem['clothes_color'],
                                          item['availableQuantity'],
                                          securityItem['cost'],
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Choose',
                                            style: TextStyle(
                                              color: Colors.deepPurple,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward,
                                              color: Colors.deepPurple),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
           Padding(
            padding: const EdgeInsets.only(top:650),
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
                            FoodsPage(),
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



        ],
      ),
    );
  }
}
