import 'package:flutter/material.dart';
import 'create_event2.dart';
import 'package:provider/provider.dart';
import 'event_provider.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({Key? key}) : super(key: key);

  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> with SingleTickerProviderStateMixin {
  DateTime? startDate;
  DateTime? endDate;
  int? minAge;
  bool? isPaid;
  bool? isPrivate;

  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now().add(Duration(days: 7));

    if (isStartDate) {
      initialDate = firstDate;
    } else {
      if (startDate != null) {
        initialDate = startDate!.add(Duration(days: 1));
        firstDate = startDate!;
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light().copyWith(primary: Colors.deepPurple),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light().copyWith(primary: Colors.deepPurple),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (isStartDate) {
          if (endDate != null && selectedDateTime.isAfter(endDate!)) {
            _showErrorDialog('Start date cannot be after end date.');
            return;
          }
          eventProvider.setStartDate(selectedDateTime.toIso8601String());
          setState(() {
            startDate = selectedDateTime;
          });
        } else {
          if (startDate != null && selectedDateTime.isBefore(startDate!)) {
            _showErrorDialog('End date cannot be before start date.');
            return;
          }
          if (startDate != null &&
              selectedDateTime.difference(startDate!).inDays > 1) {
            _showErrorDialog('End date cannot be more than one day after start date.');
            return;
          }
          eventProvider.setEndDate(selectedDateTime.toIso8601String());
          setState(() {
            endDate = selectedDateTime;
          });
        }
      }
    }
  }

  Future<void> _selectMinAge(BuildContext context) async {
    final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);
    final int? selectedAge = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light().copyWith(primary: Colors.deepPurple),
          ),
          child: AlertDialog(
            title: Text('Select Minimum Age'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButton<int>(
                  hint: Text('Select Minimum Age'),
                  value: minAge,
                  onChanged: (int? value) {
                    setState(() {
                      minAge = value;
                    });
                    eventProvider.setMinAge(value!);
                  },
                  items: List.generate(
                    100,
                        (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(minAge);
                },
                child: Text('OK', style: TextStyle(color: Colors.deepPurple)),
              ),
            ],
          ),
        );
      },
    );

    if (selectedAge != null) {
      print('Selected minimum age: $selectedAge');
    }
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
    final eventProvider = Provider.of<CreateEventProvider>(context, listen: false);
    if (eventNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        startDate == null ||
        endDate == null ||
        minAge == null) {
      _showErrorDialog('You must enter all information');
      return false;
    }
    eventProvider.setTitle(eventNameController.text);
    eventProvider.setDescription(descriptionController.text);
    eventProvider.setStartDate(startDate!.toIso8601String());
    eventProvider.setEndDate(endDate!.toIso8601String());
    eventProvider.setMinAge(minAge!);
    eventProvider.setIsPaid(isPaid ?? false);
    eventProvider.setIsPrivate(isPrivate ?? false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Create Event',style: TextStyle(fontFamily: 'Satisfy',fontWeight: FontWeight.bold,fontSize: 30,),)),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: TextField(
                  controller: eventNameController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    border: InputBorder.none,
                    labelStyle: TextStyle(color: Colors.deepPurple),
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    Provider.of<CreateEventProvider>(context, listen: false).setTitle(value);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: InputBorder.none,
                    labelStyle: TextStyle(color: Colors.deepPurple),
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    Provider.of<CreateEventProvider>(context, listen: false).setDescription(value);
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 25),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      _selectDate(context, true); // Select Start Date
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.arrow_forward, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          'Select Start Date',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (startDate != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Start Date: ${startDate.toString()}'),
                    ),
                  InkWell(
                    onTap: () {
                      _selectDate(context, false); // Select End Date
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.arrow_forward, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          'Select End Date',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (endDate != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('End Date: ${endDate.toString()}'),
                    ),
                  InkWell(
                    onTap: () {
                      _selectMinAge(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.arrow_forward, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          'Select Minimum Age',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (minAge != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Minimum Age: $minAge'),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Is Paid:',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Checkbox(
                              value: isPaid ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  isPaid = value;
                                });
                              },
                              activeColor: Colors.deepPurple,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Is Private:',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Checkbox(
                              value: isPrivate ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  isPrivate = value;
                                });
                              },
                              activeColor: Colors.deepPurple,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
              ),
              onPressed: () {
                if (_validateInputs()) {
                  _controller.forward().then((_) {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => CreateEvent2(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(position: offsetAnimation, child: child);

                      },
                    ),
                    );

                  });
                }
              },
              child: Text(
                'Next',
                style: TextStyle(fontSize :20,color: Colors.white,fontFamily: 'Satisfy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
