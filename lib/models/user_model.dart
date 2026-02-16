class UserModel {
  final String uid;
  final String name;
  final String email;
  final String searchName;
  final String? profilePictureUrl; // Add this field

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.searchName,
    this.profilePictureUrl, // Add it to constructor
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      searchName: map['searchName'] ?? '',
      profilePictureUrl: map['profilePictureUrl'], // Add this line
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'searchName': searchName,
      'profilePictureUrl': profilePictureUrl, // Add this line
    };
  }
}
