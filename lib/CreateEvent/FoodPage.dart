import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import 'DrinksPage.dart';
import 'create_event.dart';
import 'event_provider.dart';

class FoodsPage extends StatefulWidget {
  const FoodsPage({Key? key}) : super(key: key);

  @override
  State<FoodsPage> createState() => _FoodsPageState();
}

class _FoodsPageState extends State<FoodsPage> with SingleTickerProviderStateMixin {
  List<String> tabs = [];
  Map<String, List<Map<String, dynamic>>> foodItems = {};
  late TabController _tabController;
  bool isLoading = true;
  final token =UserController.getToken();

  @override
  void initState() {
    super.initState();
    fetchFoodData();
  }

  Future<void> fetchFoodData() async {
    try {
      final eventId = Provider.of<CreateEventProvider>(context, listen: false).eventId;
      print('Fetching food for eventId: $eventId');
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/resources/available/catering'),
        headers: {
          'Content-Type': 'application/json',
"Authorization": "Bearer $token",      },
        body: jsonEncode({
          'category': 'food',
          'eventId': eventId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<String> fetchedTabs = [];
        Map<String, List<Map<String, dynamic>>> fetchedFoodItems = {};

        for (var food in data['Food available']) {
          String type = food['type'];

          if (!fetchedTabs.contains(type)) {
            fetchedTabs.add(type);
            fetchedFoodItems[type] = [];
          }

          if (food['id'] == null) {
            print('Error: Food ID is null for item: ${food}');
            continue;
          }

          Map<String, dynamic> foodItem = {
            'id': food['id'],
            'name': food['name'],
            'cost': '\$${food['individual_cost']}',
            'description': food['description'],
            'image': food['image'],
          };

          fetchedFoodItems[type]!.add(foodItem);
        }

        setState(() {
          tabs = fetchedTabs;
          foodItems = fetchedFoodItems;
          _tabController = TabController(length: tabs.length, vsync: this);
          isLoading = false;
        });
      } else {
        print('Failed to load food data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching food data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDetailsDialog(Map<String, dynamic> item) {
    int itemCount = 1;
    DateTime? selectedStartDate;
    TimeOfDay? selectedTime;
    final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);
    final DateTime? startDate = eventProvider.startDate;
    final DateTime? endDate = eventProvider.endDate;
    final TextEditingController itemCountController = TextEditingController(text: itemCount.toString());
    final FocusNode itemCountFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(item['name'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(item['image'], width: 200, height: 200, fit: BoxFit.cover),
                    SizedBox(height: 8),
                    _buildDetail('Cost', item['cost']),
                    _buildDetail('Description', item['description']),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        if (startDate != null && endDate != null) {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedStartDate ?? startDate,
                            firstDate: startDate,
                            lastDate: endDate,
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light().copyWith(primary: Colors.deepPurple),
                                  buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null && pickedDate != selectedStartDate) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.light().copyWith(primary: Colors.deepPurple),
                                    buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedTime != null) {
                              setState(() {
                                selectedStartDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                selectedTime = pickedTime;
                              });
                            }
                          }
                        }
                      },
                      child: Text(
                        selectedStartDate == null
                            ? 'Select Serving date '
                            : 'Serving Date: ${selectedStartDate!.toLocal()}'.split(' ')[0] +
                            ' at ${selectedTime!.format(context)}',
                        style: TextStyle(color: Colors.deepPurple, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Text(
                        'To order, press Order',
                        style: TextStyle(color: Colors.deepPurple, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.deepPurple),
                          onPressed: itemCount > 1
                              ? () {
                            setState(() {
                              itemCount--;
                              itemCountController.text = itemCount.toString();
                            });
                          }
                              : null,
                        ),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            controller: itemCountController,
                            focusNode: itemCountFocusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                            onChanged: (value) {
                              setState(() {
                                itemCount = int.tryParse(value) ?? 1;
                              });
                            },
                            onTap: () {

                              itemCountFocusNode.requestFocus();
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.deepPurple),
                          onPressed: () {
                            setState(() {
                              itemCount++;
                              itemCountController.text = itemCount.toString();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                    child: Text('Close', style: TextStyle(fontSize: 18)),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: selectedStartDate == null
                        ? null
                        : () {
                      eventProvider.setFoodDetails(
                        item['id'],
                        itemCount,
                        selectedStartDate!,
                      );


                      print(eventProvider.foodDetails);

                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                    child: Text('ORDER', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetail(String name, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$name: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
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
        title: Center(child: Text('Food',style: TextStyle(fontFamily: 'Satisfy',fontWeight: FontWeight.bold,fontSize: 30),)),
        backgroundColor: Colors.deepPurple,
        bottom: tabs.isNotEmpty
            ? TabBar(
          controller: _tabController,
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        )
            : null,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: tabs.isNotEmpty
                ? TabBarView(
              controller: _tabController,
              children: tabs.map((tab) => _buildFoodList(foodItems[tab]!)).toList(),
            )
                : Center(child: Text('No food items available')),
          ),
          Padding(
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
                            DrinksPage(),
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
                    child: Text('Next', style: TextStyle(fontSize: 20,fontFamily: 'Satisfy',fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            leading: Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover),
            title: Text(item['name']),
            subtitle: Text(item['description']),
            trailing: Text(item['cost'], style: TextStyle(color: Colors.grey)),
            onTap: () => _showDetailsDialog(item),
          ),
        );
      },
    );
  }
}
