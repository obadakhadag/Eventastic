import 'package:flutter/material.dart';

class UserThingsProvider with ChangeNotifier {
  int _id = 0;
  String _firstName = '';
  String _lastName = '';
  String _profilePic = '';
  String _QRcode = '';

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get profilePic => _profilePic;
  String get QRcode => _QRcode;
  int get id => _id;


  void setUser({  required int id , required String firstName, required String lastName, required String profilePic   , required String QRcode}) {
    _id = id ;
    _firstName = firstName;
    _lastName = lastName;
    _profilePic = profilePic;
    _QRcode = QRcode;

    notifyListeners();
  }
}
