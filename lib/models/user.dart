class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String tenantId;
  final DateTime? hireDate;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.tenantId,
    this.hireDate,
    this.metadata,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      role: json['role'] ?? 'employee',
      tenantId: json['tenant_id'] ?? json['tenantId'] ?? '',
      hireDate: json['hire_date'] != null 
          ? DateTime.tryParse(json['hire_date']) 
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'tenant_id': tenantId,
      'hire_date': hireDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? tenantId,
    DateTime? hireDate,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      hireDate: hireDate ?? this.hireDate,
      metadata: metadata ?? this.metadata,
    );
  }
}
