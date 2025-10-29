import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import this to handle TimeoutException

class UserController {
  static User? user = FirebaseAuth.instance.currentUser;
  static String? token;










  static Future<User?> loginWithGoogle() async {
    try {
      final googleAccount = await GoogleSignIn().signIn();
      final googleAuth = await googleAccount?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      user = userCredential.user;

      return user;
    } catch (error) {
      print('Google sign-in error: $error');
      return null;
    }
  }















  static Future<Map<String, dynamic>> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      user = null; // Clear the cached user instance

      const String url = 'http://192.168.7.39:8000/api/users/signOut';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Signing out now ');
        return json.decode(response.body);
      } else {
        return {'error': 'Failed to sign out from server'};
      }
    } catch (error) {
      print('Sign out error: $error');
      return {'error': 'Sign out error'};
    }
  }













  static Future<Map<String, dynamic>> fetchEventsByCategory(String categoryName) async {
    final url = Uri.parse('http://192.168.7.39:8000/api/events/getEventsByCategory');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',

    };
    final body = jsonEncode({'categoryName': categoryName});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('it is working  fetching events by category   ');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {'success': true, 'events': responseData['events'], 'statusCode': response.statusCode, 'body': response.body};
      } else {
        return {'success': false, 'statusCode': response.statusCode, 'body': response.body};
      }
    } catch (error) {
      print('Error occurred: $error');
      return {'success': false, 'statusCode': 500, 'body': 'Error occurred: $error'};
    }
  }












  static Future<List<EventCategory>> fetchEventCategories() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/resources/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'type': 'D'}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if the 'Categories' key exists and is not empty
        if (data.containsKey('Categories')) {
          final List<dynamic> categories = data['Categories'];

          if (categories.isEmpty) {
            print('Categories list is empty.');
            return [];
          }

          return categories.map((category) => EventCategory.fromJson(category)).toList();
        } else {
          print('Categories key not found in the response.');
          return [];
        }
      } else {
        throw Exception('Failed to load categories: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load categories: $e');
    }
  }





  static Future<String> sendLoginRequest(String email) async {
    final response = await http.post(
      Uri.parse('http://192.168.7.39:8000/api/users/googleSignIn'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );
    if (response.statusCode == 200) {
      print('there is  no problem in the sendlogin request ');
      final Map<String, dynamic> responseBody = json.decode(response.body);
      UserController.setToken(responseBody['token']);




      return responseBody['message'];
    } else {
      print(response.body);
      print(response.statusCode);

      throw Exception('Failed to sign in');
    }
  }





  static Future<int> getBalance() async {
    final response = await http.get(
      Uri.parse("http://192.168.7.39:8000/api/wallet/balance"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Fetching balance in your wallet now');
      final data = jsonDecode(response.body);
      return data['balance'] as int;
    } else {
      print(response.body);
      print(response.statusCode);
      throw Exception('Failed to load balance');
    }
  }



  static void setToken(String newToken) {
    token = newToken;
  }


  static String? getToken() {
    return token;
  }
}


class EventCategory {
  final int id;
  final String name;

  EventCategory({required this.id, required this.name});

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}