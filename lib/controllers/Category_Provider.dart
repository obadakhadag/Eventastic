import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:our_mobile_app/controllers/user_controller.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> FetchingCategoryNamesAnd_Id() async {
    final token = UserController.getToken();
    final url = 'http://192.168.7.39:8000/api/resources/categories';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'type': 'D'}),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      if (responseData.containsKey('Categories')) {
        _categories = (responseData['Categories'] as List)
            .map((category) => Category.fromJson(category))
            .toList();
      }
      notifyListeners();
    } else {
      throw Exception('Failed to load categories. Status code: ${response.statusCode}, Response: ${response.body}');
    }
  }
}
