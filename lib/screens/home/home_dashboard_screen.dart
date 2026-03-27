import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/attendance/attendance_model.dart';
import '../../services/app/attendance_service.dart';
import '../../services/app/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/user_avatar.dart';
import '../../widgets/common/states.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final AttendanceService _attendanceService;
  
  AttendanceRecord? _attendance;
  bool _isLoading = true;
  String? _error;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  _HomeDashboardScreenState() : _attendanceService = AttendanceService(ApiService());

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _attendance?.clockInTime != null) {
        setState(() {
          _elapsedTime = DateTime.now().difference(_attendance!.clockInTime!);
        });
      }
    });
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final attendance = await _attendanceService.getCurrentStatus();
      setState(() {
        _attendance = attendance;
        _isLoading = false;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _clockIn() async {
    try {
      final result = await _attendanceService.clockIn();
      setState(() {
        _attendance = result;
      });
      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clock in: $e')),
        );
      }
    }
  }

  Future<void> _clockOut() async {
    try {
      final result = await _attendanceService.clockOut();
      _timer?.cancel();
      setState(() {
        _attendance = result;
        _elapsedTime = Duration.zero;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clock out: $e')),
        );
      }
    }
  }

  Future<void> _toggleBreak() async {
    try {
      AttendanceRecord result;
      if (_attendance?.isOnBreak ?? false) {
        result = await _attendanceService.endBreak();
      } else {
        result = await _attendanceService.startBreak();
      }
      setState(() {
        _attendance = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update break status: $e')),
        );
      }
    }
  }

  String _formatElapsed(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const LoadingWidget(message: 'Loading...')
            : _error != null
                ? ErrorStateWidget(message: _error!, onRetry: _loadAttendance)
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadAttendance,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildTimerCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildTodayTimesheet(),
            const SizedBox(height: 24),
            _buildPayPeriodSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEE, d MMM, yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                dateFormat.format(now),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            ),
            const UserAvatar(name: 'User', size: 40),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${_getGreeting()}!',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'The clock is ticking...',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCard() {
    final totalToday = _attendance?.totalWorkedToday ?? Duration.zero;
    final totalPeriod = _attendance?.totalWorkedPeriod ?? Duration.zero;
    
    final todayHours = totalToday.inHours.toString().padLeft(2, '0');
    final todayMinutes = (totalToday.inMinutes % 60).toString().padLeft(2, '0');
    final periodHours = totalPeriod.inHours.toString().padLeft(2, '0');
    final periodMinutes = (totalPeriod.inMinutes % 60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _formatElapsed(_elapsedTime),
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'monospace',
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSummaryPill('$todayHours:$todayMinutes Hrs Today'),
              const SizedBox(width: 12),
              _buildSummaryPill('$periodHours:$periodMinutes This Pay Period'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final isClockedIn = _attendance?.isClockedIn ?? false;
    final isOnBreak = _attendance?.isOnBreak ?? false;
    final isClockedOut = _attendance?.isClockedOut ?? false;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isClockedOut ? _clockIn : _toggleBreak,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isOnBreak ? 'End Break' : 'Take a Break',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: isClockedOut ? null : _clockOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: isClockedOut ? AppColors.textHint : AppColors.primary,
              side: BorderSide(
                color: isClockedOut ? AppColors.textHint : AppColors.primary,
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isClockedOut ? 'Clocked Out' : 'Clock Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isClockedOut ? AppColors.textHint : AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTimesheet() {
    final entries = _attendance?.todayEntries ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Timesheet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          _buildEmptyCard()
        else
          ...entries.map((entry) => _buildEntryCard(entry)),
      ],
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(
        child: Text(
          'No entries for today',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(AttendanceEntry entry) {
    Color borderColor;
    IconData icon;
    
    switch (entry.type) {
      case AttendanceEntryType.checkIn:
        borderColor = AppColors.checkInGreen;
        icon = Icons.login;
        break;
      case AttendanceEntryType.breakStart:
      case AttendanceEntryType.breakEnd:
        borderColor = AppColors.breakYellow;
        icon = entry.type == AttendanceEntryType.breakStart ? Icons.pause : Icons.play_arrow;
        break;
      case AttendanceEntryType.checkOut:
        borderColor = AppColors.checkOutRed;
        icon = Icons.logout;
        break;
    }

    final time = DateFormat('HH:mm').format(entry.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: borderColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.typeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (entry.patient != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                entry.patient!.initials,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.patient!.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  entry.patient!.phone ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPayPeriodSummary() {
    final summaries = _attendance?.periodSummary ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Current Pay Period',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (summaries.isEmpty)
          _buildEmptyCard()
        else
          ...summaries.map((summary) => _buildSummaryCard(summary)),
      ],
    );
  }

  Widget _buildSummaryCard(DailySummary summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${summary.formattedCheckIn ?? '--:--'} - ${summary.formattedCheckOut ?? '--:--'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              summary.formattedHours,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
