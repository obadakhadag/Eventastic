import 'package:flutter/material.dart';
import './Search_Filters_Page.dart';

class SearchTriangle extends StatelessWidget {
  const SearchTriangle({super.key});

  void _navigateToSearchFilters(BuildContext context) {
    Navigator.of(context).push(_createRoute());
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SearchFiltersPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350.0,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: GestureDetector(
        onTap: () => _navigateToSearchFilters(context),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Find the best events for you',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _navigateToSearchFilters(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}