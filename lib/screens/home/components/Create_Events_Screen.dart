import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';

class Event {
  String name;
  String description;
  DateTime date;
  TimeOfDay time;
  List<String> food;
  List<String> drinks;
  List<String> decor;
  int normalSets;
  int vipSets;
  String securityType;
  String lighting;
  String flowers;
  List<Color> themeColors;

  Event({
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.food,
    required this.drinks,
    required this.decor,
    required this.normalSets,
    required this.vipSets,
    required this.securityType,
    required this.lighting,
    required this.flowers,
    required this.themeColors,
  });
}

class CreateEventWidget extends StatefulWidget {
  @override
  _CreateEventWidgetState createState() => _CreateEventWidgetState();
}

class _CreateEventWidgetState extends State<CreateEventWidget> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String description;
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  List<String> food = [];
  List<String> drinks = [];
  List<String> decor = [];
  int normalSets = 0;
  int vipSets = 0;
  String securityType = "Basic";
  String lighting = "Bright";
  String flowers = "Roses";
  List<Color> themeColors = [];

  static List<MultiSelectItem<String>> foodItems = [
    MultiSelectItem("Pizza", "Pizza"),
    MultiSelectItem("Burger", "Burger"),
    MultiSelectItem("Sushi", "Sushi"),
    MultiSelectItem("Pasta", "Pasta"),
    MultiSelectItem("Salad", "Salad"),
    MultiSelectItem("Steak", "Steak"),
    MultiSelectItem("Sandwich", "Sandwich"),
    MultiSelectItem("Tacos", "Tacos"),
  ];

  static List<MultiSelectItem<String>> drinkItems = [
    MultiSelectItem("Coke", "Coke"),
    MultiSelectItem("Pepsi", "Pepsi"),
    MultiSelectItem("Juice", "Juice"),
    MultiSelectItem("Water", "Water"),
    MultiSelectItem("Wine", "Wine"),
    MultiSelectItem("Beer", "Beer"),
    MultiSelectItem("Vodka", "Vodka"),
    MultiSelectItem("Whiskey", "Whiskey"),
  ];

  static List<MultiSelectItem<String>> decorItems = [
    MultiSelectItem("Balloons", "Balloons"),
    MultiSelectItem("Streamers", "Streamers"),
    MultiSelectItem("Flowers", "Flowers"),
    MultiSelectItem("Candles", "Candles"),
    MultiSelectItem("Lights", "Lights"),
    MultiSelectItem("Banners", "Banners"),
  ];

  static List<String> securityTypes = ["Basic", "Intermediate", "Advanced"];
  static List<String> lightingOptions = ["Bright", "Dim", "Colorful", "Ambient", "Spotlight"];
  static List<String> flowerOptions = ["Roses", "Lilies", "Tulips", "Orchids", "Daisies"];

  static List<MultiSelectItem<Color>> colorOptions = [
    MultiSelectItem(Colors.red, "Red"),
    MultiSelectItem(Colors.blue, "Blue"),
    MultiSelectItem(Colors.green, "Green"),
    MultiSelectItem(Colors.yellow, "Yellow"),
    MultiSelectItem(Colors.orange, "Orange"),
    MultiSelectItem(Colors.purple, "Purple"),
    MultiSelectItem(Colors.pink, "Pink"),
    MultiSelectItem(Colors.teal, "Teal"),
  ];

  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,



        title: Text('Create Event'),
      ),
      body: Stepper(
        currentStep: currentStep,
        onStepContinue: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            if (currentStep < 2) {
              setState(() {
                currentStep++;
              });
            } else {
              _submitForm();
            }
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() {
              currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: Text('Basic Info'),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Event Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the event name';
                      }
                      return null;
                    },
                    onSaved: (value) => name = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    onSaved: (value) => description = value!,
                  ),
                  ListTile(
                    title: Text('Date: ${DateFormat('yyyy-MM-dd').format(date)}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: _selectDate,
                  ),
                  ListTile(
                    title: Text('Time: ${time.format(context)}'),
                    trailing: Icon(Icons.access_time),
                    onTap: _selectTime,
                  ),
                ],
              ),
            ),
            isActive: currentStep >= 0,
            state: currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text('Event Details'),
            content: Column(
              children: [
                MultiSelectDialogField(
                  items: foodItems,
                  title: Text("Food"),
                  selectedColor: Colors.purple ,
                  onConfirm: (results) {
                    food = results.cast<String>();
                  },
                ),
                MultiSelectDialogField(
                  items: drinkItems,
                  title: Text("Drinks"),
                  selectedColor: Colors.purple,
                  onConfirm: (results) {
                    drinks = results.cast<String>();
                  },
                ),
                MultiSelectDialogField(
                  items: decorItems,
                  title: Text("Decor"),
                  selectedColor: Colors.purple,
                  onConfirm: (results) {
                    decor = results.cast<String>();
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Number of Normal Sets'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of normal sets';
                    }
                    return null;
                  },
                  onSaved: (value) => normalSets = int.parse(value!),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Number of VIP Sets'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of VIP sets';
                    }
                    return null;
                  },
                  onSaved: (value) => vipSets = int.parse(value!),
                ),
              ],
            ),
            isActive: currentStep >= 1,
            state: currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text('Additional Details'),
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Security Type'),
                  value: securityType,
                  items: securityTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      securityType = value!;
                    });
                  },
                  onSaved: (value) => securityType = value!,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Lighting'),
                  value: lighting,
                  items: lightingOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      lighting = value!;
                    });
                  },
                  onSaved: (value) => lighting = value!,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Flowers'),
                  value: flowers,
                  items: flowerOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      flowers = value!;
                    });
                  },
                  onSaved: (value) => flowers = value!,
                ),
                MultiSelectDialogField(
                  items: colorOptions,
                  title: Text("Theme Colors"),
                  selectedColor: Colors.purple,
                  onConfirm: (results) {
                    themeColors = results.cast<Color>();
                  },
                ),
              ],
            ),
            isActive: currentStep >= 2,
            state: currentStep == 2 ? StepState.editing : StepState.indexed,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != date)
      setState(() {
        date = picked;
      });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: time);
    if (picked != null && picked != time)
      setState(() {
        time = picked;
      });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Event newEvent = Event(
        name: name,
        description: description,
        date: date,
        time: time,
        food: food,
        drinks: drinks,
        decor: decor,
        normalSets: normalSets,
        vipSets: vipSets,
        securityType: securityType,
        lighting: lighting,
        flowers: flowers,
        themeColors: themeColors,
      );
      // Handle the newEvent object (e.g., save to database, etc.)
      print(newEvent );
    }
  }
}