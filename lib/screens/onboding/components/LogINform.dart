import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:our_mobile_app/entry_point.dart';
import 'package:our_mobile_app/utils/rive_utils.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controllers/Language_Provider.dart';
import '../../../controllers/User_Things_Provider.dart';
import '../../../controllers/user_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../models/Localization.dart'; // For using jsonEncode

class LogINform extends StatefulWidget {
  const LogINform({Key? key}) : super(key: key);

  static String? savedEmail;

  @override
  State<LogINform> createState() => _LogINformState();
}

class _LogINformState extends State<LogINform> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static User? loggedInUser; // Declare _loggedInUser here
  bool _isLoading = false;

  bool isShowLoading = false;
  bool isShowConfetti = false;

  late SMITrigger check;
  late SMITrigger error;
  late SMITrigger reset;
  late SMITrigger confetti;

  DateTime? _selectedDate;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }


  void LogIN(BuildContext context) {
    setState(() {
      isShowLoading = true;
      isShowConfetti = true;
    });

    Future.delayed(
      Duration(seconds: 1),
          () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save(); // Save the form state to save the email

          try {
            final response = await http.post(
              Uri.parse('http://192.168.7.39:8000/api/users/signIn'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                'email': _emailController.text,
                'password': _passwordController.text,
              }),
            );

            print('Response body: ${response.body}');

            if (response.statusCode == 200) {
              final Map<String, dynamic> responseData = jsonDecode(response.body);

              if (responseData['message'] == 'user signed in successfully, WELCOME') {
                // Store the token
                UserController.setToken(responseData['token']);

                // Store user information in the provider
                final userProvider = Provider.of<UserThingsProvider>(context, listen: false);
                userProvider.setUser(
                  id:  responseData['user']['id'],
                  firstName: responseData['user']['first_name'],
                  lastName: responseData['user']['last_name'],
                  profilePic: responseData['user']['profile_pic'],
                  QRcode: responseData['user']['qr_code'],
                );

                // Show the success animation
                check.fire();
                await Future.delayed(Duration(seconds: 2));
                setState(() {
                  isShowLoading = false;
                });

                // Show the confetti animation
                confetti.fire();
                await Future.delayed(Duration(seconds: 1));

                // Navigate to the next screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EntryPoint(),
                  ),
                );
              } else {
                // Show error animation and snackbar if sign-up was not successful
                error.fire();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(responseData['message'])),
                );
                await Future.delayed(Duration(seconds: 2));
                setState(() {
                  isShowLoading = false;
                });
              }
            } else {
              // Show error animation and snackbar if the server did not return a 200 OK response
              error.fire();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to sign in. Please try again.')),
              );
              await Future.delayed(Duration(seconds: 2));
              setState(() {
                isShowLoading = false;
              });
            }
          } catch (e) {
            // Handle any errors that occurred during the request
            print('Error: $e');
            error.fire();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('An error occurred. Please try again.')),
            );
            await Future.delayed(Duration(seconds: 2));
            setState(() {
              isShowLoading = false;
            });
          }
        } else {
          // Show error animation and snackbar if form validation fails
          error.fire();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill in all fields correctly.')),
          );
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            isShowLoading = false;
          });
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: Stack(
          children: [
            KeyboardVisibilityBuilder(
              builder: (context, isKeyboardVisible) {
                return SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: isKeyboardVisible ? 20.0 : 10.0,
                        horizontal: 6.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<LanguageProvider>(
                            builder: (context, languageProvider, child) {
                              String emailText = languageProvider.isEnglish
                                  ? Localization.en['email']!
                                  : Localization.ar['email']!;

                              return Text(
                                emailText,
                                style: TextStyle(color: Colors.black54),
                              );
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: TextFormField(
                              controller: _emailController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your email";
                                }
                                return null;
                              },
                              onSaved: (email) {
                                LogINform.savedEmail = email;
                              },
                              decoration: InputDecoration(
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 9, right: 8, top: 8, bottom: 7),
                                  child: Image.asset(
                                    "assets/images/EmailIconPurple.png",
                                    fit: BoxFit.cover,
                                    height: 22,
                                    width: 40,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(58, 28, 113, 1),
                                  ),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(58, 28, 113, 1),
                                  ),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 30,
                          ),

                          Consumer<LanguageProvider>(
                            builder: (context, languageProvider, child) {
                              String emailText = languageProvider.isEnglish
                                  ? Localization.en['password']!
                                  : Localization.ar['password']!;

                              return Text(
                                emailText,
                                style: TextStyle(color: Colors.black54),
                              );
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: TextFormField(
                              controller: _passwordController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your password";
                                }
                                return null;
                              },
                              onSaved: (password) {},
                              obscureText: true,
                              decoration: InputDecoration(
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 8, bottom: 13),
                                  child: SvgPicture.asset(
                                    "assets/icons/password_purple.svg",
                                    height: 42,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(58, 28, 113, 1),
                                  ),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(58, 28, 113, 1),
                                  ),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                LogIN(context);
                                print(LogINform
                                    .savedEmail); // Print the saved email
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(58, 28, 113, 1),
                                minimumSize: const Size(double.infinity, 48),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(25),
                                    bottomRight: Radius.circular(25),
                                    bottomLeft: Radius.circular(25),
                                  ),
                                ),
                              ),
                              icon: const Icon(
                                CupertinoIcons.arrow_right,
                                color: Color(0xFF8D0B3D),
                              ),
                              label: Consumer<LanguageProvider>(
                                builder: (context, languageProvider, child) {
                                  String emailText = languageProvider.isEnglish
                                      ? Localization.en['login']!
                                      : Localization.ar['login']!;

                                  return Text(
                                    emailText,
                                    style: TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),

                          ElevatedButton.icon(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });

                              User? user =
                                  await UserController.loginWithGoogle();
                              if (user != null) {
                                try {
                                  String responseMessage =
                                      await UserController.sendLoginRequest(
                                          user.email!);
                                  if (responseMessage ==
                                      'user signed in successfully, WELCOME') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EntryPoint(),
                                      ),
                                    );
                                    print('Signed in as ${user.displayName}');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(responseMessage)),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Sign-in failed: ${e.toString()}')),
                                  );
                                  print('Sign-in failed: ${e.toString()}');
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Sign-in failed')),
                                );
                                print('Sign-in failed');
                              }

                              setState(() {
                                _isLoading = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                  bottomLeft: Radius.circular(25),
                                ),
                              ),
                            ),
                            icon: SvgPicture.asset(
                              'assets/icons/google.svg',
                              // Adjust the path to your SVG asset
                              height: 24,
                              width: 24,
                            ),
                            label: Consumer<LanguageProvider>(
                              builder: (context, languageProvider, child) {
                                String emailText = languageProvider.isEnglish
                                    ? Localization.en['loginWithGoogle']!
                                    : Localization.ar['loginWithGoogle']!;

                                return Text(
                                  emailText,
                                  style: TextStyle(fontSize: 16),
                                );
                              },
                            ),
                          ),

                          // Loading indicator
                          if (_isLoading)
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (isShowLoading)
              CustomPositioned(
                child: RiveAnimation.asset(
                  "assets/RiveAssets/check.riv",
                  onInit: (artboard) {
                    StateMachineController controller =
                        RiveUtils.getRiveController(artboard);
                    check = controller.findSMI("Check") as SMITrigger;
                    error = controller.findSMI("Error") as SMITrigger;
                    reset = controller.findSMI("Reset") as SMITrigger;
                  },
                ),
              ),
            if (isShowConfetti)
              CustomPositioned(
                child: Transform.scale(
                  scale: 7,
                  child: RiveAnimation.asset(
                    "assets/RiveAssets/confetti.riv",
                    onInit: (artboard) {
                      StateMachineController controller =
                          RiveUtils.getRiveController(artboard);
                      confetti =
                          controller.findSMI("Trigger explosion") as SMITrigger;
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomPositioned extends StatelessWidget {
  const CustomPositioned({super.key, required this.child, this.size = 100});

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          Spacer(),
          SizedBox(
            height: size,
            width: size,
            child: child,
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
