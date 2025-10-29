import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:our_mobile_app/screens/onboding/components/SignUPform.dart';
import 'package:provider/provider.dart';

import '../../../controllers/Language_Provider.dart';
import '../../../models/Localization.dart';

class SignUpPage extends StatelessWidget {
  final VoidCallback toggleForm;

  SignUpPage({required this.toggleForm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
      
      
      
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                String mostPopularText = languageProvider.isEnglish
                    ? Localization.en['signup']!
                    : Localization.ar['signup']!;
      
                return Text(
                  mostPopularText,
                  style: TextStyle(
                  fontSize: 40, fontFamily: "Poppins"),
                );
              },
            ),
      
      
      
            // const Text(
            //   "Sign Up",
            //   style: TextStyle(fontSize: 40, fontFamily: "Poppins"),
            // ),
            //
      
      
      
      
      
      
      
      
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "Welcome to Eventastic! Sign Up to create, join, and manage your favorite events and parties. Stay connected and never miss out on the fun!",
                textAlign: TextAlign.center,
              ),
            ),
            // SizedBox(
            //   height: 4,
            // ),
      
      
      
      
      
      
      
            const SignUPform(),
      
      
      
      
      
        // SizedBox(height: 13,),
      
      
      
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        "Already have account ?",
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ),
                    TextButton(
                        onPressed: toggleForm,
                        child: Text(
                          'log in here  ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
