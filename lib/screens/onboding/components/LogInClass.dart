import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:our_mobile_app/controllers/user_controller.dart';
import 'package:our_mobile_app/entry_point.dart';
import 'package:our_mobile_app/screens/onboding/components/LogINform.dart';
import 'package:our_mobile_app/screens/onboding/components/SignUPform.dart';
import 'package:provider/provider.dart';

import '../../../controllers/Language_Provider.dart';
import '../../../models/Localization.dart';
import '../../home/home_screen.dart';

class LogInPage extends StatefulWidget {
  final VoidCallback toggleForm;

  LogInPage({required this.toggleForm});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.1,
            ),
      
      
      
      
      
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                String loginText = languageProvider.isEnglish
                    ? Localization.en['login']!
                    : Localization.ar['login']!;
      
                return Text(
                  loginText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0,
                    fontFamily: 'Poppins',
                  ),
                );
              },
            ),
      
      
      
      
      
      
      
      
            //   HERE i want to edit this later  the text is shit as fuck    fuck that ---------><-----------><---------><>
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 21),
              child: Text(
                "Welcome back to your Events app ",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 32,
            ),
            const LogINform(),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.065,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
      
                //    Here it needs some updates on the directions   based on the language
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child:Consumer<LanguageProvider>(
                        builder: (context, languageProvider, child) {
                          String mostPopularText = languageProvider.isEnglish
                              ? Localization.en['noAccount']!
                              : Localization.ar['noAccount']!;
      
                          return Text(
                            mostPopularText,
                            style: TextStyle(
                                color: Colors.black54, fontSize: 13
                            ),
                          );
                        },
                      ),
                    ),
      
      
                    TextButton(
                        onPressed: widget.toggleForm,
                        child:
      
                        Consumer<LanguageProvider>(
                          builder: (context, languageProvider, child) {
                            String createOneHereText = languageProvider.isEnglish
                                ? Localization.en['createOneHere']!
                                : Localization.ar['createOneHere']!;
      
                            return Text(
                              createOneHereText,
                              style: TextStyle(
                                color: Colors.black,
                                      fontSize: 14,
                                       fontWeight: FontWeight.bold
                              ),
                            );
                          },
                        ),
      
      
      
                    ),
                  ],
                ),
      
      
              ],
            ),
          ],
        ),
      ),
    );
  }

}
