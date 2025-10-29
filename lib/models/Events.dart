import 'package:flutter/material.dart';

class Events {
  final int id ;
  final String imageUrl;
  final String title;
  final String description;
  final String location;
  final String startDate;
  final String endDate;
  final int minAge;
  final bool isPaid;
  final bool isPrivate;
  final double ticketPrice;
  final double rating;
  bool isFavorite;

  final bool isCreated;

  Events({
    required this.id,

    required this.imageUrl,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.minAge,
    required this.isPaid,
    required this.isPrivate,
    required this.ticketPrice,
    required this.rating,
    this.isFavorite = false, // Initialize with false or as needed
    required this.isCreated, // Make sure to include isCreated in the constructor
  });

  // factory Event.fromJson(Map<String, dynamic> json) {
  //   return Event(
  //     id: json['id'],
  //     title: json['title'],
  //     startDate: json['start_date'],
  //     imageUrl: json['image'],
  //     description: json['image'],
  //     location: json['image'],
  //     endDate: json['image'],
  //     minAge: json['image'],
  //     isPaid: json['image'],
  //     isPrivate: json['image'],
  //     ticketPrice: json['image'],
  //     rating: 0,
  //     isCreated: true,
  //     // Initialize other properties from JSON
  //   );
  // }
}
