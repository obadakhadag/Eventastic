import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import '../controllers/user_controller.dart';
import '../models/Most_P_Events.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String result = '';
  List<MostPEvents> events = [];
  String? selectedEventId;
  final String? token = UserController.getToken();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final response = await http.get(
      Uri.parse('http://192.168.7.39:8000/api/attendees/getTodayEvents'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> eventsList = responseData['events'];
      setState(() {
        events = eventsList.map((event) => MostPEvents.fromJson(event)).toList();
      });
    } else {
      // Handle error
      print('Failed to load events');
    }
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
                      await _sendCheckInRequest(id);
                    } else {
                      // Confirm attendance
                      await _sendMakeScannerRequest(eventId, userId);

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

  Future<void> _sendCheckInRequest(int attendeeId) async {
    print('Sending Check-In Request with attendeeId: $attendeeId');
    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/attendees/checkIn'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "attendeeId": attendeeId,
      }),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      print('Check-in successful');
    } else {
      print('Check-in failed with status: ${response.statusCode}');
      _showRawResponseDialog(response.body);
    }
  }

  Future<void> _sendMakeScannerRequest(int eventId, int newScannerId) async {
    print('Sending Make Scanner Request with eventId: $eventId, newScannerId: $newScannerId');
    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/attendees/makeScanner'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "eventId": eventId,
        "newScannerId": newScannerId,
      }),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      _showResponseDialog(response);
    } else {
      print('Failed to create scanner with status: ${response.statusCode}');
      _showErrorDialog('Failed to create scanner. Please try again.');
    }
  }

  void _showRawResponseDialog(String responseBody) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unexpected Response'),
          content: SingleChildScrollView(
            child: Text(responseBody),
          ),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  void _showResponseDialog(http.Response response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Response'),
          content: Text('Status Code: ${response.statusCode}\n${response.body}'),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Select one event from your events today to confirm attendance or create scanner for that event',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Event',
                border: OutlineInputBorder(),
              ),
              items: events.map<DropdownMenuItem<String>>((event) {
                return DropdownMenuItem<String>(
                  value: event.id.toString(),
                  child: Text(event.title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedEventId = value;
                });
              },
              value: selectedEventId,
            ),
            SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onTap: () => _showQRView(context, 'Scan to confirm attendance'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurple,
                  ),
                  child: Center(
                    child: Text(
                      'Scan to confirm attendance',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _showQRView(context, 'Create scanner'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurple,
                  ),
                  child: Center(
                    child: Text(
                      'Create scanner',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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

  void _showQRView(BuildContext context, String action) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(action),
        ),
        body: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
      ),
    ));
  }
}
