enum FormStatus {
  draft,
  submitted,
  approved,
  rejected,
}

class GovernmentForms {
  final String id;
  final String tenantId;
  final String userId;
  final String formType;
  final String status;
  final Map<String, dynamic> formData;
  final Map<String, dynamic>? submittedSnapshot;
  final String? taskId;
  final String? signedName;
  final bool attestationAgreed;
  final DateTime createdAt;
  final DateTime updatedAt;

  GovernmentForms({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.formType,
    required this.status,
    required this.formData,
    this.submittedSnapshot,
    this.taskId,
    this.signedName,
    this.attestationAgreed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  FormStatus get formStatus {
    switch (status.toLowerCase()) {
      case 'draft':
        return FormStatus.draft;
      case 'submitted':
        return FormStatus.submitted;
      case 'approved':
        return FormStatus.approved;
      case 'rejected':
        return FormStatus.rejected;
      default:
        return FormStatus.draft;
    }
  }

  bool get isReadOnly => formStatus != FormStatus.draft;

  factory GovernmentForms.fromJson(Map<String, dynamic> json) {
    return GovernmentForms(
      id: json['id'] ?? '',
      tenantId: json['tenant_id'] ?? json['tenantId'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      formType: json['form_type'] ?? json['formType'] ?? '',
      status: json['status'] ?? 'draft',
      formData: json['form_data'] ?? json['formData'] ?? {},
      submittedSnapshot: json['submitted_snapshot'] ?? json['submittedSnapshot'],
      taskId: json['task_id'] ?? json['taskId'],
      signedName: json['signed_name'] ?? json['signedName'],
      attestationAgreed: json['attestation_agreed'] ?? json['attestationAgreed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'user_id': userId,
      'form_type': formType,
      'status': status,
      'form_data': formData,
      'submitted_snapshot': submittedSnapshot,
      'task_id': taskId,
      'signed_name': signedName,
      'attestation_agreed': attestationAgreed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GovernmentForms copyWith({
    String? id,
    String? tenantId,
    String? userId,
    String? formType,
    String? status,
    Map<String, dynamic>? formData,
    Map<String, dynamic>? submittedSnapshot,
    String? taskId,
    String? signedName,
    bool? attestationAgreed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GovernmentForms(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      userId: userId ?? this.userId,
      formType: formType ?? this.formType,
      status: status ?? this.status,
      formData: formData ?? this.formData,
      submittedSnapshot: submittedSnapshot ?? this.submittedSnapshot,
      taskId: taskId ?? this.taskId,
      signedName: signedName ?? this.signedName,
      attestationAgreed: attestationAgreed ?? this.attestationAgreed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class W4FormData {
  final String? filingStatus;
  final int? allowances;
  final bool? multipleJobs;
  final bool? claimDependents;
  final double? otherIncome;
  final double? deductions;
  final double? extraWithholding;
  final String? stepOneName;
  final String? stepOneSsn;
  final String? stepOneAddress;

  W4FormData({
    this.filingStatus,
    this.allowances,
    this.multipleJobs,
    this.claimDependents,
    this.otherIncome,
    this.deductions,
    this.extraWithholding,
    this.stepOneName,
    this.stepOneSsn,
    this.stepOneAddress,
  });

  factory W4FormData.fromJson(Map<String, dynamic> json) {
    return W4FormData(
      filingStatus: json['filing_status'],
      allowances: json['allowances'],
      multipleJobs: json['multiple_jobs'],
      claimDependents: json['claim_dependents'],
      otherIncome: (json['other_income'] as num?)?.toDouble(),
      deductions: (json['deductions'] as num?)?.toDouble(),
      extraWithholding: (json['extra_withholding'] as num?)?.toDouble(),
      stepOneName: json['step_one_name'],
      stepOneSsn: json['step_one_ssn'],
      stepOneAddress: json['step_one_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filing_status': filingStatus,
      'allowances': allowances,
      'multiple_jobs': multipleJobs,
      'claim_dependents': claimDependents,
      'other_income': otherIncome,
      'deductions': deductions,
      'extra_withholding': extraWithholding,
      'step_one_name': stepOneName,
      'step_one_ssn': stepOneSsn,
      'step_one_address': stepOneAddress,
    };
  }
}

class I9FormData {
  final String? citizenshipStatus;
  final String? alienNumber;
  final String? admissionNumber;
  final String? foreignPassportNumber;
  final String? countryOfIssuance;
  final String? lastName;
  final String? firstName;
  final String? middleInitial;
  final DateTime? dateOfBirth;
  final String? streetAddress;
  final String? apartment;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? gender;
  final DateTime? startDate;

  I9FormData({
    this.citizenshipStatus,
    this.alienNumber,
    this.admissionNumber,
    this.foreignPassportNumber,
    this.countryOfIssuance,
    this.lastName,
    this.firstName,
    this.middleInitial,
    this.dateOfBirth,
    this.streetAddress,
    this.apartment,
    this.city,
    this.state,
    this.zipCode,
    this.gender,
    this.startDate,
  });

  factory I9FormData.fromJson(Map<String, dynamic> json) {
    return I9FormData(
      citizenshipStatus: json['citizenship_status'],
      alienNumber: json['alien_number'],
      admissionNumber: json['admission_number'],
      foreignPassportNumber: json['foreign_passport_number'],
      countryOfIssuance: json['country_of_issuance'],
      lastName: json['last_name'],
      firstName: json['first_name'],
      middleInitial: json['middle_initial'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      streetAddress: json['street_address'],
      apartment: json['apartment'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      gender: json['gender'],
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'citizenship_status': citizenshipStatus,
      'alien_number': alienNumber,
      'admission_number': admissionNumber,
      'foreign_passport_number': foreignPassportNumber,
      'country_of_issuance': countryOfIssuance,
      'last_name': lastName,
      'first_name': firstName,
      'middle_initial': middleInitial,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'street_address': streetAddress,
      'apartment': apartment,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'gender': gender,
      'start_date': startDate?.toIso8601String(),
    };
  }
}
