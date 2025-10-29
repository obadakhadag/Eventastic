import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/controllers/user_controller.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isEnglish = true;

  bool get isEnglish => _isEnglish;

  void setLanguage(String language) {
    _isEnglish = (language == 'en');
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _isEnglish = !_isEnglish;
    notifyListeners();
    await _sendLanguagePreference();
  }

  String get currentLanguage => _isEnglish ? 'English' : 'Arabic';

  Future<void> _sendLanguagePreference() async {
    final token = UserController.getToken();
    final String attributeValue = _isEnglish ? 'en' : 'ar';
    final url = Uri.parse('http://192.168.7.39:8000/api/users/adjustPreferences');
    final headers = {
      "Content-Type": "application/json"    ,
    "Authorization": "Bearer $token",

    };
    final body = json.encode({
      'attribute': 'language',
      'attributeValue': attributeValue,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Language preference updated successfully');
      } else {
        print('Failed to update language preference: ${response.body}');
      }
    } catch (error) {
      print('Error updating language preference: $error');
    }
  }
}
