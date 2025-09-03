class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isVerified;
  final List<String>? categories;
  final String? bio;
  final String? photoUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isVerified,
    this.categories,
    this.bio,
    this.photoUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      isVerified: map['isVerified'] ?? false,
      categories: map['categories'] != null ? List<String>.from(map['categories']) : null,
      bio: map['bio'],
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'isVerified': isVerified,
      'categories': categories,
      'bio': bio,
      'photoUrl': photoUrl,
    };
  }
}
