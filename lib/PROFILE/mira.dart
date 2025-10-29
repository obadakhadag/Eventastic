import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:our_mobile_app/controllers/user_controller.dart';

class UserProfilePage2 extends StatefulWidget {
  final String userId; // تأكد من أن userId هو من نوع String

  UserProfilePage2({required this.userId}); // تأكد من قبول userId كـ String

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage2> {
  Map<String, dynamic>? userData; // لتخزين بيانات المستخدم
  String? friendshipStatus; // لتخزين حالة الصداقة

  @override
  void initState() {
    super.initState();
    fetchData(widget.userId); // استخدام userId المستلم كـ String
  }

  Future<Map<String, dynamic>> sendIdAndFetchData(String id) async {
    final token = UserController.getToken();
    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/users/getUser'),
      body: jsonEncode({'id': id}),
      headers: {

        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",

    },

    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('فشل في إرسال البيانات');
    }
  }

  Future<void> fetchData(String id) async {
    try {
      final fetchedData = await sendIdAndFetchData(id);
      setState(() {
        userData = fetchedData['user'];
        friendshipStatus = fetchedData['friendship_status'];
      });
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile Page')),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${userData!['id']}'),
            Text('First Name: ${userData!['first_name']}'),
            Text('Last Name: ${userData!['last_name']}'),
            Text('Email: ${userData!['email']}'),
            Text('Rating: ${userData!['rating']}'),
            Text('Followers: ${userData!['followers']}'),
            Text('Following: ${userData!['following']}'),
            Text('Friendship Status: $friendshipStatus'),
          ],
        ),
      ),
    );
  }
}
