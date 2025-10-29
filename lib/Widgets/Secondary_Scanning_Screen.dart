import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../controllers/user_controller.dart';
import '../models/Most_P_Events.dart';

class SecondaryScanningScreen extends StatefulWidget {
  @override
  _SecondaryScanningScreenState createState() => _SecondaryScanningScreenState();
}

class _SecondaryScanningScreenState extends State<SecondaryScanningScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String result = '';
  List<MostPEvents> events = [];
  String? selectedEventId;
  final token = UserController.getToken();

  @override
  void initState() {
    super.initState();
    // _fetchEvents();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      setState(() {
        result = scanData.code ?? '';
      });
      _showDialog(result, controller);
    });
  }

  void _showDialog(String scannedData, QRViewController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scanned Data'),
          content: Text(scannedData),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop();

                if (scannedData.isNotEmpty) {
                  try {
                    print('Scanned Data: $scannedData');
                    final Map<String, dynamic> data = jsonDecode(scannedData);

                    // Extract data from the scanned QR code
                    final int userId = data['userId'];
                    final int eventId = data['eventId'];
                    final int id = data['id'];

                    print('Parsed Data: userId=$userId, eventId=$eventId, id=$id');

                    if (selectedEventId != null) {
                      // Create scanner for the selected event
                      await _sendMakeScannerRequest(eventId, userId);

                    } else {
                      // Confirm attendance
                      // await _sendMakeScannerRequest(eventId, userId);

                      await _sendCheckInRequest(id);


                    }
                  } catch (e) {
                    print('Failed to parse scanned data: $e');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendCheckInRequest(int  attendeeId) async {

    final token = UserController.getToken();
    print('checkIn API  : ');

    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/attendees/checkIn'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({"attendeeId": attendeeId}),
    );

    _showResponseDialog(response);
  }

  Future<void> _sendMakeScannerRequest(int eventId, int newScannerId) async {
    print('sending make ScannerRequest now : ');
    final token = UserController.getToken();
    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/attendees/makeScanner'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({"eventId": eventId, "newScannerId": newScannerId}),
    );

    _showResponseDialog(response);
  }

  void _showResponseDialog(http.Response response) {
    // Parse the JSON response body
    final responseData = jsonDecode(response.body);

    // Extract the message
    final message = responseData['message'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Response'),
          content: Text('Status Code: ${response.statusCode}\nMessage: $message'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
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
        title: Text('QR Code Scanner'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'If someone makes you a scanner for their event, use this page to confirm attendance:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: () => _showQRView(context, 'Scan to confirm attendance'),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.deepPurple,
                ),
                child: Center(
                  child: Text(
                    'Scan to confirm attendance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQRView(BuildContext context, String section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerView(
          onQRViewCreated: _onQRViewCreated,
          section: section,
        ),
      ),
    );
  }
}

class QRScannerView extends StatelessWidget {
  final Function(QRViewController) onQRViewCreated;
  final String section;

  QRScannerView({required this.onQRViewCreated, required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(section),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: GlobalKey(debugLabel: 'QR'),
              onQRViewCreated: onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }
}
