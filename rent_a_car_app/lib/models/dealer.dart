class Dealer {
  final String id;
  final String name;
  final String location;
  final String phone;
  final String? profileImage;

  Dealer({
    required this.id,
    required this.name,
    required this.location,
    required this.phone,
    this.profileImage,
  });

  /// Cria instância a partir do JSON da API
  factory Dealer.fromJson(Map<String, dynamic> json) {
    return Dealer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profile_image'],
    );
  }
}
