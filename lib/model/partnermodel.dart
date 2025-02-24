class Partner {
  final int id;
  final String name;
  final dynamic phone;
  final dynamic email;
  final dynamic image; // image_1920 ko map karne ke liye

  Partner({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.image,
  });

  // JSON se model banane ke liye
  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'],
      name: json['name'],
      phone: json['phone'] is bool ? "" : json['phone'],
      email: json['email'] is bool ? "" : json['email'],
      image: json['image_1920'] is bool
          ? ""
          : json['image_1920'], // API field image_1920 handle kiya
    );
  }

  // Model ko JSON me convert karne ke liye
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'image_1920': image, // JSON me image_1920 key use hogi
    };
  }
}
