class MostPEvents {
  final int id;
  final int userId;
  final int categoryId;
  final String title;
  final String descriptionAr;
  final String descriptionEn;
  final String startDate;
  final String endDate;
  final int minAge;
  final int isPaid;
  final int isPrivate;
  final String attendanceType;
  final double totalCost; // Changed to double
  final double ticketPrice; // Changed to double
  final double vipTicketPrice; // Changed to double
  final String image;
  final String qrCode;
  final double rating; // Changed to double
  final String createdAt;
  final String updatedAt;
  final double creatorRating; // Changed to double
  bool isFavorite;  // Add this property

  MostPEvents({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.startDate,
    required this.endDate,
    required this.minAge,
    required this.isPaid,
    required this.isPrivate,
    required this.attendanceType,
    required this.totalCost,
    required this.ticketPrice,
    required this.vipTicketPrice,
    required this.image,
    required this.qrCode,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorRating,
    required this.isFavorite,
  });

  factory MostPEvents.fromJson(Map<String, dynamic> json) {
    return MostPEvents(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      title: json['title'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      minAge: json['min_age'] ?? 0,
      isPaid: json['is_paid'] ?? 1,
      isPrivate: json['is_private'] ?? 0,
      attendanceType: json['attendance_type'] ?? '',
      totalCost: double.parse(json['total_cost'] ?? '0'), // Handle string to double conversion
      ticketPrice: double.parse(json['ticket_price'] ?? '0'), // Handle string to double conversion
      vipTicketPrice: double.parse(json['vip_ticket_price'] ?? '0'), // Handle string to double conversion
      image: json['image'] ?? '',
      qrCode: json['qr_code'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0, // Handle int to double conversion
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      creatorRating: json['creator_rating']?.toDouble() ?? 0.0, // Handle int to double conversion
      isFavorite: json['isFavourite'] ?? false, // Corrected to 'isFavourite' as per the API response
    );
  }
}
