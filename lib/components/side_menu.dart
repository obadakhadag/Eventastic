import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:our_mobile_app/models/rive_asset.dart';
import 'package:our_mobile_app/utils/rive_utils.dart';
import '../Widgets/Scanning_Screen.dart';
import '../controllers/Language_Provider.dart';
import '../controllers/Theme_Provider.dart';
import 'EmptyScreen.dart';
import 'EmptyScreenForList2.dart';
import 'info_card.dart';
import 'side_menu_tile.dart';
import 'package:our_mobile_app/main.dart'; // Ensure you import the ThemeProvider

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  RiveAsset selectedMenu = sideMenus.first;

  void _toggleTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }

  void _toggleLanguage() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.toggleLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: const Color.fromRGBO(58, 28, 113, 1),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InfoCard(
                name: "obada kh",
                profession: "Student",
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "Browse".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              ...sideMenus.asMap().entries.map(
                    (entry) {
                  int index = entry.key;
                  RiveAsset menu = entry.value;
                  return SideMenuTile(
                    menu: menu,
                    riveonInit: (artboard) {
                      StateMachineController controller =
                      RiveUtils.getRiveController(artboard,
                          stateMachineName: menu.stateMachineName);
                      menu.input = controller.findSMI("active") as SMIBool;
                    },
                    press: () {
                      menu.input!.change(true);
                      Future.delayed(const Duration(seconds: 2), () {
                        menu.input!.change(false);
                      });
                      setState(() {
                        selectedMenu = menu;
                      });
                      Future.delayed(const Duration(milliseconds: 400), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmptyScreen(index: index),
                          ),
                        );
                      });
                    },
                    isActive: selectedMenu == menu,
                  );
                },
              ).toList(),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "History".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              ...sideMenu2.asMap().entries.map(
                    (entry) {
                  int index = entry.key;
                  RiveAsset menu = entry.value;
                  return SideMenuTile(
                    menu: menu,
                    riveonInit: (artboard) {
                      StateMachineController controller =
                      RiveUtils.getRiveController(artboard,
                          stateMachineName: menu.stateMachineName);
                      menu.input = controller.findSMI("active") as SMIBool;
                    },
                    press: () {
                      menu.input!.change(true);
                      Future.delayed(const Duration(seconds: 1), () {
                        menu.input!.change(false);
                      });
                      setState(() {
                        selectedMenu = menu;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Emptyscreenforlist2(index: index),

                          // ScannerScreen(),
                        ),
                      );
                    },
                    isActive: selectedMenu == menu,
                  );
                },
              ).toList(),
              const Spacer(),
              Row(
                children: [
                  // Theme toggle icon
                  IconButton(
                    icon: Icon(
                      Provider.of<ThemeProvider>(context).isDarkTheme
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Colors.white70,
                    ),
                    onPressed: _toggleTheme,
                  ),
                  // Language toggle icon
                  IconButton(
                    icon: Text(
                      Provider.of<LanguageProvider>(context).isEnglish ? 'EN' : 'AR',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.0, // Adjust the font size as needed
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _toggleLanguage,
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
