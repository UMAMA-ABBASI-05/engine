class UserModel {
  final int userId;
  final String email;

  UserModel({required this.userId, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(userId: json['user_id'], email: json['email']);
}
