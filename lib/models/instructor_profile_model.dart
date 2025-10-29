// lib/models/instructor_profile_model.dart
class InstructorProfile {
  final int id;
  final String email;
  final String createdAt;
  final String updatedAt;

  InstructorProfile({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InstructorProfile.fromJson(Map<String, dynamic> json) {
    return InstructorProfile(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

