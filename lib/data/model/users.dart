class User{
  final String uid;
  final String email;
  final String role;

  User({
    required this.uid,
    required this.email,
    required this.role,
  });

  //dto
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
    };
  }
}