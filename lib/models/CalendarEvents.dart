class CalendarEvent {
  final int id;
  final int userId;
  final int categoryId;
  final String title;
  final DateTime startDate;
  final int minAge;
  final bool isPaid;
  final bool isPrivate;
  final String image;
  final String state;

  CalendarEvent({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.startDate,
    required this.minAge,
    required this.isPaid,
    required this.isPrivate,
    required this.image,
    required this.state,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      title: json['title'],
      startDate: DateTime.parse(json['start_date']), // Parsing the date string to DateTime
      minAge: json['min_age'],
      isPaid: json['is_paid'] == 1,
      isPrivate: json['is_private'] == 1,
      image: json['image'],
      state: json['state'],
    );
  }
}
