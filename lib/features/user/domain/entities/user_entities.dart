class UserEntity {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bio;
  final List<String> interests;
  final List<String> photos;
  final String location;

  const UserEntity({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bio,
    required this.interests,
    required this.photos,
    required this.location,
  });
}