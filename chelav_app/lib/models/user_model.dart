class UserModel {
  final String id;
  final String name;
  final String email;
  final String currency;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      currency: json['currency'] ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'currency': currency,
    };
  }
}
