class User {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.createdAt,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String username;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAt;

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return username.isEmpty ? '?' : username[0].toUpperCase();
    }
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final first = (json['firstName'] ?? '') as String;
    final last = (json['lastName'] ?? '') as String;
    final full = json['fullName'] as String?;
    return User(
      id: (json['id'] as num).toInt(),
      firstName: first,
      lastName: last,
      fullName: (full == null || full.isEmpty) ? '$first $last'.trim() : full,
      username: (json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'fullName': fullName,
    'username': username,
    'email': email,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt?.toIso8601String(),
  };
}
