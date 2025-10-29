import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import 'package:our_mobile_app/PROFILE/profile_page.dart';
import 'package:our_mobile_app/PROFILE/profile_user.dart';
import 'package:flutter/services.dart'; // Make sure to import this
import 'package:provider/provider.dart';

import '../controllers/User_Things_Provider.dart';
import '../controllers/user_controller.dart';
import 'mira.dart';


class User {
  final String image;
  final String name;
  final int id;

  User({required this.image, required this.name, required this.id});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      image: json['profile_pic'] ?? 'assets/images/undraw_Profile_pic_re_iwgo.png',
      name: '${json['first_name']} ${json['last_name']}',
      id: json['id'] ?? 0,
    );
  }
}

class ProfileSearch extends StatefulWidget {
  const ProfileSearch({super.key});

  @override
  State<ProfileSearch> createState() => _ProfileSearchState();
}

class _ProfileSearchState extends State<ProfileSearch> {
  List<User> _foundedUsers = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'name';
  final List<String> _filterOptions = ['minRating', 'email', 'name', 'phoneNumber'];

  Future<void> _searchUsers({
    int? minRating,
    String? email,
    String? name,
    String? phoneNumber,
  }) async {
    final String url = 'http://192.168.7.39:8000/api/users/searchUsers';

    Map<String, dynamic> requestBody = {};
    if (minRating != null) requestBody['minRating'] = minRating;
    if (email != null) {
      if (EmailValidator.validate(email)) {
        requestBody['email'] = email;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email address')),
        );
        return;
      }
    }
    if (name != null) {
      requestBody["name"] = name;
    }
    if (phoneNumber != null) requestBody['phoneNumber'] = phoneNumber;

    print('Request Body: $requestBody');

    try {
      final token =  UserController.getToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        List<User> users = (responseBody['users'] as List)
            .map((user) => User.fromJson(user))
            .toList();

        setState(() {
          _foundedUsers = users;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to search users');
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to search users')),
      );
    }
  }

  void onSearch(String value) {
    if (_selectedFilter == 'minRating') {
      // Validate the value is a number between 0 and 5
      int? rating = int.tryParse(value);
      if (rating == null || rating < 0 || rating > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a rating between 0 and 5')),
        );
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    switch (_selectedFilter) {
      case 'minRating':
        _searchUsers(minRating: int.tryParse(value));
        break;
      case 'email':
        _searchUsers(email: value);
        break;
      case 'name':
        _searchUsers(name: value);
        break;
      case 'phoneNumber':
        _searchUsers(phoneNumber: value);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade300,
        title: Container(
          height: 38,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  keyboardType: _selectedFilter == 'minRating' || _selectedFilter == 'phoneNumber'
                      ? TextInputType.number
                      : TextInputType.text,
                  inputFormatters: _selectedFilter == 'minRating' || _selectedFilter == 'phoneNumber'
                      ? <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ]
                      : null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[400],
                    contentPadding: EdgeInsets.all(10),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "Search users",
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: Color.fromRGBO(92, 75, 153, 1),
                    ),
                  ),
                  onChanged: onSearch,
                ),
              ),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: _selectedFilter,
                items: _filterOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GestureDetector(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          color: Colors.grey.shade300,
          child: _foundedUsers.isNotEmpty
              ? ListView.builder(
            itemCount: _foundedUsers.length,
            itemBuilder: (context, index) {
              return userComponent(user: _foundedUsers[index], context: context);
            },
          )
              : Center(
            child: Text(
              'No user found',
              style: TextStyle(
                color: Color.fromRGBO(92, 75, 153, 1),
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }






  Widget userComponent({required User user, required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        int myId = Provider.of<UserThingsProvider>(context, listen: false).id;

        if (user.id == myId) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(), // Show your own profile page
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
                userId: user.id,
                token: UserController.getToken(),
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black, width: 0.10),
          ),
        ),
        padding: EdgeInsets.only(top: 15, bottom: 15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            SizedBox(width: 10),
            Text(
              user.name,
              style: TextStyle(
                color: Color.fromRGBO(92, 75, 153, 1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  }