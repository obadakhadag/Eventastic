import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import 'EditPrice.dart';
import 'FurniturePage.dart';
import 'Venue.dart';
import 'create_event.dart';
import 'event_provider.dart';

class DrinksPage extends StatefulWidget {
  const DrinksPage({Key? key}) : super(key: key);

  @override
  State<DrinksPage> createState() => _DrinksPageState();
}
class _DrinksPageState extends State<DrinksPage> with TickerProviderStateMixin {
  TabController? _tabController;
  List<String> tabs = [];
  Map<String, List<Map<String, dynamic>>> drinkItems = {};
  bool isLoading = true;
  final token = UserController.getToken();


  @override
  void initState() {
    super.initState();
    fetchDrinkData();
  }

  Future<void> fetchDrinkData() async {
    try {
      final eventId = Provider.of<CreateEventProvider>(context, listen: false).eventId;
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/resources/available/catering'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
       },
        body: jsonEncode({
          'category': 'drink',
          'eventId': eventId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        var drinkData = data['Drink available'];
        if (drinkData is Map<String, dynamic>) {
          drinkData = drinkData.entries.map((entry) => entry.value).toList();
        }

        if (drinkData is List) {
          List<String> fetchedTabs = [];
          Map<String, List<Map<String, dynamic>>> fetchedDrinkItems = {};

          for (var drink in drinkData) {
            String type = drink['type'];

            if (!fetchedTabs.contains(type)) {
              fetchedTabs.add(type);
              fetchedDrinkItems[type] = [];
            }

            if (drink['id'] == null) {
              print('Error: Drink ID is null for item: $drink');
              continue;
            }

            Map<String, dynamic> drinkItem = {
              'id': drink['id'],
              'name': drink['name'],
              'cost': '\$${drink['individual_cost']}',
              'age_required': '${drink['age_required']}',
              'description': drink['description'],
              'image': drink['image'],
            };

            fetchedDrinkItems[type]!.add(drinkItem);
          }

          setState(() {
            tabs = fetchedTabs;
            drinkItems = fetchedDrinkItems;


            _tabController?.dispose();


            _tabController = TabController(length: tabs.length, vsync: this);
          });
        } else {
          print('Error: Expected a List for "Drink available", but got ${data['Drink available'].runtimeType}');
        }
      } else {
        print('Failed to load drink data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching drink data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  void _showDetailsDialog(Map<String, dynamic> item) {
    int itemCount = 1;
    DateTime? selectedStartDate;
    TimeOfDay? selectedTime;
    final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);
    final DateTime? startDate = eventProvider.startDate;
    final DateTime? endDate = eventProvider.endDate;

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
                    _buildDetail('age_required', item['age_required']),
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
                            });
                          }
                              : null,
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await showDialog<int>(
                              context: context,
                              builder: (BuildContext context) {
                                int? enteredValue = itemCount;
                                return AlertDialog(
                                  title: Text("Enter item count"),
                                  content: TextField(
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      enteredValue = int.tryParse(value);
                                    },
                                    decoration: InputDecoration(
                                      hintText: '$itemCount',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, enteredValue);
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (result != null) {
                              setState(() {
                                itemCount = result;
                              });
                            }
                          },
                          child: Text(
                            '$itemCount',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.deepPurple),
                          onPressed: () {
                            setState(() {
                              itemCount++;
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
                      eventProvider.setDrinkDetails(
                        item['id'],
                        itemCount,
                        selectedStartDate!,
                      );
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                    child: Text('Order', style: TextStyle(fontSize: 18)),
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

  Future<void> _submitData() async {
    try {
      final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);
      final eventId = eventProvider.eventId;
      final Drink = eventProvider.drinkDetails;
      final VenueId = eventProvider.venueId;
      final Furniture = eventProvider.furnitureData;
      final DecorationItem = eventProvider.decorationItems;
      final Sound = eventProvider.sound;
      final Security = eventProvider.selectedSecurity;
      final Food = eventProvider.foodDetails;

      print('eventId: $eventId');
      print('selectedVenue: $VenueId');
      print('furnitureData: $Furniture');
      print('decorationItems: $DecorationItem');
      print('Sound: $Sound');
      print('Security: $Security');
      print('Food: $Food');
      print('Drink: $Drink');

      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/events/step2'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
      },
        body: jsonEncode({
          'eventId': eventId,
          'VenueId': VenueId,
          'Furniture': Furniture,
          'DecorationItem': DecorationItem,
          'Sound': Sound,
          'Security': Security,
          'Food': Food,
          'Drink': Drink,
        }),
      );

      if (response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          final message = responseData['message'];
          final event = responseData['event'];

          print('Step 2 submitted successfully');
          print('Message: $message');
          print('Event: ${jsonEncode(event)}');

          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => EditPrice(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        } catch (e) {
          print('Error parsing response data: $e');
        }
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'];

        if (message == "The selected furniture exceeds the venue capacity") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('The selected furniture exceeds the venue capacity.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Go to Furniture Page', style: TextStyle(color: Colors.deepPurple)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FurniturePage()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }
        print('Failed to submit data. Status code: 400');
        print('Response body: ${response.body}');
      } else if (response.statusCode == 401) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'];
        final withdrawError = responseData['withdraw error'];

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('$message\n$withdrawError'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK', style: TextStyle(color: Colors.deepPurple)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        print('Failed to submit data. Status code: 401');
        print('Response body: ${response.body}');

      } else if (response.statusCode == 500) {
        print(response.body);
        print(response.statusCode);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Step two can not be completed successfully.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Go to Venue Page', style: TextStyle(color: Colors.deepPurple)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Venue()),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to submit data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error submitting data: $e');
    }
  }


  Future<String> _cancelEvent() async {
    try {
      final eventId = Provider.of<CreateEventProvider>(context, listen: false).eventId;

      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/events/remove'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
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
        title: Text('Drink Menu', style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,fontFamily: 'Satisfy')),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabs.map((tab) {
                final items = drinkItems[tab];
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: items?.length ?? 0,
                  itemBuilder: (context, index) {
                    final item = items![index];
                    return GestureDetector(
                      onTap: () => _showDetailsDialog(item),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.network(
                                item['image'],
                                width: double.infinity,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    item['cost'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => _showSuccessDialog('Are you sure you want to cancel the event?'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Cancel Event',
                  style: TextStyle(fontSize: 20,fontFamily: 'Satisfy',fontWeight: FontWeight.bold),
                ),
              ),

              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Satisfy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}