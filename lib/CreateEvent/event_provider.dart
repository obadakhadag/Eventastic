import 'package:flutter/material.dart';

class CreateEventProvider with ChangeNotifier {
  String _title = '';
  String _description = '';
  DateTime? _startDate;
  DateTime? _endDate;
  int _minAge = 0;
  bool _isPaid = false;
  bool _isPrivate = false;
  bool _isInvitation = false;
  bool _isTicket = false;
  String _imageUrl = '';
  int? _eventId;
  int? _venueId;
  List<Map<String, dynamic>> _furnitureData = [];
  List<Map<String, dynamic>> _decorationItems = [];
  List<Map<String, dynamic>> _sound = [];
  List<Map<String, dynamic>> _selectedSecurity = [];
  List<Map<String, dynamic>> _foodDetails = [];
  List<Map<String, dynamic>> _drinkDetails = [];


  List<Map<String, dynamic>> get furnitureData => _furnitureData;
  String get title => _title;
  String get description => _description;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get minAge => _minAge;
  bool get isPaid => _isPaid;
  bool get isPrivate => _isPrivate;
  bool get isInvitation => _isInvitation;
  bool get isTicket => _isTicket;
  String get imageUrl => _imageUrl;
  int? get eventId => _eventId;
  int? get venueId => _venueId;
  List<Map<String, dynamic>> get decorationItems => _decorationItems;
  List<Map<String, dynamic>> get sound => _sound;
  List<Map<String, dynamic>> get selectedSecurity => _selectedSecurity;
  List<Map<String, dynamic>> get foodDetails => _foodDetails;
  List<Map<String, dynamic>> get drinkDetails => _drinkDetails;


  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void setDescription(String description) {
    _description = description;
    notifyListeners();
  }

  void setStartDate(String startDate) {
    _startDate = DateTime.parse(startDate);
    notifyListeners();
  }

  void setEndDate(String endDate) {
    _endDate = DateTime.parse(endDate);
    notifyListeners();
  }

  void setMinAge(int minAge) {
    _minAge = minAge;
    notifyListeners();
  }

  void setIsPaid(bool isPaid) {
    _isPaid = isPaid;
    notifyListeners();
  }

  void setIsPrivate(bool isPrivate) {
    _isPrivate = isPrivate;
    notifyListeners();
  }

  void setIsInvitation(bool isInvitation) {
    _isInvitation = isInvitation;
    notifyListeners();
  }

  void setIsTicket(bool isTicket) {
    _isTicket = isTicket;
    notifyListeners();
  }

  void setImageUrl(String imageUrl) {
    _imageUrl = imageUrl;
    notifyListeners();
  }

  void setEventId(int eventId) {
    _eventId = eventId;
    notifyListeners();
  }

  void setVenueId(int id) {
    _venueId = id;
    notifyListeners();
  }

  void setSelectedFurniture(int id, int eventId, int quantity) {
    _furnitureData.add({
      'id': id,
      'eventId': eventId,
      'quantity': quantity,
    });
    notifyListeners();
  }

  void setDecorationItem(Map<String, dynamic> item) {
    _decorationItems.add(item);
    notifyListeners();
  }

  void setSoundDetails({
    required int id,
    required int eventId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    _sound.add({
      "id": id,
      "eventId": eventId,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
    });
    notifyListeners();
  }

  void setSelectedSecurity(int id, int quantity) {
    _selectedSecurity.add({
      "id": id,
      "quantity": quantity,
    });
    notifyListeners();
  }

  void setFoodDetails(int id, int quantity, DateTime servingDate) {
    _foodDetails.add({
      "id": id,
      "quantity": quantity,
      "servingDate": servingDate.toIso8601String(),
    });
    notifyListeners();
  }

  void setDrinkDetails(int id, int quantity, DateTime servingDate) {
    _drinkDetails.add({
      "id": id,
      "quantity": quantity,
      "servingDate": servingDate.toIso8601String(),
    });
    notifyListeners();
  }

  Map<String, dynamic> getEventData() {
    return {
      'title': _title,
      'description': _description,
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'minAge': _minAge,
      'isPaid': _isPaid,
      'isPrivate': _isPrivate,
      'attendanceType': {
        'isInvitation': _isInvitation,
        'isTicket': _isTicket,
      },
      'image': _imageUrl,
      'eventId': _eventId,
    };
  }

  Map<String, dynamic> getSecurityData() {
    return {
      "Security": _selectedSecurity,
    };
  }
}
