import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../controllers/user_controller.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _isSecurPassword = true;
  File? _image;
  final _picker = ImagePicker();
  final token = UserController.getToken();

  Map<String, dynamic>? profileData;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.7.39:8000/api/users/getProfile'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          profileData = jsonDecode(response.body);
          _firstNameController.text = profileData?['firstName'] ?? '';
          _lastNameController.text = profileData?['lastName'] ?? '';
          _phoneNumberController.text = profileData?['phoneNumber'] ?? '';
          _emailController.text = profileData?['email'] ?? '';
          _birthDateController.text = profileData?['birthDate'] ?? '';
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        setState(() {
          _image = File(pickedFile.path);
          profileData?['profilePicture'] = base64Image;
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, String> updatedData = {
        'firstName': _firstNameController.text,
        'phoneNumber': _phoneNumberController.text,
        'email': _emailController.text,
        'birthDate': _birthDateController.text,
      };

      if (profileData?['profilePicture'] != null) {
        updatedData['profilePicture'] = profileData!['profilePicture'];
      }

      if (_oldPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty) {
        if (_newPasswordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New passwords do not match.')),
          );
          return;
        }

        updatedData['oldPassword'] = _oldPasswordController.text;
        updatedData['newPassword'] = _newPasswordController.text;
      }

      try {
        final response = await http.post(
          Uri.parse('http://192.168.7.39:8000/api/users/editProfile'),
          headers: {
            "Authorization": "Bearer $token",
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: updatedData,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
          await _fetchUserProfile();
        } else {
          print (response.body);
          print (response.statusCode);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile. ${response.body}')),
          );
        }
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Color.fromRGBO(92, 75, 153, 1)),
        ),
      ),
      body: profileData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : profileData?['profilePicture'] != null &&
                          profileData!['profilePicture'].isNotEmpty
                          ? MemoryImage(base64Decode(profileData!['profilePicture']))
                      as ImageProvider<Object>?
                          : null,
                      child: _image == null &&
                          (profileData?['profilePicture'] == null ||
                              profileData!['profilePicture'].isEmpty)
                          ? Icon(Icons.person, size: 55)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final source = await showDialog<ImageSource>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Choose image source'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.camera_alt),
                                    title: Text('Camera'),
                                    onTap: () => Navigator.pop(context, ImageSource.camera),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.photo_album),
                                    title: Text('Gallery'),
                                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (source != null) {
                            await _pickImage(source);
                          }
                        },
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    labelText: 'Birth Date',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 32.0),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _isSecurPassword,
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isSecurPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSecurPassword = !_isSecurPassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _isSecurPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isSecurPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSecurPassword = !_isSecurPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (_newPasswordController.text != _confirmPasswordController.text) {
                      return 'New passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isSecurPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isSecurPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSecurPassword = !_isSecurPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
