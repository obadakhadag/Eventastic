import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import '../controllers/User_Things_Provider.dart';

class ReservationDetailsPage extends StatefulWidget {
  final int eventId;
  final List<dynamic> reservations;
  final String category;

  ReservationDetailsPage({
    required this.eventId,
    required this.reservations,
    required this.category,
  });

  @override
  _ReservationDetailsPageState createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends State<ReservationDetailsPage> {
  Map<int, Map<String, dynamic>> updatedReservations = {};

  @override
  Widget build(BuildContext context) {
    final int userId = Provider.of<UserThingsProvider>(context).id;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Reservations'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _updateReservations(userId),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.reservations.length,
        itemBuilder: (context, index) {
          final reservation = widget.reservations[index];
          final id = reservation['id'];

          // Initialize controllers and variables based on the category
          TextEditingController quantityController = TextEditingController();
          TextEditingController startDateController = TextEditingController();
          TextEditingController servingDateController = TextEditingController();

          String name = '';
          String image = '';
          double cost = 0.0;

          switch (widget.category) {
            case 'Food':
            case 'Drinks':
              name = widget.category == 'Food'
                  ? reservation['food']['name'] ?? 'No name'
                  : reservation['drink']['name'] ?? 'No name';
              image = widget.category == 'Food'
                  ? reservation['food']['image'] ?? ''
                  : reservation['drink']['image'] ?? '';
              cost = widget.category == 'Food'
                  ? reservation['food']['cost']?.toDouble() ?? 0.0
                  : reservation['drink']['cost']?.toDouble() ?? 0.0;
              quantityController.text = widget.category == 'Food'
                  ? reservation['food']['quantity']?.toString() ?? '0'
                  : reservation['drink']['quantity']?.toString() ?? '0';
              servingDateController.text = widget.category == 'Food'
                  ? reservation['food']['serving_date'] ?? ''
                  : reservation['drink']['serving_date'] ?? '';
              break;

            case 'Security':
            case 'Furniture':
              name = widget.category == 'Security'
                  ? 'Security - ${reservation['security']['clothes_color']}'
                  : reservation['furniture']['name'] ?? 'No name';
              image = widget.category == 'Security'
                  ? reservation['security']['image'] ?? ''
                  : reservation['furniture']['image'] ?? '';
              cost = widget.category == 'Security'
                  ? reservation['security']['cost']?.toDouble() ?? 0.0
                  : reservation['furniture']['cost']?.toDouble() ?? 0.0;
              quantityController.text = widget.category == 'Security'
                  ? reservation['quantity']?.toString() ?? '0'
                  : reservation['furniture']['quantity']?.toString() ?? '0';
              break;

            case 'Decorations':
              name = reservation['decoration_item']['name'] ?? 'No name';
              image = reservation['decoration_item']['image'] ?? '';
              cost = reservation['decoration_item']['cost']?.toDouble() ?? 0.0;
              quantityController.text =
                  reservation['decoration_item']['quantity']?.toString() ?? '0';
              startDateController.text =
                  reservation['decoration_item']['start_date'] ?? '';
              break;

            default:
              break;
          }

          updatedReservations[id] = {
            'newQuantity': quantityController.text,
            'newStartDate': startDateController.text,
            'newServingDate': servingDateController.text,
          };

          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: image.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(Icons.image, size: 30, color: Colors.grey),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        if (widget.category == 'Food' ||
                            widget.category == 'Drinks') ...[
                          TextField(
                            controller: quantityController,
                            decoration: InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                          ),
                          GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  servingDateController.text =
                                      pickedDate.toString().substring(0, 10);
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                controller: servingDateController,
                                decoration:
                                InputDecoration(labelText: 'Serving Date'),
                              ),
                            ),
                          ),
                        ] else if (widget.category == 'Security' ||
                            widget.category == 'Furniture') ...[
                          TextField(
                            controller: quantityController,
                            decoration: InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                          ),
                        ] else if (widget.category == 'Decorations') ...[
                          TextField(
                            controller: quantityController,
                            decoration: InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                          ),
                          GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  startDateController.text =
                                      pickedDate.toString().substring(0, 10);
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                controller: startDateController,
                                decoration:
                                InputDecoration(labelText: 'Start Date'),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('\$${cost.toStringAsFixed(2)}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateReservations(int userId) async {
    final token = UserController.getToken();
    final int eventId = widget.eventId;

    List<Map<String, dynamic>> newItems = updatedReservations.entries
        .map((entry) {
      final id = entry.key;
      final details = entry.value;
      return {
        'id': id,
        'newQuantity': int.parse(details['newQuantity']),
        'newStartDate': details['newStartDate'],
        'newServingDate': details['newServingDate'],
      };
    }).toList();

    final requestBody = {
      'eventId': eventId,
      'itemsType': widget.category.toLowerCase(),
      'userId': userId,
      'newItems': newItems,
    };
    final response = await http.post(
      Uri.parse(
          'http://192.168.7.39:8000/api/events/updateEventQuantitiesReservations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservations updated successfully')));
    } else {
      print(response.statusCode);
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update reservations')));
    }
  }
}
