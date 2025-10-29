import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

import '../controllers/user_controller.dart';
import 'package:http/http.dart' as http;

class EventDetailsPage extends StatefulWidget {
  final int EventId;
  final String imageUrl;
  final String eventName;
  final String eventDescription;
  final String startDate;
  final String endDate;
  final int minAge;
  final int isPaid;
  final int isPrivate;
  final String attendanceType;
  final String totalCost;
  final String ticketPrice;
  final String vipTicketPrice;
  final String qrCode;
  final double rating;
  final bool isFavourite;
  final String heroTag;

  const EventDetailsPage({
    required this.imageUrl,
    required this.eventName,
    required this.eventDescription,
    required this.startDate,
    required this.endDate,
    required this.minAge,
    required this.isPaid,
    required this.isPrivate,
    required this.attendanceType,
    required this.totalCost,
    required this.ticketPrice,
    required this.vipTicketPrice,
    required this.qrCode,
    required this.rating,
    required this.isFavourite,
    required this.heroTag, required this.EventId,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  Future<void> _purchaseTicket(String ticketType) async {
    final token = UserController.getToken();
    final url = Uri.parse('http://192.168.7.39:8000/api/attendees/purchaseTicket');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        'eventId': widget.EventId,
        'ticketType': ticketType,
      }),
    );

    if (response.statusCode == 201) {
      print (' you buy ticket for this event ');

      final responseBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
    } else {
      print (response.body);
      print (response.statusCode);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to purchase ticket')),
      );
    }
  }

  void _showTicketSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Ticket Type"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _purchaseTicket("VIP");
                },
                child: Text("VIP Ticket"),
              ),
              SizedBox(height: 16 , width:  4 ,),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _purchaseTicket("regular");
                },
                child: Text("Regular Ticket"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convert the base64 string to SVG
    final decodedQrCode = base64Decode(widget.qrCode);
    final qrCodeSvg = SvgPicture.memory(decodedQrCode, width: 250, height: 250);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.eventName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: widget.heroTag,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    image: DecorationImage(
                      image: NetworkImage(widget.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.eventName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      widget.rating.round(),  // Converts double to int
                          (index) => Icon(Icons.star, color: Colors.amber),
                    ),
                  ),

                ],
              ),
              SizedBox(height: 10.0),
              Text(
                widget.eventDescription,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Start Date: ${widget.startDate}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5.0),
              Text(
                'End Date: ${widget.endDate}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5.0),
              Text(
                'Minimum Age: ${widget.minAge}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5.0),
              Text(
                'Paid Event: ${widget.isPaid == 1 ? 'Yes' : 'No'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5.0),
              Text(
                'Private Event: ${widget.isPrivate == 1 ? 'Yes' : 'No'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5.0),
              Text(
                'Attendance Type: ${widget.attendanceType}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5.0),
              Text(
                'Total Cost: ${widget.totalCost}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5.0),
              Text(
                'Ticket Price: ${widget.ticketPrice}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5.0),
              Text(
                'VIP Ticket Price: ${widget.vipTicketPrice}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // QR Code Icon Button with Border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 2.0,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.qr_code, color: Colors.deepPurple),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('QR Code'),
                                content: qrCodeSvg,
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      // Favorite Icon Button with Border










                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 2.0,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            widget.isFavourite ? Icons.favorite : Icons.favorite_border,
                            color: widget.isFavourite ? Colors.red : Colors.deepPurple,
                          ),
                          onPressed: () {
                            // Handle favorite toggling functionality
                          },
                        ),
                      ),










                    ],
                  ),
                  // Buy Ticket Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple, // Deep purple color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: _showTicketSelectionDialog,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: Text(
                        'Buy Ticket',
                        style: TextStyle(fontSize: 16 , color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
