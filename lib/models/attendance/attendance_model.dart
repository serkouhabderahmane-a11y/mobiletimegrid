import '../user_model.dart';

enum AttendanceStatus {
  clockedIn,
  onBreak,
  clockedOut,
}

enum AttendanceEntryType {
  checkIn,
  breakStart,
  breakEnd,
  checkOut,
}

class AttendanceRecord {
  final String id;
  final String employeeId;
  final String? tenantId;
  final AttendanceStatus status;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;
  final Duration totalWorkedToday;
  final Duration totalWorkedPeriod;
  final List<AttendanceEntry> todayEntries;
  final List<DailySummary> periodSummary;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    this.tenantId,
    required this.status,
    this.clockInTime,
    this.clockOutTime,
    this.totalWorkedToday = Duration.zero,
    this.totalWorkedPeriod = Duration.zero,
    this.todayEntries = const [],
    this.periodSummary = const [],
  });

  bool get isClockedIn => status == AttendanceStatus.clockedIn;
  bool get isOnBreak => status == AttendanceStatus.onBreak;
  bool get isClockedOut => status == AttendanceStatus.clockedOut;

  String get formattedTodayHours {
    final hours = totalWorkedToday.inHours;
    final minutes = totalWorkedToday.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} Hrs Today';
  }

  String get formattedPeriodHours {
    final hours = totalWorkedPeriod.inHours;
    final minutes = totalWorkedPeriod.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} This Pay Period';
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? json['employee_id'] ?? '',
      tenantId: json['tenantId'] ?? json['tenant_id'],
      status: _parseStatus(json['status']),
      clockInTime: json['clockInTime'] != null 
          ? DateTime.parse(json['clockInTime'].toString())
          : null,
      clockOutTime: json['clockOutTime'] != null 
          ? DateTime.parse(json['clockOutTime'].toString())
          : null,
      totalWorkedToday: Duration(seconds: json['totalWorkedToday'] ?? json['total_worked_today'] ?? 0),
      totalWorkedPeriod: Duration(seconds: json['totalWorkedPeriod'] ?? json['total_worked_period'] ?? 0),
      todayEntries: (json['todayEntries'] as List<dynamic>?)
          ?.map((e) => AttendanceEntry.fromJson(e))
          .toList() ?? [],
      periodSummary: (json['periodSummary'] as List<dynamic>?)
          ?.map((e) => DailySummary.fromJson(e))
          .toList() ?? [],
    );
  }

  static AttendanceStatus _parseStatus(dynamic status) {
    switch (status?.toString()) {
      case 'clockedIn':
      case 'clocked_in':
        return AttendanceStatus.clockedIn;
      case 'onBreak':
      case 'on_break':
        return AttendanceStatus.onBreak;
      default:
        return AttendanceStatus.clockedOut;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'tenantId': tenantId,
      'status': status.toString().split('.').last,
      'clockInTime': clockInTime?.toIso8601String(),
      'clockOutTime': clockOutTime?.toIso8601String(),
      'totalWorkedToday': totalWorkedToday.inSeconds,
      'totalWorkedPeriod': totalWorkedPeriod.inSeconds,
      'todayEntries': todayEntries.map((e) => e.toJson()).toList(),
      'periodSummary': periodSummary.map((e) => e.toJson()).toList(),
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? employeeId,
    String? tenantId,
    AttendanceStatus? status,
    DateTime? clockInTime,
    DateTime? clockOutTime,
    Duration? totalWorkedToday,
    Duration? totalWorkedPeriod,
    List<AttendanceEntry>? todayEntries,
    List<DailySummary>? periodSummary,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      tenantId: tenantId ?? this.tenantId,
      status: status ?? this.status,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      totalWorkedToday: totalWorkedToday ?? this.totalWorkedToday,
      totalWorkedPeriod: totalWorkedPeriod ?? this.totalWorkedPeriod,
      todayEntries: todayEntries ?? this.todayEntries,
      periodSummary: periodSummary ?? this.periodSummary,
    );
  }
}

class AttendanceEntry {
  final String id;
  final String employeeId;
  final AttendanceEntryType type;
  final DateTime timestamp;
  final String? notes;
  final PatientInfo? patient;

  AttendanceEntry({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.timestamp,
    this.notes,
    this.patient,
  });

  String get typeLabel {
    switch (type) {
      case AttendanceEntryType.checkIn:
        return 'Check In';
      case AttendanceEntryType.breakStart:
        return 'Break';
      case AttendanceEntryType.breakEnd:
        return 'Break End';
      case AttendanceEntryType.checkOut:
        return 'Check Out';
    }
  }

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceEntry(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? json['employee_id'] ?? '',
      type: _parseType(json['type']),
      timestamp: DateTime.parse(json['timestamp'].toString()),
      notes: json['notes'],
      patient: json['patient'] != null ? PatientInfo.fromJson(json['patient']) : null,
    );
  }

  static AttendanceEntryType _parseType(dynamic type) {
    switch (type?.toString()) {
      case 'checkIn':
      case 'check_in':
        return AttendanceEntryType.checkIn;
      case 'breakStart':
      case 'break_start':
        return AttendanceEntryType.breakStart;
      case 'breakEnd':
      case 'break_end':
        return AttendanceEntryType.breakEnd;
      case 'checkOut':
      case 'check_out':
        return AttendanceEntryType.checkOut;
      default:
        return AttendanceEntryType.checkIn;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'patient': patient?.toJson(),
    };
  }
}

class PatientInfo {
  final String id;
  final String name;
  final String? phone;
  final String? avatarUrl;

  PatientInfo({
    required this.id,
    required this.name,
    this.phone,
    this.avatarUrl,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Patient',
      phone: json['phone'],
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
    };
  }
}

class DailySummary {
  final DateTime date;
  final Duration totalHours;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int entriesCount;

  DailySummary({
    required this.date,
    required this.totalHours,
    this.checkIn,
    this.checkOut,
    this.entriesCount = 0,
  });

  String get formattedDate {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String get formattedHours {
    final hours = totalHours.inHours;
    final minutes = totalHours.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String? get formattedCheckIn {
    if (checkIn == null) return null;
    return '${checkIn!.hour.toString().padLeft(2, '0')}:${checkIn!.minute.toString().padLeft(2, '0')}';
  }

  String? get formattedCheckOut {
    if (checkOut == null) return null;
    return '${checkOut!.hour.toString().padLeft(2, '0')}:${checkOut!.minute.toString().padLeft(2, '0')}';
  }

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: DateTime.parse(json['date'].toString()),
      totalHours: Duration(hours: (json['totalHours'] ?? json['total_hours'] ?? 0).toInt()),
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn'].toString()) : null,
      checkOut: json['checkOut'] != null ? DateTime.parse(json['checkOut'].toString()) : null,
      entriesCount: json['entriesCount'] ?? json['entries_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalHours': totalHours.inHours,
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'entriesCount': entriesCount,
    };
  }
}
