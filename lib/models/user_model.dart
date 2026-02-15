class UserModel {
  final String uid;
  final String name;
  final String email;
  final String searchName;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.searchName,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      searchName: map['searchName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'searchName': searchName,
    };
  }
}
