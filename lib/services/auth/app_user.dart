class AppUser {
  final String name;
  final String id;
  final String role; // 'teacher' or 'student'
  final List<String> studentIds; // only applicable if role is 'teacher'

  AppUser({
    required this.name,
    required this.id,
    required this.role,
    this.studentIds = const [],
  });
}