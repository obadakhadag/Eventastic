import 'package:flutter/material.dart';
import 'package:our_mobile_app/screens/home/home_screen.dart';
import '../Widgets/Invitations_Screen.dart';
import '../Widgets/Scanning_Screen.dart';
import '../Widgets/Search_Filters_Page.dart';
import '../Widgets/Secondary_Scanning_Screen.dart';
import '../Widgets/TicketScreenNow.dart';
import '../Widgets/WalletWidget.dart';
import '../screens/home/components/Fav_Screen.dart';
import '../entry_point.dart';

class Emptyscreenforlist2 extends StatelessWidget {
  final int index;

  const Emptyscreenforlist2({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {



    Widget screenContent;


    switch (index) {
      case 0:
        screenContent = ScannerScreen();
        break;
      case 1:
        screenContent = SecondaryScanningScreen();
        break;
      case 2 :
        screenContent = InvitationScreen();
      default:
        screenContent = TicketScreenNow();
        // TicketScreenNow
        break;
    }

    return Scaffold(

      body: Center(
        child: screenContent,
      ),
    );
  }
}