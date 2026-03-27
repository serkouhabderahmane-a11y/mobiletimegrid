import '../../models/attendance/attendance_model.dart';
import 'api_service.dart';

class AttendanceService {
  final ApiService _api;

  AttendanceService(this._api);

  Future<AttendanceRecord> getCurrentStatus() async {
    try {
      final response = await _api.get('/attendance/status');
      return AttendanceRecord.fromJson(response);
    } catch (_) {
      return _getMockAttendanceRecord();
    }
  }

  Future<AttendanceRecord> clockIn() async {
    try {
      final response = await _api.post('/attendance/clock-in');
      return AttendanceRecord.fromJson(response);
    } catch (_) {
      return _getMockAttendanceRecord().copyWith(
        status: AttendanceStatus.clockedIn,
        clockInTime: DateTime.now(),
      );
    }
  }

  Future<AttendanceRecord> clockOut() async {
    try {
      final response = await _api.post('/attendance/clock-out');
      return AttendanceRecord.fromJson(response);
    } catch (_) {
      return AttendanceRecord(
        id: 'att-1',
        employeeId: 'emp-1',
        status: AttendanceStatus.clockedOut,
        clockInTime: DateTime.now().subtract(const Duration(hours: 6)),
        clockOutTime: DateTime.now(),
      );
    }
  }

  Future<AttendanceRecord> startBreak() async {
    try {
      final response = await _api.post('/attendance/break/start');
      return AttendanceRecord.fromJson(response);
    } catch (_) {
      return _getMockAttendanceRecord().copyWith(
        status: AttendanceStatus.onBreak,
      );
    }
  }

  Future<AttendanceRecord> endBreak() async {
    try {
      final response = await _api.post('/attendance/break/end');
      return AttendanceRecord.fromJson(response);
    } catch (_) {
      return _getMockAttendanceRecord().copyWith(
        status: AttendanceStatus.clockedIn,
      );
    }
  }

  Future<List<AttendanceEntry>> getTodayEntries() async {
    try {
      final response = await _api.get('/attendance/entries/today');
      final entries = (response['entries'] as List<dynamic>?)
          ?.map((e) => AttendanceEntry.fromJson(e))
          .toList() ?? [];
      return entries;
    } catch (_) {
      return _getMockEntries();
    }
  }

  Future<List<DailySummary>> getPayPeriodSummary() async {
    try {
      final response = await _api.get('/attendance/pay-period');
      final summaries = (response['summary'] as List<dynamic>?)
          ?.map((s) => DailySummary.fromJson(s))
          .toList() ?? [];
      return summaries;
    } catch (_) {
      return _getMockPeriodSummary();
    }
  }

  AttendanceRecord _getMockAttendanceRecord() {
    return AttendanceRecord(
      id: 'att-1',
      employeeId: 'emp-1',
      status: AttendanceStatus.clockedIn,
      clockInTime: DateTime.now().subtract(const Duration(hours: 6, minutes: 48)),
      totalWorkedToday: const Duration(hours: 6, minutes: 48),
      totalWorkedPeriod: const Duration(hours: 96, minutes: 42),
      todayEntries: _getMockEntries(),
      periodSummary: _getMockPeriodSummary(),
    );
  }

  List<AttendanceEntry> _getMockEntries() {
    final now = DateTime.now();
    return [
      AttendanceEntry(
        id: 'entry-1',
        employeeId: 'emp-1',
        type: AttendanceEntryType.checkIn,
        timestamp: DateTime(now.year, now.month, now.day, 9, 0),
        patient: PatientInfo(
          id: 'patient-1',
          name: 'John Smith',
          phone: '+1 555-0100',
        ),
      ),
      AttendanceEntry(
        id: 'entry-2',
        employeeId: 'emp-1',
        type: AttendanceEntryType.breakStart,
        timestamp: DateTime(now.year, now.month, now.day, 12, 30),
        patient: null,
      ),
      AttendanceEntry(
        id: 'entry-3',
        employeeId: 'emp-1',
        type: AttendanceEntryType.breakEnd,
        timestamp: DateTime(now.year, now.month, now.day, 13, 0),
        patient: null,
      ),
    ];
  }

  List<DailySummary> _getMockPeriodSummary() {
    final now = DateTime.now();
    return [
      DailySummary(
        date: now.subtract(const Duration(days: 4)),
        totalHours: const Duration(hours: 8),
        checkIn: DateTime(now.year, now.month, now.day - 4, 9, 0),
        checkOut: DateTime(now.year, now.month, now.day - 4, 17, 30),
        entriesCount: 4,
      ),
      DailySummary(
        date: now.subtract(const Duration(days: 3)),
        totalHours: const Duration(hours: 7, minutes: 45),
        checkIn: DateTime(now.year, now.month, now.day - 3, 9, 15),
        checkOut: DateTime(now.year, now.month, now.day - 3, 17, 0),
        entriesCount: 3,
      ),
      DailySummary(
        date: now.subtract(const Duration(days: 2)),
        totalHours: const Duration(hours: 8, minutes: 15),
        checkIn: DateTime(now.year, now.month, now.day - 2, 8, 45),
        checkOut: DateTime(now.year, now.month, now.day - 2, 17, 30),
        entriesCount: 5,
      ),
      DailySummary(
        date: now.subtract(const Duration(days: 1)),
        totalHours: const Duration(hours: 8),
        checkIn: DateTime(now.year, now.month, now.day - 1, 9, 0),
        checkOut: DateTime(now.year, now.month, now.day - 1, 17, 30),
        entriesCount: 4,
      ),
    ];
  }
}
