class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool mustChangePassword;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.mustChangePassword = false,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      mustChangePassword: json['must_change_password'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'must_change_password': mustChangePassword,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    bool? mustChangePassword,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AuthResponse {
  final String tokenType;
  final String accessToken;
  final bool mustChangePassword;
  final User user;
  final String? message;
  final String? defaultPassword;

  AuthResponse({
    required this.tokenType,
    required this.accessToken,
    required this.user,
    this.mustChangePassword = false,
    this.message,
    this.defaultPassword,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      tokenType: json['token_type'] as String? ?? 'Bearer',
      accessToken: json['access_token'] as String? ?? '',
      mustChangePassword: json['must_change_password'] as bool? ?? false,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String?,
      defaultPassword: json['default_password'] as String?,
    );
  }

  String get fullToken => '$tokenType $accessToken';
}
