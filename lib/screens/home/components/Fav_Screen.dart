import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Widgets/detailsScreenforMostPopular.dart';
import '../../../controllers/EventProvider.dart';
import '../../../controllers/Language_Provider.dart';
import '../../../models/Localization.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch favorite events when the screen is initialized
    Provider.of<EventProvider>(context, listen: false).fetchFavoriteEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            String mostPopularText = languageProvider.isEnglish
                ? Localization.en['favoriteEvents']!
                : Localization.ar['favoriteEvents']!;

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
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (eventProvider.hasError) {
            return Center(
              child: Container(
                width: 300,
                child: Text(
                  'There is no Favorite Events  , try add some  :)   ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          final highPriorityEvents = eventProvider.highPriorityEvents;
          final midPriorityEvents = eventProvider.midPriorityEvents;

          // Combine both lists with highPriorityEvents first
          final allFavoriteEvents = [...highPriorityEvents, ...midPriorityEvents];

          // Show a message if there are no favorite events yet
          if (allFavoriteEvents.isEmpty) {
            return Center(
              child: Text(
                'Add some events to your favorites!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          // Show the list of favorite events
          return ListView.builder(
            itemCount: allFavoriteEvents.length,
            itemBuilder: (context, index) {
              final event = allFavoriteEvents[index];
              return Card(
                elevation: 1,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 100,
                      height: 100,
                      child: Image.network(
                        event.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(event.title),
                  subtitle: Text(event.startDate),
                  trailing: IconButton(
                    icon: Icon(
                      event.isFavorite ?  Icons.favorite_border_outlined : Icons.favorite,
                      color: event.isFavorite ?  Colors.black :Colors.red ,
                    ),
                    onPressed: () {
                      eventProvider.toggleFavorite(event);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreenForMostPopular(event: event),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
