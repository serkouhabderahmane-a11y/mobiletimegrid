import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../../widgets/animations.dart';

class TimeClockScreen extends StatefulWidget {
  const TimeClockScreen({super.key});

  @override
  State<TimeClockScreen> createState() => _TimeClockScreenState();
}

class _TimeClockScreenState extends State<TimeClockScreen>
    with TickerProviderStateMixin {
  Timer? _clockTimer;
  String? _selectedJobCode;
  final _notesController = TextEditingController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimeClockService>().loadEntries();
    });
    _startClockTimer();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _notesController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startClockTimer() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String _getCurrentTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  String _getCurrentDate() {
    return DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor.withValues(alpha: 0.1),
                      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Consumer<TimeClockService>(
                    builder: (context, timeClock, _) {
                      return _buildCurrentTimeCard(timeClock, isDark, primaryColor);
                    },
                  ),
                ),
              ),
            ),
            title: Text(
              'Time Clock',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: AnimatedIconButton(
              icon: Icons.arrow_back_rounded,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SlideFadeTransition(
                    child: _buildClockActionCard(context.read<TimeClockService>()),
                  ),
                  const SizedBox(height: 24),
                  SlideFadeTransition(
                    delay: const Duration(milliseconds: 200),
                    child: _buildRecentEntries(context.read<TimeClockService>()),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeCard(
    TimeClockService timeClock,
    bool isDark,
    Color primaryColor,
  ) {
    final isClockedIn = timeClock.isClockedIn;
    final statusColor = isClockedIn ? const Color(0xFF10B981) : Colors.grey;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          _getCurrentDate(),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                if (!isClockedIn) return const SizedBox.shrink();
                return Container(
                  width: 200 * _pulseAnimation.value,
                  height: 200 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  ),
                );
              },
            ),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (isClockedIn ? const Color(0xFF10B981) : primaryColor)
                        .withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getCurrentTime(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: primaryColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isClockedIn ? 'WORKING' : 'OFF DUTY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isClockedIn
                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isClockedIn
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: isClockedIn
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isClockedIn ? 'Clocked In' : 'Clocked Out',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClockActionCard(TimeClockService timeClock) {
    final isClockedIn = timeClock.isClockedIn;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedCard(
      useGlassmorphism: true,
      gradientColors: [
        isDark ? const Color(0xFF334155) : Colors.white,
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (timeClock.config.requireJobCode ||
              timeClock.config.availableJobCodes.isNotEmpty) ...[
            _buildInputLabel('Job Code (Optional)'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedJobCode,
                decoration: const InputDecoration(
                  labelText: null,
                  hintText: 'Select job code',
                  prefixIcon: Icon(Icons.work_outline_rounded),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No Job Code')),
                  ...timeClock.config.availableJobCodes.map((code) {
                    return DropdownMenuItem(value: code, child: Text(code));
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedJobCode = value);
                },
              ),
            ),
          ],
          if (timeClock.config.requireNotes) ...[
            const SizedBox(height: 16),
            _buildInputLabel('Notes'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add notes...',
                prefixIcon: const Icon(Icons.notes_rounded),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          AnimatedButton(
            onPressed: timeClock.isLoading
                ? null
                : () => isClockedIn
                    ? _handleClockOut(timeClock)
                    : _handleClockIn(timeClock),
            gradientColors: isClockedIn
                ? [Colors.red.shade400, Colors.red.shade600]
                : [const Color(0xFF10B981), const Color(0xFF059669)],
            borderRadius: BorderRadius.circular(16),
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (timeClock.isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else ...[
                  Icon(
                    isClockedIn ? Icons.stop_circle_rounded : Icons.play_circle_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isClockedIn ? 'CLOCK OUT' : 'CLOCK IN',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isClockedIn) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Started at ${DateFormat('HH:mm').format(timeClock.activeEntry!.clockIn)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Future<void> _handleClockIn(TimeClockService timeClock) async {
    final success = await timeClock.clockIn(
      jobCode: _selectedJobCode,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (success && mounted) {
      _showSuccessSnackBar('Clocked in successfully');
      _notesController.clear();
    }
  }

  Future<void> _handleClockOut(TimeClockService timeClock) async {
    final success = await timeClock.clockOut(
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (success && mounted) {
      _showSuccessSnackBar('Clocked out successfully');
      _notesController.clear();
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildRecentEntries(TimeClockService timeClock) {
    final recentEntries = timeClock.entries.take(10).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Time Entries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentEntries.isEmpty)
          AnimatedCard(
            useGlassmorphism: true,
            gradientColors: [
              isDark ? const Color(0xFF334155) : Colors.white,
              isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            ],
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No time entries yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...recentEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return StaggeredListItem(
              index: index,
              child: _buildEntryCard(item, isDark),
            );
          }),
      ],
    );
  }

  Widget _buildEntryCard(TimeEntry entry, bool isDark) {
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('HH:mm');
    final isActive = entry.isClockedIn;

    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 10),
      useGlassmorphism: true,
      gradientColors: [
        isDark ? const Color(0xFF334155) : Colors.white,
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateFormat.format(entry.clockIn).substring(0, 3),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isActive
                          ? const Color(0xFF10B981)
                          : (isDark ? Colors.grey.shade300 : Colors.grey.shade600),
                    ),
                  ),
                  Text(
                    dateFormat.format(entry.clockIn).substring(4),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isActive
                          ? const Color(0xFF10B981)
                          : (isDark ? Colors.white : const Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(entry.clockIn),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.login_rounded,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeFormat.format(entry.clockIn),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_right_alt_rounded,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.clockOut != null
                                  ? timeFormat.format(entry.clockOut!)
                                  : 'Now',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (entry.jobCode != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.jobCode!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.formattedDuration,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
