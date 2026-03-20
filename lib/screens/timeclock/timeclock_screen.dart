import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class TimeClockScreen extends StatefulWidget {
  const TimeClockScreen({super.key});

  @override
  State<TimeClockScreen> createState() => _TimeClockScreenState();
}

class _TimeClockScreenState extends State<TimeClockScreen> {
  Timer? _clockTimer;
  String? _selectedJobCode;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimeClockService>().loadEntries();
    });
    _startClockTimer();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _notesController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Clock'),
      ),
      body: Consumer<TimeClockService>(
        builder: (context, timeClock, _) {
          if (timeClock.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildCurrentTimeCard(timeClock),
              _buildClockActionCard(timeClock),
              const SizedBox(height: 16),
              Expanded(
                child: _buildRecentEntries(timeClock),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentTimeCard(TimeClockService timeClock) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Column(
        children: [
          Text(
            _getCurrentDate(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getCurrentTime(),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          if (timeClock.isClockedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Clocked In',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle_outlined, size: 12, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Clocked Out',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClockActionCard(TimeClockService timeClock) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (timeClock.config.requireJobCode ||
              timeClock.config.availableJobCodes.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _selectedJobCode,
              decoration: const InputDecoration(
                labelText: 'Job Code (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work_outline),
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
          if (timeClock.config.requireNotes) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: timeClock.isLoading
                  ? null
                  : () => timeClock.isClockedIn
                      ? _handleClockOut(timeClock)
                      : _handleClockIn(timeClock),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    timeClock.isClockedIn ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: Icon(
                timeClock.isClockedIn ? Icons.stop : Icons.play_arrow,
                size: 28,
              ),
              label: Text(
                timeClock.isClockedIn ? 'CLOCK OUT' : 'CLOCK IN',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (timeClock.isClockedIn) ...[
            const SizedBox(height: 8),
            Text(
              'Started at ${DateFormat('HH:mm').format(timeClock.activeEntry!.clockIn)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleClockIn(TimeClockService timeClock) async {
    final success = await timeClock.clockIn(
      jobCode: _selectedJobCode,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clocked in successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _notesController.clear();
    }
  }

  Future<void> _handleClockOut(TimeClockService timeClock) async {
    final success = await timeClock.clockOut(
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clocked out successfully'),
          backgroundColor: Colors.blue,
        ),
      );
      _notesController.clear();
    }
  }

  Widget _buildRecentEntries(TimeClockService timeClock) {
    final recentEntries = timeClock.entries.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Time Entries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recentEntries.length,
            itemBuilder: (context, index) {
              final entry = recentEntries[index];
              return _buildEntryCard(entry);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(TimeEntry entry) {
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: entry.isClockedIn
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  dateFormat.format(entry.clockIn).substring(0, 3),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: entry.isClockedIn
                        ? Colors.green.shade700
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(entry.clockIn),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        timeFormat.format(entry.clockIn),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Text(' - '),
                      Text(
                        entry.clockOut != null
                            ? timeFormat.format(entry.clockOut!)
                            : 'Now',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (entry.jobCode != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            entry.jobCode!,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.formattedDuration,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (entry.isClockedIn)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                      ),
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
