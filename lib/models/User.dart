class User {
  final String id;
  final String user_name;
  final String user_family;

  User({required this.id, required this.user_name, required this.user_family});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      user_name: json['user_name'],
      user_family: json['user_family'],
    );
  }
}
