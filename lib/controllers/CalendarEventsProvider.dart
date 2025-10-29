import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/controllers/user_controller.dart';
import '../models/CalendarEvents.dart';

class CalendarEventsProvider with ChangeNotifier {
  List<CalendarEvent> _events = [];

  List<CalendarEvent> get events => _events;

  Future<void> fetchEvents() async {
    final token = UserController.getToken();
    final url = 'http://192.168.7.39:8000/api/events/calender';
    final response = await http.get(Uri.parse(url), headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      print('it is working ');
      print (response.body);
      var responseData = json.decode(response.body);

      if (responseData is Map<String, dynamic> && responseData.containsKey('Events')) {
        var eventsData = responseData['Events'];
        if (eventsData is List) {
          _events = eventsData.map((event) => CalendarEvent.fromJson(event)).toList();
        } else {
          _events = [];
          print('Unexpected format for Events data.');
        }
      } else {
        print('No "Events" key found in response data.');
        _events = [];
      }
      notifyListeners();
    } else {
      throw Exception('Failed to load events. Status code: ${response.statusCode}, Response: ${response.body}');
    }
  }
}
