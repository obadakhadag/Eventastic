import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../controllers/Language_Provider.dart';
import '../controllers/user_controller.dart';
import '../models/Localization.dart';
import 'QRViewExample.dart';

class SearchFiltersPage extends StatefulWidget {
  const SearchFiltersPage({Key? key}) : super(key: key);

  @override
  _SearchFiltersPageState createState() => _SearchFiltersPageState();
}

class _SearchFiltersPageState extends State<SearchFiltersPage> {
  String? category;
  DateTime? startDate;
  DateTime? endDate;
  String location = '';
  int minAge = 0;
  RangeValues priceRange = RangeValues(0, 1000);
  RangeValues vipPriceRange = RangeValues(0, 2000);
  bool isFree = false;
  List<String> selectedFilters = [];
  List<EventCategory> eventCategories = [];
  EventCategory? selectedCategory;
  bool _isLoading = false;
  bool _categoriesFetched = false; // Add this flag
  TextEditingController _searchController =
      TextEditingController(); // Controller for the search TextField

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = null;
          }
        } else {
          if (startDate == null || picked.isAfter(startDate!)) {
            endDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('End date must be after start date')),
            );
          }
        }
      });
    }
  }

  @override
  void initState() {
    if (!_categoriesFetched) {
      _fetchCategories(); // Fetch categories only if not fetched before
    }
    super.initState();
  }

  void _addFilter(String filter) {
    setState(() {
      if (!selectedFilters.contains(filter)) {
        selectedFilters.add(filter);
      }
    });
  }

  void _removeFilter(String filter) {
    setState(() {
      selectedFilters.remove(filter);
    });
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
        _categoriesFetched = true; // Set flag to true after fetching
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

  Future<void> _searchEvents() async {
    final String url = 'http://192.168.7.39:8000/api/events/searchEvents';

    Map<String, dynamic> requestBody = {};
    if (_searchController.text.isNotEmpty)
      requestBody['title'] = _searchController.text;

    if (category != null) requestBody['categoryName'] = category;
    if (startDate != null)
      requestBody['startDate'] = DateFormat('yyyy/MM/dd').format(startDate!);
    if (endDate != null)
      requestBody['endDate'] = DateFormat('yyyy/MM/dd').format(endDate!);
    if (location.isNotEmpty) requestBody['location'] = location;
    if (minAge > 0) requestBody['minAge'] = minAge;
    requestBody['isFree'] = isFree;
    if (priceRange.start != 0 || priceRange.end != 1000)
      requestBody['priceRange'] = '${priceRange.start}-${priceRange.end}';
    if (vipPriceRange.start != 0 || vipPriceRange.end != 2000)
      requestBody['vipPriceRange'] =
          '${vipPriceRange.start}-${vipPriceRange.end}';

    try {
      final token = UserController.getToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final List events = responseBody['events'];

        // Show dialog with events list or no events message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Search Results'),
              content: events.isEmpty
                  ? Text('No events found for the selected criteria.')
                  : Container(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: events.length,
                        itemBuilder: (BuildContext context, int index) {
                          final event = events[index];
                          return ListTile(
                            leading: event['image'] != ""
                                ? ClipOval(
                                    child: Image.network(
                                      event['image'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(Icons.image_not_supported, size: 50),
                            title: Text(event['title'] ?? 'Unnamed Event'),
                            // subtitle: Text(
                            //     event['description_en'] ?? 'No Description'),
                            trailing: Text(DateFormat('yyyy/MM/dd')
                                .format(DateTime.parse(event['start_date']))),
                            onTap: () {
                              // Handle event tap, e.g., navigate to event details page
                            },
                          );
                        },
                      ),
                    ),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        print(response.statusCode);
        print(response.body);
        throw Exception('There is no Events with this specifications ');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('There is no Events with this specifications ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            String mostPopularText = languageProvider.isEnglish
                ? Localization.en['searchPage']!
                : Localization.ar['searchPage']!;

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
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRViewExample()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.deepPurple, width: 2.0),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        // Attach the controller to the TextField

                        decoration: InputDecoration(
                          hintText: 'What are you looking for?',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 20.0),
                        ),
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepPurple, width: 2.0),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add, color: Colors.deepPurple),
                      onPressed: _showFilterSelectionDialog,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              ..._buildSelectedFilters(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _searchEvents,
        label: Text('Search'),
        icon: Icon(Icons.search),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showFilterSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Filters'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                CheckboxListTile(
                  title: Text('Category'),
                  value: selectedFilters.contains('Category'),
                  onChanged: (bool? value) {
                    setState(() {
                      value!
                          ? _addFilter('Category')
                          : _removeFilter('Category');
                    });
                    Navigator.of(context).pop();
                    _showFilterSelectionDialog();
                  },
                ),
                CheckboxListTile(
                  title: Text('Start Date and End Date'),
                  value: selectedFilters.contains('Start Date and End Date'),
                  onChanged: (bool? value) {
                    setState(() {
                      value!
                          ? _addFilter('Start Date and End Date')
                          : _removeFilter('Start Date and End Date');
                    });
                    Navigator.of(context).pop();
                    _showFilterSelectionDialog();
                  },
                ),
                CheckboxListTile(
                  title: Text('Location'),
                  value: selectedFilters.contains('Location'),
                  onChanged: (bool? value) {
                    setState(() {
                      value!
                          ? _addFilter('Location')
                          : _removeFilter('Location');
                    });
                    Navigator.of(context).pop();
                    _showFilterSelectionDialog();
                  },
                ),
                CheckboxListTile(
                  title: Text('Min Age'),
                  value: selectedFilters.contains('Min Age'),
                  onChanged: (bool? value) {
                    setState(() {
                      value! ? _addFilter('Min Age') : _removeFilter('Min Age');
                    });
                    Navigator.of(context).pop();
                    _showFilterSelectionDialog();
                  },
                ),
                CheckboxListTile(
                  title: Text('Price Range'),
                  value: selectedFilters.contains('Price Range'),
                  onChanged: (bool? value) {
                    setState(() {
                      value!
                          ? _addFilter('Price Range')
                          : _removeFilter('Price Range');
                    });
                    Navigator.of(context).pop();
                    _showFilterSelectionDialog();
                  },
                ),
                CheckboxListTile(
                  title: Text('VIP Price Range'),
                  value: selectedFilters.contains('VIP Price Range'),
                  onChanged: (bool? value) {
                    setState(() {
                      value!
                          ? _addFilter('VIP Price Range')
                          : _removeFilter('VIP Price Range');
                    });
                    Navigator.of(context).pop();
                    _showFilterSelectionDialog();
                  },
                ),
                CheckboxListTile(
                  title: Text('Is Free'),
                  value: selectedFilters.contains('Is Free'),
                  onChanged: (bool? value) {
                    setState(() {
                      value! ? _addFilter('Is Free') : _removeFilter('Is Free');
                    });
                    Navigator.of(context).pop();
                    _showFilterSelectionDialog();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildSelectedFilters() {
    List<Widget> filterWidgets = [];
    for (String filter in selectedFilters) {
      switch (filter) {
        case 'Category':
          filterWidgets.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category', style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 10.0),
              DropdownButtonFormField<EventCategory>(
                value: selectedCategory,
                onChanged: (EventCategory? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                    category = newValue?.name;
                  });
                },
                items: eventCategories.map<DropdownMenuItem<EventCategory>>(
                    (EventCategory category) {
                  return DropdownMenuItem<EventCategory>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ));
          break;
        case 'Start Date and End Date':
          filterWidgets.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Start Date and End Date', style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          startDate != null
                              ? DateFormat('yyyy/MM/dd').format(startDate!)
                              : 'Select Start Date',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          endDate != null
                              ? DateFormat('yyyy/MM/dd').format(endDate!)
                              : 'Select End Date',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
            ],
          ));
          break;
        case 'Location':
          filterWidgets.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Location', style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 10.0),
              TextField(
                onChanged: (String value) {
                  setState(() {
                    location = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 15.0),
                ),
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
            ],
          ));
          break;
        case 'Min Age':
          filterWidgets.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Min Age', style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 10.0),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  setState(() {
                    minAge = int.tryParse(value) ?? 0;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 15.0),
                ),
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
            ],
          ));
          break;
        case 'Price Range':
          filterWidgets.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price Range', style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 10.0),
              RangeSlider(
                values: priceRange,
                min: 0,
                max: 1000,
                divisions: 100,
                labels: RangeLabels(
                  priceRange.start.round().toString(),
                  priceRange.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    priceRange = values;
                  });
                },
              ),
              SizedBox(height: 20.0),
            ],
          ));
          break;
        case 'VIP Price Range':
          filterWidgets.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VIP Price Range', style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 10.0),
              RangeSlider(
                values: vipPriceRange,
                min: 0,
                max: 2000,
                divisions: 100,
                labels: RangeLabels(
                  vipPriceRange.start.round().toString(),
                  vipPriceRange.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    vipPriceRange = values;
                  });
                },
              ),
              SizedBox(height: 20.0),
            ],
          ));
          break;
        case 'Is Free':
          filterWidgets.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Is Free', style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 10.0),
              CheckboxListTile(
                title: Text('Only show free events'),
                value: isFree,
                onChanged: (bool? value) {
                  setState(() {
                    isFree = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 20.0),
            ],
          ));
          break;
      }
    }
    return filterWidgets;
  }
}
