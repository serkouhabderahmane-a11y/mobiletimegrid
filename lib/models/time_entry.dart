class TimeEntry {
  final String id;
  final String userId;
  final String tenantId;
  final DateTime clockIn;
  final DateTime? clockOut;
  final String? notes;
  final String? jobCode;
  final String status;

  TimeEntry({
    required this.id,
    required this.userId,
    required this.tenantId,
    required this.clockIn,
    this.clockOut,
    this.notes,
    this.jobCode,
    required this.status,
  });

  Duration get workedDuration {
    final end = clockOut ?? DateTime.now();
    return end.difference(clockIn);
  }

  bool get isClockedIn => clockOut == null;

  String get formattedDuration {
    final hours = workedDuration.inHours;
    final minutes = workedDuration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      tenantId: json['tenant_id'] ?? json['tenantId'] ?? '',
      clockIn: DateTime.parse(json['clock_in'] ?? json['clockIn']),
      clockOut: json['clock_out'] != null || json['clockOut'] != null
          ? DateTime.tryParse(json['clock_out'] ?? json['clockOut'])
          : null,
      notes: json['notes'],
      jobCode: json['job_code'] ?? json['jobCode'],
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tenant_id': tenantId,
      'clock_in': clockIn.toIso8601String(),
      'clock_out': clockOut?.toIso8601String(),
      'notes': notes,
      'job_code': jobCode,
      'status': status,
    };
  }
}

class TimeClockConfig {
  final bool requireJobCode;
  final bool requireNotes;
  final List<String> availableJobCodes;
  final double? overtimeThreshold;

  TimeClockConfig({
    this.requireJobCode = false,
    this.requireNotes = false,
    this.availableJobCodes = const [],
    this.overtimeThreshold,
  });

  factory TimeClockConfig.fromJson(Map<String, dynamic> json) {
    return TimeClockConfig(
      requireJobCode: json['require_job_code'] ?? json['requireJobCode'] ?? false,
      requireNotes: json['require_notes'] ?? json['requireNotes'] ?? false,
      availableJobCodes: json['available_job_codes'] != null
          ? List<String>.from(json['available_job_codes'])
          : [],
      overtimeThreshold: (json['overtime_threshold'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'require_job_code': requireJobCode,
      'require_notes': requireNotes,
      'available_job_codes': availableJobCodes,
      'overtime_threshold': overtimeThreshold,
    };
  }
}
