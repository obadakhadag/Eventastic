import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
import 'package:our_mobile_app/entry_point.dart';
import 'package:our_mobile_app/utils/rive_utils.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controllers/user_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For using jsonEncode


class SignUPform extends StatefulWidget {
  const SignUPform({Key? key}) : super(key: key);

  static String? savedEmail;

  @override
  State<SignUPform> createState() => _SignUPformState();
}

class _SignUPformState extends State<SignUPform> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
   static User? loggedInUser; // Declare _loggedInUser here


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

  Future<void> _showEmailPicker(BuildContext context) async {
    try {
      final user = await UserController.loginWithGoogle();
      if (user != null && mounted) {
        setState(() {
          loggedInUser = user; // Save the logged-in user
          _emailController.text = user.email ?? '';
        });
        // Optionally, you can fetch additional user details like profile image URL here
      }
    } on FirebaseAuthException catch (error) {
      print(error.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? "Something went wrong"),
      ));
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
      ));
    }
  }


  void signIn(BuildContext context) {
    setState(() {
      isShowLoading = true;
      isShowConfetti = true;
    });

    Future.delayed(
      Duration(seconds: 1),
          () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save(); // Save the form state to save the email
          print('0');

          // Send sign-up request to backend
          try {
            print('1');
            final response = await http.post(
              Uri.parse('http://192.168.7.39:8000/api/users/signUp'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                'firstName': _firstNameController.text,
                'lastName': _lastNameController.text,
                'email': _emailController.text,
                'password': _passwordController.text,
                'address': _addressController.text,
                'phoneNumber': _phoneNumberController.text,
                'birthDate': '2003/3/3', // Assuming this is a constant
                'profilePic': UserController.user!.photoURL!.toString(),
                'googleId': '199', // Assuming this is a constant
              }),
            );
            print('2');

            print('Response body: ${response.body}');

            if (response.statusCode == 201) {
              // If the server returns a 201 Created response, parse the JSON
              final Map<String, dynamic> responseData = jsonDecode(response.body);

              // Check if the sign-up was successful based on your API response
              if (responseData['message'] == 'user signed up successfully') {
                // Store the token
                UserController.setToken(responseData['token']);

                // If everything looks good, show the success animation
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
              // Show error animation and snackbar if the server did not return a 201 Created response
              error.fire();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to sign up. Please try again.')),
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
                    padding: EdgeInsets.symmetric(vertical: isKeyboardVisible ? 20.0 : 10.0, horizontal: 6.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "First Name",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: TextFormField(
                                        controller: _firstNameController,

                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Please enter your first name";
                                          }
                                          return null;
                                        },
                                        onSaved: (firstName) {
                                          // Save first name
                                        },
                                        decoration: InputDecoration(
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
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Last Name",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: TextFormField(
                                        controller: _lastNameController,

                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Please enter your last name";
                                          }
                                          return null;
                                        },
                                        onSaved: (lastName) {
                                          // Save last name
                                        },
                                        decoration: InputDecoration(
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "Email",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: GestureDetector(
                              onTap: () => _showEmailPicker(context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _emailController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter your email";
                                    }
                                    return null;
                                  },
                                  onSaved: (email) {
                                    SignUPform.savedEmail = email;
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
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
                            ),
                          ),
                          const Text(
                            "Password",
                            style: TextStyle(color: Colors.black54),
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
                                prefixIcon: Padding(
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
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Address",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: TextFormField(
                                        controller: _addressController,

                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Please enter your address";
                                          }
                                          return null;
                                        },
                                        onSaved: (address) {
                                          // Save address
                                        },
                                        decoration: InputDecoration(
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
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Birthdate",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: GestureDetector(
                                        onTap: () => _selectDate(context),
                                        child: AbsorbPointer(
                                          child: TextFormField(
                                            controller: _birthDateController,

                                            validator: (value) {
                                              if (_selectedDate == null) {
                                                return "Please select your birthdate";
                                              }
                                              return null;
                                            },
                                            onSaved: (birthdate) {
                                              // Save birthdate
                                            },
                                            decoration: InputDecoration(
                                              hintText: _selectedDate == null
                                                  ? 'Select your birthdate'
                                                  : '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}',
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "Phone Number",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: TextFormField(
                              controller: _phoneNumberController,

                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your phone number";
                                }
                                return null;
                              },
                              onSaved: (phoneNumber) {
                                // Save phone number
                              },
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
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
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                signIn(context);
                                print(SignUPform.savedEmail); // Print the saved email
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(58, 28, 113, 1),
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
                              label: const Text("Sign Up" ,style: TextStyle(color: Colors.white)),
                            ),
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
                      confetti = controller.findSMI("Trigger explosion") as SMITrigger;
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
