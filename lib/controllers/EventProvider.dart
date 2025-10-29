import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controllers/user_controller.dart';
import '../models/Most_P_Events.dart';

class EventProvider with ChangeNotifier {
  List<MostPEvents> _events = [];
  List<MostPEvents> _highPriorityEvents = [];
  List<MostPEvents> _midPriorityEvents = [];
  List<MostPEvents> _favoriteEvents = [];
  bool _isLoading = false;
  bool _hasError = false;
  // bool _isFetched = false;

  List<MostPEvents> get events => _events;
  List<MostPEvents> get highPriorityEvents => _highPriorityEvents;
  List<MostPEvents> get midPriorityEvents => _midPriorityEvents;
  List<MostPEvents> get favoriteEvents => _favoriteEvents;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  //
  //
  // List<MostPEvents> get MostPEventswhateverfornow => _events;
  // bool get isFetched => _isFetched;




  Future<void> fetchEvents() async {
    final token = UserController.getToken();
    print('Fetching events...');
    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      final response = await http.get(
        Uri.parse('http://192.168.7.39:8000/api/events/mostPopularEvents'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        print('Fetching Most P Events works with status code : 200');
        print(response.body);

        // Debug print for the decoded data
        var decodedData = jsonDecode(response.body);
        print('Decoded data: $decodedData');

        List<dynamic> data = decodedData['events'];
        print('Events data: $data'); // Debug print

        // Check if data is a List and not empty
        if (data is List && data.isNotEmpty) {
          _events = data.map((event) => MostPEvents.fromJson(event)).toList();
          print('Events fetched: ${_events.length}'); // Debug print
        } else {
          print('No events found in the response');
        }
      } else {
        _hasError = true;
        print('Failed to fetch events with status code: ${response.statusCode}');
      }
    } catch (e) {
      _hasError = true;
      print('Error fetching events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchFavoriteEvents() async {
    final token = UserController.getToken();

    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/users/getFavouriteEvents'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"month": false}),
      );

      if (response.statusCode == 200) {
        print('Fetching Favorite Events works with status code : 200');
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Response data: $data');

        List<dynamic> highPriorityData = data['highPriorityEvents'] ?? [];
        List<dynamic> midPriorityData = data['midPriorityEvents'] ?? [];

        _highPriorityEvents = highPriorityData.map((event) => MostPEvents.fromJson(event)).toList();
        _midPriorityEvents = midPriorityData.map((event) => MostPEvents.fromJson(event)).toList();
      } else {
        print('Failed to fetch favorite events with status code: ${response.statusCode}');
        _hasError = true;
      }
    } catch (e) {
      print('Error fetching favorite events: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy/MM/dd').format(parsedDate);
  }

  Future<void> toggleFavorite(MostPEvents event) async {
    final token = UserController.getToken();
    final eventId = event.id;
    final url = 'http://192.168.7.39:8000/api/users/changeEventFavouriteState';

    // Update local favorite state
    event.isFavorite = !event.isFavorite;
    if (event.isFavorite) {
      if (!_favoriteEvents.any((favEvent) => favEvent.id == event.id)) {
        _favoriteEvents.add(event);
      }
    } else {
      _favoriteEvents.removeWhere((favEvent) => favEvent.id == event.id);
    }
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({'eventId': eventId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Event favorite state updated successfully');
      } else {
        print('Failed to update favorite state on server');
        // Revert the local change if server update fails
        event.isFavorite = !event.isFavorite;
        if (event.isFavorite) {
          if (!_favoriteEvents.any((favEvent) => favEvent.id == event.id)) {
            _favoriteEvents.add(event);
          }
        } else {
          _favoriteEvents.removeWhere((favEvent) => favEvent.id == event.id);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error updating favorite state: $e');
      // Revert the local change if an error occurs
      event.isFavorite = !event.isFavorite;
      if (event.isFavorite) {
        if (!_favoriteEvents.any((favEvent) => favEvent.id == event.id)) {
          _favoriteEvents.add(event);
        }
      } else {
        _favoriteEvents.removeWhere((favEvent) => favEvent.id == event.id);
      }
      notifyListeners();
    }
  }

  bool isFavorite(MostPEvents event) {
    return event.isFavorite;
  }
}
