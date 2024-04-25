class AppUser {
  final String name;
  final String id;
  final String role; // 'teacher' or 'student'
  final List<String> studentIds; // only applicable if role is 'teacher'

  // New fields
  final String? username;
  final String? email;
  final String? profilePicture;
  final String? birthDate;
  final String? gender;
  final String? country;
  final String? city;
  final String? phoneNumber;
  final String? address;
  final String? password;
  final bool? emailNotification;
  final String? privacySettings;

  AppUser({
    required this.name,
    required this.id,
    required this.role,
    this.studentIds = const [],
    // Initialize new fields
    this.username,
    this.email,
    this.profilePicture,
    this.birthDate,
    this.gender,
    this.country,
    this.city,
    this.phoneNumber,
    this.address,
    this.password,
    this.emailNotification,
    this.privacySettings,
  });
}