class Follower {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String address;
  final String phoneNumber;
  final int points;
  final double rating;
  final String profilePic;

  Follower({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.address,
    required this.phoneNumber,
    required this.points,
    required this.rating,
    required this.profilePic,
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      points: json['points'],
      rating: json['rating'].toDouble(),
      profilePic: json['profile_pic'],
    );
  }
}
