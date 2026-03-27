import '../../models/holiday/holiday_model.dart';
import 'api_service.dart';

class HolidayService {
  final ApiService _api;

  HolidayService(this._api);

  Future<List<Holiday>> getHolidays() async {
    try {
      final response = await _api.get('/holidays');
      final holidays = (response['holidays'] as List<dynamic>?)
          ?.map((h) => Holiday.fromJson(h))
          .toList() ?? [];
      return holidays;
    } catch (_) {
      return _getMockHolidays();
    }
  }

  Future<List<Holiday>> getUpcomingHolidays() async {
    try {
      final response = await _api.get('/holidays?filter=upcoming');
      final holidays = (response['holidays'] as List<dynamic>?)
          ?.map((h) => Holiday.fromJson(h))
          .toList() ?? [];
      return holidays;
    } catch (_) {
      return _getMockHolidays().where((h) => h.isUpcoming || h.isToday).toList();
    }
  }

  Future<List<Holiday>> getPastHolidays() async {
    try {
      final response = await _api.get('/holidays?filter=passed');
      final holidays = (response['holidays'] as List<dynamic>?)
          ?.map((h) => Holiday.fromJson(h))
          .toList() ?? [];
      return holidays;
    } catch (_) {
      return _getMockHolidays().where((h) => h.isPast).toList();
    }
  }

  List<Holiday> _getMockHolidays() {
    final now = DateTime.now();
    final year = now.year;
    
    return [
      Holiday(
        id: 'hol-1',
        name: 'New Year\'s Day',
        startDate: DateTime(year, 1, 1),
        description: 'Celebration of the new year',
        color: '#42B883',
      ),
      Holiday(
        id: 'hol-2',
        name: 'Eid-ul-Fitr',
        startDate: DateTime(year, 3, 10),
        endDate: DateTime(year, 3, 11),
        description: 'Islamic holiday marking the end of Ramadan',
        color: '#8B5CF6',
      ),
      Holiday(
        id: 'hol-3',
        name: 'Labour Day',
        startDate: DateTime(year, 5, 1),
        description: 'International Workers\' Day',
        color: '#EF4444',
      ),
      Holiday(
        id: 'hol-4',
        name: 'Eid-ul-Adha',
        startDate: DateTime(year, 6, 15),
        endDate: DateTime(year, 6, 16),
        description: 'Islamic holiday of sacrifice',
        color: '#8B5CF6',
      ),
      Holiday(
        id: 'hol-5',
        name: 'Independence Day',
        startDate: DateTime(year, 7, 4),
        description: 'National holiday celebrating independence',
        color: '#3B82F6',
      ),
      Holiday(
        id: 'hol-6',
        name: 'Christmas Day',
        startDate: DateTime(year, 12, 25),
        description: 'Christian holiday celebrating the birth of Christ',
        color: '#EF4444',
      ),
      Holiday(
        id: 'hol-7',
        name: 'Boxing Day',
        startDate: DateTime(year, 12, 26),
        description: 'Day after Christmas',
        color: '#3B82F6',
      ),
      Holiday(
        id: 'hol-8',
        name: 'Memorial Day',
        startDate: DateTime(year - 1, 5, 27),
        endDate: DateTime(year - 1, 5, 28),
        description: 'Day to honor military personnel who have died',
        color: '#42B883',
      ),
      Holiday(
        id: 'hol-9',
        name: 'Thanksgiving',
        startDate: DateTime(year - 1, 11, 23),
        description: 'Day to give thanks for the harvest',
        color: '#F59E0B',
      ),
      Holiday(
        id: 'hol-10',
        name: 'Veterans Day',
        startDate: DateTime(year - 1, 11, 11),
        description: 'Honor veterans of the US armed forces',
        color: '#42B883',
      ),
    ];
  }
}
