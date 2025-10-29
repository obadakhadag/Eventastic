import 'package:flutter/material.dart';
import '../Widgets/Search_Filters_Page.dart';
import '../Widgets/WalletWidget.dart';
import '../screens/home/components/Fav_Screen.dart';
import '../entry_point.dart';

class EmptyScreen extends StatelessWidget {
  final int index;

  const EmptyScreen({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (index == 0) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EntryPoint()),
        );
      });
      return Scaffold(); // Return an empty scaffold to avoid any errors while the pushReplacement is executing
    }

    Widget screenContent;


    switch (index) {
      case 1:
        screenContent = SearchFiltersPage();
        break;
      case 2:
        screenContent = FavoriteScreen();
        break;
      default:
        screenContent = WalletScreen();
        break;
    }

    return Scaffold(

      body: Center(
        child: screenContent,
      ),
    );
  }
}