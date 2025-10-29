import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import 'create_event.dart';
import 'decoration_category.dart';
import 'event_provider.dart';

class FurniturePage extends StatefulWidget {
  const FurniturePage({Key? key}) : super(key: key);

  @override
  State<FurniturePage> createState() => _FurniturePageState();
}

class _FurniturePageState extends State<FurniturePage> with SingleTickerProviderStateMixin {
  List<String> tabs = [];
  Map<String, List<Map<String, dynamic>>> furnitureItems = {};
  late TabController _tabController;
  bool isLoading = true;
  final token =UserController.getToken();

  @override
  void initState() {
    super.initState();
    fetchFurniture();
  }

  Future<void> fetchFurniture() async {
    try {
      final eventId = Provider
          .of<CreateEventProvider>(context, listen: false)
          .eventId;
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/resources/available/quantity'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'eventId': eventId,
          'resourceName': 'furniture',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<String> fetchedTabs = [];
        Map<String, List<Map<String, dynamic>>> fetchedFurnitureItems = {};

        for (var furniture in data['furniture_items']) {
          var item = furniture['item'][0];
          String type = item['type'];

          if (!fetchedTabs.contains(type)) {
            fetchedTabs.add(type);
            fetchedFurnitureItems[type] = [];
          }


          if (item['id'] == null) {
            print('Error: Furniture ID is null for item: ${item}');
            continue;
          }

          Map<String, dynamic> furnitureItem = {
            'id': item['id'],
            'name': item['name'],
            'quantity': furniture['availableQuantity'],
            'cost': '\$${item['cost']}',
            'image': item['image'],
          };

          fetchedFurnitureItems[type]!.add(furnitureItem);
        }

        setState(() {
          tabs = fetchedTabs;
          furnitureItems = fetchedFurnitureItems;
          _tabController = TabController(length: tabs.length, vsync: this);
          isLoading = false;
        });
      } else {
        print('Failed to load furniture. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching furniture: $e');
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

  Future<String> _cancelEvent() async {
    try {
      final eventId = Provider
          .of<CreateEventProvider>(context, listen: false)
          .eventId;

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
        title: Center(child: Text('Choose Furniture',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Satisfy',fontSize: 30),)),
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
              children: tabs.map((tab) =>
                  _buildFurnitureList(furnitureItems[tab]!)).toList(),
            )
                : Center(child: Text('No furniture available')),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:ElevatedButton(
                          onPressed: () => _showSuccessDialog('Are you sure you want to cancel the event?'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: Text(
                            'Cancel Event',
                            style: TextStyle(fontSize: 20,fontFamily: 'Satisfy',fontWeight: FontWeight.bold),
                          ),

                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (context, animation,
                                  secondaryAnimation) => DecorationCategory(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                          child: Text('Next'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                            textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,fontFamily: 'Satisfy'),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFurnitureList(List<Map<String, dynamic>> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          Divider(thickness: 2, color: Colors.grey.shade300),
      itemBuilder: (context, index) {
        return _buildFurnitureItem(items[index]);
      },
    );
  }

  Widget _buildFurnitureItem(Map<String, dynamic> item) {
    String imageUrl = item['image'];
    if (imageUrl == null ||
        (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://'))) {
      imageUrl = 'https://via.placeholder.com/80';
    }


    print('Loading image: $imageUrl');


    if (item['id'] == null) {
      print('Error: Furniture ID is null');
      return ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text('Error: Furniture ID is null'),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.all(16),
      leading: SizedBox(
        width: 80,
        height: 80,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          errorBuilder: (BuildContext context, Object error,
              StackTrace? stackTrace) {
            print('Error loading image: $error');
            return Icon(Icons.broken_image, size: 80, color: Colors.grey);
          },
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: ${item['name']}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Quantity in warehouse: ${item['quantity']}'),
          Text('Cost: ${item['cost']}'),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () {
          _showFurnitureSelectionDialog(item);
        },
        child: Text('Choose'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
      ),
    );
  }

  void _showFurnitureSelectionDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedQuantity = 1;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select quantity for ${item['name']}'),
              content: Container(
                height: 150,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  diameterRatio: 1.2,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedQuantity = index + 1;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      return Center(
                        child: Text(
                          '${index + 1} ${item['name']}${index > 0 ? 's' : ''}',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    },
                    childCount: 4000,
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'You have selected $selectedQuantity ${item['name']}(s).'),
                    ));

                    final eventId = Provider
                        .of<CreateEventProvider>(context, listen: false)
                        .eventId;
                    if (eventId != null) {
                      print(
                          'id: ${item['id']}, eventId: $eventId, Quantity: $selectedQuantity');

                      Provider.of<CreateEventProvider>(context, listen: false)
                          .setSelectedFurniture(
                        item['id'],
                        eventId,
                        selectedQuantity,
                      );
                    } else {
                      print('Error: eventId is null');
                    }
                  },
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
    );
  }
}