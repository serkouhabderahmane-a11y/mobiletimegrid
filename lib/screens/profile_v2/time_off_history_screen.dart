import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/components.dart';

class TimeOffHistoryScreen extends StatefulWidget {
  const TimeOffHistoryScreen({super.key});

  @override
  State<TimeOffHistoryScreen> createState() => _TimeOffHistoryScreenState();
}

class _TimeOffHistoryScreenState extends State<TimeOffHistoryScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = ['All', 'Approved', 'Pending', 'Rejected'];

  final List<Map<String, dynamic>> _timeOffRequests = [
    {
      'type': 'Paid Time Off',
      'reason': 'Family vacation planned for the long weekend',
      'startDate': 'Feb 10, 2026',
      'endDate': 'Feb 12, 2026',
      'duration': '3 days',
      'status': 'Pending',
      'submittedDate': 'Feb 5, 2026',
    },
    {
      'type': 'Sick Leave',
      'reason': 'Doctor appointment and recovery time',
      'startDate': 'Jan 28, 2026',
      'endDate': 'Jan 28, 2026',
      'duration': '1 day',
      'status': 'Approved',
      'submittedDate': 'Jan 25, 2026',
    },
    {
      'type': 'Vacation',
      'reason': 'Annual holiday trip',
      'startDate': 'Jan 15, 2026',
      'endDate': 'Jan 20, 2026',
      'duration': '6 days',
      'status': 'Approved',
      'submittedDate': 'Jan 5, 2026',
    },
    {
      'type': 'Paid Time Off',
      'reason': 'Personal matters requiring time off',
      'startDate': 'Dec 20, 2025',
      'endDate': 'Dec 22, 2025',
      'duration': '3 days',
      'status': 'Rejected',
      'submittedDate': 'Dec 10, 2025',
    },
    {
      'type': 'Sick Leave',
      'reason': 'Feeling unwell, need rest',
      'startDate': 'Dec 5, 2025',
      'endDate': 'Dec 6, 2025',
      'duration': '2 days',
      'status': 'Approved',
      'submittedDate': 'Dec 4, 2025',
    },
  ];

  List<Map<String, dynamic>> get _filteredRequests {
    if (_selectedFilterIndex == 0) {
      return _timeOffRequests;
    }
    return _timeOffRequests
        .where((r) => r['status'] == _filters[_selectedFilterIndex])
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return AppColors.success;
      case 'Rejected':
        return AppColors.error;
      case 'Pending':
      default:
        return AppColors.warning;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'Pending':
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFilterSection(),
                ],
              ),
            ),
            Expanded(
              child: _filteredRequests.isEmpty
                  ? _buildEmptyState()
                  : _buildRequestList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Spacer(),
        const Text(
          'Time Off History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index < _filters.length - 1 ? 12 : 0),
            child: PillButton(
              label: _filters[index],
              isSelected: _selectedFilterIndex == index,
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_filters[_selectedFilterIndex]} requests',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: _filteredRequests.length,
      itemBuilder: (context, index) {
        final request = _filteredRequests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRequestCard(request),
        );
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final statusColor = _getStatusColor(request['status']);
    final statusIcon = _getStatusIcon(request['status']);

    return CardContainer(
      onTap: () {
        Navigator.pushNamed(context, '/time-off-details');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request['type'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge(
                label: request['status'],
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request['reason'],
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.calendar_today,
                label: '${request['startDate']} - ${request['endDate']}',
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.access_time,
                label: request['duration'],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Submitted ${request['submittedDate']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    statusIcon,
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
