import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:our_mobile_app/controllers/user_controller.dart';
import 'package:our_mobile_app/entry_point.dart';
import 'package:our_mobile_app/firebase_options.dart';
import 'package:our_mobile_app/screens/onboding/onboding_screen.dart';

import 'CreateEvent/event_provider.dart';
import 'PROFILE/User_event_provider.dart';
import 'controllers/CalendarEventsProvider.dart';
import 'controllers/Category_Provider.dart';
import 'controllers/EventProvider.dart';
import 'controllers/Language_Provider.dart';
import 'controllers/Theme_Provider.dart';
import 'controllers/User_Things_Provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => CalendarEventsProvider()),
        ChangeNotifierProvider(create: (_) => CreateEventProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => UserEventProvider()),
        ChangeNotifierProvider(create: (_) => UserThingsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'The Flutter Way',
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,


      home: UserController.user != null ? EntryPoint() : OnboardingScreen(),
    );
  }
}

// class ThemeProvider extends ChangeNotifier {
//   bool _isDarkTheme = false;
//
//   bool get isDarkTheme => _isDarkTheme;
//
//   void toggleTheme() {
//     _isDarkTheme = !_isDarkTheme;
//     notifyListeners();
//   }
// }

final ThemeData lightThemeData = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFEEF1F8),
  primarySwatch: Colors.deepPurple,
  fontFamily: "Intel",
  appBarTheme: AppBarTheme(
    color: Colors.deepPurple,
    toolbarTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: defaultInputBorder,
    enabledBorder: defaultInputBorder,
    focusedBorder: defaultInputBorder.copyWith(
      borderSide: BorderSide(
        color: Colors.deepPurple,
      ),
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.deepPurple,
    textTheme: ButtonTextTheme.normal, // Use normal to avoid primary theme
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.black, // Set text color to black for light mode
    ),
  ),
);

final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF2C2C2C),
  primarySwatch: Colors.deepPurple,
  fontFamily: "Intel",
  appBarTheme: AppBarTheme(
    color: const Color(0xFF3E3E3E),
    toolbarTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: defaultInputBorder,
    enabledBorder: defaultInputBorder,
    focusedBorder: defaultInputBorder.copyWith(
      borderSide: BorderSide(
        color: Colors.deepPurple,
      ),
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.deepPurple,
    textTheme: ButtonTextTheme.normal, // Use normal to avoid primary theme
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white, // Set text color to white for dark mode
    ),
  ),
);

const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(
    color: Color(0xFFDEE3F2),
    width: 1,
  ),
);
