import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // For base64 decoding
import 'package:http/http.dart' as http;

import '../controllers/EventProvider.dart';
import '../controllers/user_controller.dart';
import '../models/Most_P_Events.dart';

class DetailsScreenForMostPopular extends StatefulWidget {
  final MostPEvents event;

  const DetailsScreenForMostPopular({Key? key, required this.event}) : super(key: key);

  @override
  State<DetailsScreenForMostPopular> createState() => _DetailsScreenForMostPopularState();
}

class _DetailsScreenForMostPopularState extends State<DetailsScreenForMostPopular> {
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
        'eventId': widget.event.id,
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
      final responseBody = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(widget.event.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Container(
              width: double.infinity,
              height: 200,
              margin: EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  widget.event.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Event Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: 250,
                    child: FittedBox(
                      child: Text(
                        widget.event.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow[700]),
                      SizedBox(width: 8),
                      Text(
                        widget.event.rating.toString(),
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Event Category ID
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Text(
            //     "Category ID: ${widget.event.categoryId}",
            //     style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            //   ),
            // ),

            // Event Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.event.descriptionEn,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),

            // Event Date Range
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${widget.event.startDate} - ${widget.event.endDate}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),

            // Event Minimum Age
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.accessibility, color: Colors.grey[700]),
                  SizedBox(width: 8),
                  Text(
                    "Min Age: ${widget.event.minAge}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // Event Paid/Free
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                      widget.event.isPaid == 1 ? Icons.attach_money : Icons.money_off,
                      color: Colors.grey[700]
                  ),
                  SizedBox(width: 8),
                  Text(
                    widget.event.isPaid == 1 ? "Paid Event" : "Free Event",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // Event Privacy
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                      widget.event.isPrivate == 1 ? Icons.lock : Icons.lock_open,
                      color: Colors.grey[700]
                  ),
                  SizedBox(width: 8),
                  Text(
                    widget.event.isPrivate == 1 ? "Private Event" : "Public Event",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // Event Attendance Type
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.people, color: Colors.grey[700]),
                  SizedBox(width: 8),
                  Text(
                    "Attendance Type: ${widget.event.attendanceType}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // Event Cost Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Cost: \$${widget.event.totalCost}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Ticket Price: \$${widget.event.ticketPrice}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "VIP Ticket Price: \$${widget.event.vipTicketPrice}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // Event Rating


            // QR Code Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.qr_code, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // Decode the base64 QR code string
                          String decodedQRCode = utf8.decode(base64Decode(widget.event.qrCode));
                          return AlertDialog(
                            content: SvgPicture.string(
                              decodedQRCode,
                              width: 200,
                              height: 200,
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      'Show QR Code',
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Favorite Button and Get Ticket Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Consumer<EventProvider>(
                    builder: (context, eventProvider, child) {
                      final isFavorite = eventProvider.isFavorite(widget.event);
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepPurple, width: 3),
                          borderRadius: BorderRadius.all(Radius.circular(45)),
                        ),
                        height: 64,
                        width: 64,
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
                            color: isFavorite ? Colors.red : Colors.black,
                          ),
                          onPressed: () {
                            eventProvider.toggleFavorite(widget.event);
                          },
                        ),
                      );
                    },
                  ),
                  Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    onPressed: _showTicketSelectionDialog,
                    child: Text(
                      "Get a Ticket",
                      style: TextStyle(fontSize: 16  , color:  Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
