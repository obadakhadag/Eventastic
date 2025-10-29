
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:our_mobile_app/controllers/user_controller.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

import 'Search_Event_Details_Screen.dart';




class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    controller!.pauseCamera();
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Scanned Data: ${result!.code}')
                  : Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });
      await controller.pauseCamera(); // Pause the camera after scanning
      _sendDataToAPI(result!.code!); // Send scanned data to API
    });
  }

  Future<void> _sendDataToAPI(String scannedData) async {
    final data = jsonDecode(scannedData);
    final token = UserController.getToken();

    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/events/searchEventsByQR'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        'eventId': data['id'],
      }),
    );

    if (response.statusCode == 200) {
      final eventDetails = jsonDecode(response.body)['event'][0];
      _showEventDetailsDialog(eventDetails);
    } else {
      // Handle error
      print('Failed to fetch event details: ${response.statusCode}');
    }
  }
  void _showEventDetailsDialog(Map<String, dynamic> eventDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(eventDetails['title']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description (EN): ${eventDetails['description_en']}'),
              Text('Description (AR): ${eventDetails['description_ar']}'),
              Text('Start Date: ${eventDetails['start_date']}'),
              Text('End Date: ${eventDetails['end_date']}'),
              // Add more details as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchEventDetailsScreen(eventId: eventDetails['id']),
                  ),
                );
              },
              child: Text('See More'),
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
