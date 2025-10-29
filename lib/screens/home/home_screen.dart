import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:our_mobile_app/controllers/user_controller.dart';
import 'package:our_mobile_app/screens/onboding/onboding_screen.dart';
import '../../CreateEvent/create_event.dart';
import '../../Widgets/Filtered_Events.dart';
import '../../Widgets/Most_popular.dart';
import '../../Widgets/Search_Triangle.dart';
import '../../components/animated_bar.dart';
import '../../constants.dart';
import '../../controllers/Language_Provider.dart';
import '../../controllers/Theme_Provider.dart';
import '../../models/Localization.dart';
import '../../models/rive_asset.dart';
import '../../utils/rive_utils.dart';
import 'components/Fav_Screen.dart';
import 'components/calendarScreen.dart';
import 'package:our_mobile_app/models/Events.dart' as events_model;
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isFavorite = false;
  RiveAsset selectedBottomNav = bottomNavs.first;
  late AnimationController _animationController;
  late Animation<double> animation;
  List<EventCategory> eventCategories = [];
  EventCategory? selectedCategory;
  List<dynamic> events = [];
  bool _isLoading = false;
  bool _categoriesFetched = false;
  String _fetchError = '';
  late Future<void> _fetchPreferencesFuture;



  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
      setState(() {});
    });

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );

    _fetchPreferences();
    _fetchCategories();
  }

  Future<void> _fetchPreferences() async {
    try {
      // Assuming you have a method to get the token
      String? token = UserController.getToken();

      // Check if the token is null
      if (token == null) {
        throw Exception('Token is null');
      }

      // Fetch preferences
      final preferences = await fetchPreferences(token);

      // Update providers
      Provider.of<ThemeProvider>(context, listen: false)
          .setDarkTheme(preferences['theme'] == 'dark');
      Provider.of<LanguageProvider>(context, listen: false)
          .setLanguage(preferences['language']);
    } catch (error) {
      // Handle errors appropriately
      print('Failed to fetch preferences: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<EventCategory> categories =
          await UserController.fetchEventCategories();
      setState(() {
        eventCategories = categories;
        _categoriesFetched = true;
        if (eventCategories.isNotEmpty) {
          selectedCategory = EventCategory(id: 1, name: 'ALL');
          FetchEventsByCategory('ALL');
        }
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<Map<String, dynamic>> fetchPreferences(String token) async {
    final response = await http.get(
      Uri.parse('http://192.168.7.39:8000/api/users/getPreferences'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['Preferences'];
    } else {
      throw Exception('Failed to load preferences');
    }
  }


  Future<void> FetchEventsByCategory(String categoryName) async {
    setState(() {
      _isLoading = true;
      _fetchError = '';
    });

    final result = await UserController.fetchEventsByCategory(categoryName);

    if (result['success']) {
      setState(() {
        events = result['events'];
      });
    } else {
      setState(() {
        _fetchError =
            'Failed to load events. Status code: ${result['statusCode']}. Response: ${result['body']}';
        events = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_fetchError),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildCategoryRow() {
    return DefaultTabController(
      length: eventCategories.length,
      child: Container(
        alignment: Alignment.centerLeft, // Ensure alignment to the left

        height: 50.0,
        child: TabBar(
          isScrollable: true,
          labelColor: Color.fromRGBO(134, 23, 193, 1),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.transparent,
          tabs: eventCategories
              .map((category) => Tab(text: category.name))
              .toList(),
          onTap: (index) {
            setState(() {
              selectedCategory = eventCategories[index];
              FetchEventsByCategory(selectedCategory!.name);
            });
          },
        ),
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      key: _scaffoldKey,
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0, 100 * animation.value),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: backgroundColor2.withOpacity(0.8),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...List.generate(
                  bottomNavs.length,
                  (index) => GestureDetector(
                    onTap: () {
                      bottomNavs[index].input!.change(true);
                      if (bottomNavs[index] != selectedBottomNav) {
                        setState(() {
                          selectedBottomNav = bottomNavs[index];
                          _selectedIndex = index;
                        });
                      }
                      Future.delayed(const Duration(seconds: 1), () {
                        bottomNavs[index].input!.change(false);
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 36,
                          width: 36,
                          child: Opacity(
                            opacity: bottomNavs[index] == selectedBottomNav
                                ? 1
                                : 0.5,
                            child: RiveAnimation.asset(
                              bottomNavs.first.src,
                              artboard: bottomNavs[index].artboard,
                              onInit: (artboard) {
                                StateMachineController controller =
                                    RiveUtils.getRiveController(artboard,
                                        stateMachineName:
                                            bottomNavs[index].stateMachineName);

                                bottomNavs[index].input =
                                    controller.findSMI("active") as SMIBool;
                              },
                            ),
                          ),
                        ),
                        AnimatedBar(
                            isActive: bottomNavs[index] == selectedBottomNav),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
              'Eventastic',
              style: TextStyle(
                fontFamily: 'Satisfy',
                fontSize: 30,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout , color: Colors.white,),
                onPressed: _handleSignOut,
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCategoryRow(),
                    SizedBox(height: 5),
                    SearchTriangle(),
                    Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer<LanguageProvider>(
                            builder: (context, languageProvider, child) {
                              String mostPopularText =
                                  languageProvider.isEnglish
                                      ? Localization.en['mostPopular']!
                                      : Localization.ar['mostPopular']!;

                              return Text(
                                mostPopularText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                  fontFamily: 'PlayfairDisplay',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    MostPopular(),
                    SizedBox(width: double.infinity, height: 5),
                    Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer<LanguageProvider>(
                            builder: (context, languageProvider, child) {
                              String mostPopularText =
                                  languageProvider.isEnglish
                                      ? Localization.en['upcomingEvents']!
                                      : Localization.ar['upcomingEvents']!;

                              return Text(
                                mostPopularText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                  fontFamily: 'PlayfairDisplay',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    FilteredEvents(
                      events: events,
                    ),
                    SizedBox(height: 20),

                    // if (_fetchError.isNotEmpty)
                    //   Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Text(
                    //       _fetchError,
                    //       style: TextStyle(color: Colors.red),
                    //     ),
                    //   ),
                  ],
                ),
              ),
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        );
      case 1:
        return FavoriteScreen();
      case 2:
        return MyCalendarPage();
      case 3:
        return CreateEvent();
      default:
        return Center(
          child: Text('There is no screen here'),
        );
    }
  }

  void _handleSignOut() async {
    setState(() {
      _isLoading = true;
    });

    final result = await UserController.signOut();

    setState(() {
      _isLoading = false;
    });

    if (result.containsKey('message') &&
        result['message'] == 'user signed out successfully, SEE YOU LATER') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Unknown error occurred')),
      );
    }
  }
}
