import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import '../../controllers/Language_Provider.dart';
import '../../models/Localization.dart';
import 'components/animated_btn.dart';
import 'components/custom_sign_in_Screen.dart';

// Let's get started
// first we need to check is text field is empty or not

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool isSignInDialogShown = false;
  late RiveAnimationController _btnAnimationColtroller;

  @override
  void initState() {
    _btnAnimationColtroller = OneShotAnimation(
      "active",
      autoplay: false,
    );
    super.initState();
  }


  void showSignInScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            width: MediaQuery.of(context).size.width * 1.7,
            bottom: 200,
            left: 100,
            child: Image.asset("assets/Backgrounds/Spline.png"),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
            ),
          ),
          const RiveAnimation.asset("assets/RiveAssets/shapes.riv"),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: const SizedBox(),
            ),
          ),
          AnimatedPositioned(
            top: isSignInDialogShown ? -50 : 0,
            duration: const Duration(milliseconds: 240),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: 260,
                      child: Column(
                        children:  [

                          Consumer<LanguageProvider>(
                            builder: (context, languageProvider, child) {
                              String joinAndCreateEventsText = languageProvider.isEnglish
                                  ? Localization.en['joinAndCreateEvents']!
                                  : Localization.ar['joinAndCreateEvents']!;

                              return Text(
                                joinAndCreateEventsText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 60.0,
                                  fontFamily: 'Poppins',
                                  height: 1.2,
                                ),
                              );
                            },
                          ),


                          SizedBox(height: 16),

                          Consumer<LanguageProvider>(
                            builder: (context, languageProvider, child) {
                              String bgText = languageProvider.isEnglish
                                  ? Localization.en['withEventasticYouCanMakeYourOwnEvents']!
                                  : Localization.ar['withEventasticYouCanMakeYourOwnEvents']!;

                              return Text(
                                bgText,
                                style: TextStyle(
                                ),
                              );
                            },
                          ),









                          //
                          // Text(
                          //   " Join & Create Events",
                          //   style: TextStyle(
                          //     fontSize: 60,
                          //     fontFamily: "Poppins",
                          //     height: 1.2,
                          //   ),
                          // ),
                          // SizedBox(height: 16),
                          // Text(
                          //   "with eventastic you can make your own events with all the details you want and in a simple way",
                          // ),

                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                    AnimatedBtn(
                      btnAnimationColtroller: _btnAnimationColtroller,
                      press: () {
                        _btnAnimationColtroller.isActive = true;
                        Future.delayed(
                          const Duration(milliseconds: 800),
                          () {
                            setState(() {
                              isSignInDialogShown = true;
                            });

                            showSignInScreen(context);

                          },
                        );
                      },
                    ),
                     Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child:
                      Consumer<LanguageProvider>(
                        builder: (context, languageProvider, child) {
                          String upcomingeventsText = languageProvider.isEnglish
                              ? Localization.en['See all the upcoming events']!
                              : Localization.ar['See all the upcoming events']!;

                          return Text(
                            upcomingeventsText,
                            style: TextStyle(

                            ),
                          );
                        },
                      ),















                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
