import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'auth_service.dart';

class TimeClockService extends ChangeNotifier {
  static const String _entriesKey = 'time_entries';
  static const String _configKey = 'timeclock_config';

  final AuthService _authService;

  TimeEntry? _activeEntry;
  List<TimeEntry> _entries = [];
  TimeClockConfig _config = TimeClockConfig();
  bool _isLoading = false;
  String? _error;

  TimeClockService(this._authService);

  TimeEntry? get activeEntry => _activeEntry;
  List<TimeEntry> get entries => _entries;
  TimeClockConfig get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isClockedIn => _activeEntry != null;

  Duration get todayWorked {
    final today = DateTime.now();
    return _entries
        .where((e) =>
            e.clockIn.year == today.year &&
            e.clockIn.month == today.month &&
            e.clockIn.day == today.day)
        .fold(Duration.zero, (sum, e) => sum + e.workedDuration);
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_authService.token == null || _authService.token!.startsWith('demo-')) {
        _entries = _getDemoEntries();
        _activeEntry = _entries.isNotEmpty && _entries.first.isClockedIn ? _entries.first : null;
      } else {
        final response = await _authService.api.get('/timeclock/entries');
        _entries = (response['entries'] as List?)
                ?.map((e) => TimeEntry.fromJson(e))
                .toList() ??
            [];
        
        _activeEntry = _entries.isNotEmpty && _entries.first.isClockedIn 
            ? _entries.first 
            : null;

        if (response['config'] != null) {
          _config = TimeClockConfig.fromJson(response['config']);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _entries = _getDemoEntries();
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  List<TimeEntry> _getDemoEntries() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    return [
      TimeEntry(
        id: 'demo-entry-3',
        userId: 'demo-user-001',
        tenantId: 'demo-tenant',
        clockIn: DateTime(yesterday.year, yesterday.month, yesterday.day, 9, 0),
        clockOut: DateTime(yesterday.year, yesterday.month, yesterday.day, 17, 30),
        notes: 'Regular workday',
        status: 'completed',
      ),
      TimeEntry(
        id: 'demo-entry-2',
        userId: 'demo-user-001',
        tenantId: 'demo-tenant',
        clockIn: DateTime(yesterday.year, yesterday.month, yesterday.day - 1, 8, 30),
        clockOut: DateTime(yesterday.year, yesterday.month, yesterday.day - 1, 17, 0),
        notes: 'Regular workday',
        status: 'completed',
      ),
      TimeEntry(
        id: 'demo-entry-1',
        userId: 'demo-user-001',
        tenantId: 'demo-tenant',
        clockIn: DateTime(now.year, now.month, now.day, 8, 45),
        clockOut: null,
        notes: null,
        status: 'active',
      ),
    ];
  }

  Future<bool> clockIn({String? jobCode, String? notes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final newEntry = TimeEntry(
        id: 'entry-${now.millisecondsSinceEpoch}',
        userId: _authService.currentUser?.id ?? 'demo-user',
        tenantId: _authService.tenantId ?? 'demo-tenant',
        clockIn: now,
        clockOut: null,
        jobCode: jobCode,
        notes: notes,
        status: 'active',
      );

      if (_authService.token == null || _authService.token!.startsWith('demo-')) {
        _entries.insert(0, newEntry);
        _activeEntry = newEntry;
      } else {
        final response = await _authService.api.post('/timeclock/clock-in', body: {
          'job_code': jobCode,
          'notes': notes,
        });
        _activeEntry = TimeEntry.fromJson(response['entry']);
        _entries.insert(0, _activeEntry!);
      }

      await _saveEntries();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> clockOut({String? notes}) async {
    if (_activeEntry == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final updatedEntry = TimeEntry(
        id: _activeEntry!.id,
        userId: _activeEntry!.userId,
        tenantId: _activeEntry!.tenantId,
        clockIn: _activeEntry!.clockIn,
        clockOut: now,
        notes: notes ?? _activeEntry!.notes,
        jobCode: _activeEntry!.jobCode,
        status: 'completed',
      );

      if (_authService.token == null || _authService.token!.startsWith('demo-')) {
        final index = _entries.indexWhere((e) => e.id == _activeEntry!.id);
        if (index >= 0) {
          _entries[index] = updatedEntry;
        }
        _activeEntry = null;
      } else {
        await _authService.api.post('/timeclock/clock-out', body: {
          'entry_id': updatedEntry.id,
          'notes': notes,
        });
        
        final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
        if (index >= 0) {
          _entries[index] = updatedEntry;
        }
        _activeEntry = null;
      }

      await _saveEntries();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _authService.currentUser?.id ?? 'demo-user';
    
    final entriesJson = _entries.map((e) {
      return '${e.id}|${e.clockIn.toIso8601String()}|${e.clockOut?.toIso8601String() ?? ''}|${e.jobCode ?? ''}|${e.notes ?? ''}|${e.status}';
    }).join(';;');
    
    await prefs.setString('${_entriesKey}_$userId', entriesJson);
  }

  List<TimeEntry> getEntriesForDateRange(DateTime start, DateTime end) {
    return _entries.where((e) {
      return e.clockIn.isAfter(start) && e.clockIn.isBefore(end);
    }).toList();
  }
}
