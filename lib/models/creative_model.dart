import 'user_model.dart';

class CreativeModel extends AppUser {
  final String? rate;

  CreativeModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
    required super.isVerified,
    super.categories,
    super.bio,
    super.photoUrl,
    this.rate,
  });

  factory CreativeModel.fromMap(Map<String, dynamic> map) {
    return CreativeModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      isVerified: map['isVerified'] ?? false,
      categories: map['categories'] != null ? List<String>.from(map['categories']) : null,
      bio: map['bio'],
      photoUrl: map['photoUrl'],
      rate: map['rate'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['rate'] = rate;
    return map;
  }
}
