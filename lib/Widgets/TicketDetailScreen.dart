


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'QRCodeScreen.dart';

class TicketDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  TicketDetailScreen(this.ticket);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.grey),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event ID: ${ticket['event_id']}'),
                    Text('Seat Number: ${ticket['seat_number']}'),
                    Text('Ticket Type: ${ticket['ticket_type']}'),
                    Text('Purchase Date: ${ticket['purchase_date']}'),
                    Text('Checked In: ${ticket['checked_in'] == 1 ? "Yes" : "No"}'),
                    Text('Ticket Price: ${ticket['ticket_price']}'),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRCodeScreen(ticket['qr_code']),
                          ),
                        );
                      },
                      child: Text('Show QR Code'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
