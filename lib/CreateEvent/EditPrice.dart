import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:our_mobile_app/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'event_provider.dart';
import 'create_event.dart';

class EditPrice extends StatefulWidget {
  @override
  _EditPriceState createState() => _EditPriceState();
}

class _EditPriceState extends State<EditPrice> {
  final _formKey = GlobalKey<FormState>();
  String? _regularTicketPrice;
  String? _vipTicketPrice;
  final token = UserController.getToken();

  @override
  Widget build(BuildContext context) {
    final eventId = Provider.of<CreateEventProvider>(context).eventId;

    if (eventId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Edit Price',style: TextStyle(fontFamily: 'Satisfy',fontWeight: FontWeight.bold,fontSize: 30),)),
        ),
        body: Center(
          child: Text('Event ID is missing.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Edit Price',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,fontFamily: 'Satisfy'),)),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchPrices(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found.'));
          }

          final data = snapshot.data;

          if (data != null && data.containsKey('message')) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data['message'] ?? 'Unknown error'),
                  if (data['message'] == 'the event is not paid')
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateEvent(),
                          ),
                        );
                      },
                      child: Text('Create Event'),
                    ),
                ],
              ),
            );
          }

          final items = <MapEntry<String, String>>[];

          if (data != null && data.containsKey('totalCost')) {
            items.add(MapEntry('Total Cost', data['totalCost']));
          }
          if (data != null && data.containsKey('regularTicketPrice')) {
            items.add(MapEntry('Regular Ticket Price', data['regularTicketPrice']));
          }
          if (data != null && data.containsKey('vipTicketPrice')) {
            items.add(MapEntry('VIP Ticket Price', data['vipTicketPrice']));
          }

          return Form(
            key: _formKey,
            child: GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item.key,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: item.value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onSaved: (newValue) {
                            if (item.key == 'Regular Ticket Price') {
                              _regularTicketPrice = newValue;
                            } else if (item.key == 'VIP Ticket Price') {
                              _vipTicketPrice = newValue;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            _formKey.currentState?.save();
            try {

              await _updatePrices(eventId, _regularTicketPrice, _vipTicketPrice);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateEvent(),
                ),
              );
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update prices')),
              );
            }
          }
        },
        icon: Icon(Icons.save),
        backgroundColor: Colors.deepPurple,
        label: Text('Save',style: TextStyle(fontFamily: 'Satisfy',fontWeight: FontWeight.bold,fontSize: 20),),
      ),
    );
  }

  Future<Map<String, dynamic>?> fetchPrices(int eventId) async {
    final uri = Uri.parse('http://192.168.7.39:8000/api/events/getPrices');
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        'Content-Type': 'application/json',
        'Accept-Language': 'ar',
      },
      body: json.encode({
        'eventId': eventId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>?;
    } else {
      final errorData = json.decode(response.body) as Map<String, dynamic>?;
      if (errorData != null && errorData.containsKey('message')) {
        return errorData;
      } else {
        throw Exception('Failed to load prices');
      }
    }
  }

  Future<void> _updatePrices(int eventId, String? regularTicketPrice, String? vipTicketPrice) async {
    final uri = Uri.parse('http://192.168.7.39:8000/api/events/adjustPrices');
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        'Content-Type': 'application/json',
        // 'Accept-Language': 'ar',
      },
      body: json.encode({
        'newRegularTicketPrice': regularTicketPrice,
        'newVipTicketPrice': vipTicketPrice,
        'eventId': eventId,
      }),
    );

    if (response.statusCode == 200) {
      final successMessage = json.decode(response.body)['message'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
    } else if (response.statusCode == 400) {
      final errorMessage = json.decode(response.body)['message'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } else {
      throw Exception('Failed to update prices');
    }
  }
}
