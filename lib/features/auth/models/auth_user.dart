class AuthUser {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
  });

  bool get isEmailVerified => emailVerifiedAt != null;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
    };
  }

  AuthUser copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? emailVerifiedAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          emailVerifiedAt == other.emailVerifiedAt;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ email.hashCode ^ emailVerifiedAt.hashCode;
}
