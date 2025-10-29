import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/controllers/user_controller.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'MusicPage.dart';
import 'create_event.dart';
import 'event_provider.dart';

class DecorationCategory extends StatefulWidget {
  const DecorationCategory({Key? key}) : super(key: key);

  @override
  State<DecorationCategory> createState() => _DecorationCategoryState();
}

class _DecorationCategoryState extends State<DecorationCategory> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> categories = [];
  Map<int, List<Map<String, dynamic>>> itemsByCategory = {};
  bool isLoading = true;
  bool isItemsLoading = false;
  final  token  = UserController.getToken() ;
  DateTime? _selectedStartDate;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/resources/categories'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
          // "Authorization": "Bearer $token",
       },
        body: json.encode({'type': 'Decoration'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = List<Map<String, dynamic>>.from(data['Categories']);
          _tabController = TabController(length: categories.length, vsync: this);
          isLoading = false;
        });
        fetchItems(categories[0]['id']);
        _tabController.addListener(() {
          if (_tabController.indexIsChanging) {
            fetchItems(categories[_tabController.index]['id']);
          }
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load categories');
    }
  }

  Future<void> fetchItems(int categoryId) async {
    setState(() {
      isItemsLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/resources/available/quantity'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",

        },
        body: json.encode({
          'eventId': Provider.of<CreateEventProvider>(context, listen: false).eventId,
          'resourceName': 'decorationItem',
          'categoryId': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          itemsByCategory[categoryId] = List<Map<String, dynamic>>.from(data['decoration_item_items']);
          isItemsLoading = false;
        });
      } else {
        print('Failed to load items: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load items');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isItemsLoading = false;
      });
      throw Exception('Failed to load items');
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: eventProvider.startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: eventProvider.endDate ?? DateTime.now().add(Duration(days: 365)),
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

        if (selectedDateTime.isBefore(eventProvider.startDate ?? DateTime.now())) {
          _showErrorDialog('Start date cannot be before the event start date.');
          return;
        }
        if (selectedDateTime.isAfter(eventProvider.endDate ?? DateTime.now().add(Duration(days: 365)))) {
          _showErrorDialog('Start date cannot be after the event end date.');
          return;
        }

        eventProvider.setStartDate(selectedDateTime.toIso8601String());
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

  void _showDetailsDialog(Map<String, dynamic> item) {
    int quantity = 1;
    DateTime? selectedStartDate;
    TextEditingController quantityController = TextEditingController(text: quantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(item['item']['name'], style: TextStyle(fontSize: 20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      item['item']['image'],
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 8),
                    _buildDetail('Quantity', item['availableQuantity'].toString(), true),
                    _buildDetail('Price', item['item']['individual_cost'].toString(), true),
                    _buildDetail('Description', item['item']['description']),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        await _selectStartDate(context);
                        setState(() {
                          selectedStartDate = Provider.of<CreateEventProvider>(context, listen: false).startDate;
                        });
                      },
                      child: Text(
                        'Select Start Date',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'To order, press +',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.deepPurple),
                          onPressed: () {
                            setState(() {
                              if (quantity > 1) {
                                quantity--;
                                quantityController.text = quantity.toString();
                              }
                            });
                          },
                        ),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: quantityController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {
                                quantity = int.tryParse(value) ?? 1;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.deepPurple),
                          onPressed: () {
                            setState(() {
                              quantity++;
                              quantityController.text = quantity.toString();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Close', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    ),
                    TextButton(
                      onPressed: () {
                        if (selectedStartDate == null) {
                          _showErrorDialog('You must select a start date before ordering.');
                          return;
                        }

                        final decorationItem = {
                          "DecorationItem": [
                            {
                              "id": item['item']['id'],
                              "eventId": Provider.of<CreateEventProvider>(context, listen: false).eventId,
                              "startDate": selectedStartDate!.toIso8601String(),
                              "quantity": quantity
                            }
                          ]
                        };

                        print('Stored Decoration Item: ${json.encode(decorationItem)}');
                        Provider.of<CreateEventProvider>(context, listen: false).setDecorationItem(decorationItem);
                        print('Ordered $quantity ${item['item']['name']}');
                        Navigator.pop(context);
                      },
                      child: Text('ORDER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
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

  Widget _buildDetail(String label, String value, [bool isBold = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 18),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 18),
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
    final eventProvider = Provider.of<CreateEventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Decoration Categories',style: TextStyle(fontSize: 30,fontFamily: 'Satisfy',fontWeight: FontWeight.bold),)),
        backgroundColor: Colors.deepPurple,
        bottom: isLoading
            ? null
            : TabBar(
          controller: _tabController,
          tabs: categories.map((cat) => Tab(text: cat['name'])).toList(),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: categories.map((cat) {
              final categoryId = cat['id'];
              final items = itemsByCategory[categoryId] ?? [];
              return isItemsLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: Image.network(item['item']['image']),
                    title: Text(item['item']['name']),
                    subtitle: Text('Available: ${item['availableQuantity']}'),
                    onTap: () => _showDetailsDialog(item),
                  );
                },
              );
            }).toList(),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showSuccessDialog('Are you sure you want to cancel the event?'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(
                      'Cancel Event',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Satisfy',),
                    ),

                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => MusicPage(),
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
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                    ),
                    child: Text('Next', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,fontFamily: 'Satisfy')),
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