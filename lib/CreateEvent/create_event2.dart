import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Event_type.dart';
import 'create_event.dart';
import 'event_provider.dart';

class CreateEvent2 extends StatefulWidget {
  const CreateEvent2({Key? key}) : super(key: key);

  @override
  _CreateEvent2State createState() => _CreateEvent2State();
}

class _CreateEvent2State extends State<CreateEvent2> {
  TextEditingController _imageUrlController = TextEditingController();
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CreateEventProvider>(context, listen: false);
    _imageUrlController.text = provider.imageUrl;
    _imageUrl = provider.imageUrl;

    _imageUrlController.addListener(() {
      setState(() {
        _imageUrl = _imageUrlController.text;
      });
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

  bool _validateInputs() {
    final provider = Provider.of<CreateEventProvider>(context, listen: false);
    if (!provider.isInvitation && !provider.isTicket) {
      _showErrorDialog('Please select Attendance Type');
      return false;
    }
    if (_imageUrlController.text.isEmpty) {
      _showErrorDialog('Please enter Event Image URL');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateEventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'Create Event',
            style: TextStyle(
                fontFamily: 'Satisfy', fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  CreateEvent(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ));
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Attendance Type:',
                    style: const TextStyle(
                        fontSize: 18.5, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: provider.isInvitation,
                        activeColor: Colors.deepPurple,
                        onChanged: (bool? isInvitation) {
                          if (isInvitation != null) {
                            provider.setIsInvitation(isInvitation);
                            if (isInvitation) {provider.setIsTicket(false);
                            }
                          }
                        },
                      ),
                      const Text(
                        'Invitation',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: provider.isTicket,
                        activeColor: Colors.deepPurple,
                        onChanged: (bool? isTicket) {
                          if (isTicket != null) {
                            provider.setIsTicket(isTicket);
                            if (isTicket) {
                              provider.setIsInvitation(false);
                            }
                          }
                        },
                      ),
                      const Text(
                        'Ticket',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _imageUrlController,
              onChanged: (value) {
                provider.setImageUrl(value);
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Event Image URL',
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
          ),
          if (_imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                _imageUrl,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'Could not load image',
                    style: TextStyle(color: Colors.red),
                  );
                },
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
          Container(
            padding: EdgeInsets.only(left: 180, top: 30),
            child: ElevatedButton(
              onPressed: () {
                if (_validateInputs()) {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Event_type(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                  ));
                }
              },
              child: Text(
                'Next',
                style: TextStyle(
                    fontFamily: 'Satisfy',
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }
}