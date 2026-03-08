class UserEntity {
  final String uid;
  final String email;
  final String displayName;
  final bool emailVerified;
  final DateTime createdAt;
  final bool notificationsEnabled;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.emailVerified,
    required this.createdAt,
    this.notificationsEnabled = false,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? emailVerified,
    DateTime? createdAt,
    bool? notificationsEnabled,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
