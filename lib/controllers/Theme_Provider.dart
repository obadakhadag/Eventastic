import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/controllers/user_controller.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  void setDarkTheme(bool isDark) {
    _isDarkTheme = isDark;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
    await _sendThemePreference();
  }

  Future<void> _sendThemePreference() async {
    final String? token = UserController.getToken(); // Retrieve the token from UserController
    if (token == null) {
      print('Token is null');
      return;
    }

    final String attributeValue = _isDarkTheme ? 'dark' : 'light';
    final url = Uri.parse('http://192.168.7.39:8000/api/users/adjustPreferences');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'attribute': 'theme',
      'attributeValue': attributeValue,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Theme preference updated successfully');
      } else {
        print('Failed to update theme preference: ${response.body}');
      }
    } catch (error) {
      print('Error updating theme preference: $error');
    }
  }
}
