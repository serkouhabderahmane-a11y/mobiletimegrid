class Holiday {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final bool isRecurring;
  final List<String>? applicableDepartments;
  final List<String>? applicableLocations;
  final String color;
  final bool isFullDay;
  final int? hoursCredit;

  Holiday({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    this.description,
    this.isRecurring = false,
    this.applicableDepartments,
    this.applicableLocations,
    this.color = '#006E5B',
    this.isFullDay = true,
    this.hoursCredit,
  });

  bool get isMultiDay => endDate != null && !_isSameDay(startDate, endDate!);

  bool get isPast => startDate.isBefore(DateTime.now());

  bool get isUpcoming => startDate.isAfter(DateTime.now());

  bool get isToday => _isSameDay(startDate, DateTime.now());

  String get dateRangeLabel {
    if (endDate == null) {
      return _formatDate(startDate);
    }
    if (_isSameDay(startDate, endDate!)) {
      return _formatDate(startDate);
    }
    return '${_formatDate(startDate)} - ${_formatDate(endDate!)}';
  }

  String get shortDateLabel {
    final day = startDate.day;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[startDate.month - 1];
    return '$day $month';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: json['endDate'] != null || json['end_date'] != null
          ? DateTime.parse(json['endDate'] ?? json['end_date'])
          : null,
      description: json['description'],
      isRecurring: json['isRecurring'] ?? json['is_recurring'] ?? false,
      applicableDepartments: json['applicableDepartments'] != null
          ? List<String>.from(json['applicableDepartments'])
          : null,
      applicableLocations: json['applicableLocations'] != null
          ? List<String>.from(json['applicableLocations'])
          : null,
      color: json['color'] ?? '#006E5B',
      isFullDay: json['isFullDay'] ?? json['is_full_day'] ?? true,
      hoursCredit: json['hoursCredit'] ?? json['hours_credit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'isRecurring': isRecurring,
      'applicableDepartments': applicableDepartments,
      'applicableLocations': applicableLocations,
      'color': color,
      'isFullDay': isFullDay,
      'hoursCredit': hoursCredit,
    };
  }

  Holiday copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    bool? isRecurring,
    List<String>? applicableDepartments,
    List<String>? applicableLocations,
    String? color,
    bool? isFullDay,
    int? hoursCredit,
  }) {
    return Holiday(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      isRecurring: isRecurring ?? this.isRecurring,
      applicableDepartments: applicableDepartments ?? this.applicableDepartments,
      applicableLocations: applicableLocations ?? this.applicableLocations,
      color: color ?? this.color,
      isFullDay: isFullDay ?? this.isFullDay,
      hoursCredit: hoursCredit ?? this.hoursCredit,
    );
  }
}

enum HolidayFilter {
  all,
  upcoming,
  passed,
}
