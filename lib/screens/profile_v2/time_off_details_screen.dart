import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/components.dart';

class TimeOffDetailsScreen extends StatefulWidget {
  const TimeOffDetailsScreen({super.key});

  @override
  State<TimeOffDetailsScreen> createState() => _TimeOffDetailsScreenState();
}

class _TimeOffDetailsScreenState extends State<TimeOffDetailsScreen> {
  String _status = 'Pending';
  String _type = 'Paid Time Off';
  String _reason = 'Family vacation planned for the long weekend. Will need coverage for the department during my absence.';
  String _submittedDate = 'Feb 5, 2026';
  String _startDate = 'Feb 10, 2026';
  String _endDate = 'Feb 12, 2026';
  String _duration = '3 days';

  Color get _statusColor {
    switch (_status) {
      case 'Approved':
        return AppColors.success;
      case 'Rejected':
        return AppColors.error;
      case 'Pending':
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.lg),
              _buildTitleChip(),
              const SizedBox(height: AppSpacing.lg),
              _buildStatusSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildTypeSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildReasonSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildAttachmentsSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildDateDurationSection(),
              const SizedBox(height: AppSpacing.xl),
              if (_status == 'Pending') _buildActionButtons(),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
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
          'Time Off Details',
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

  Widget _buildTitleChip() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: const Text(
          'Request a Time Off',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return CardContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _status,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _statusColor,
                ),
              ),
            ],
          ),
          StatusBadge(
            label: _status,
            color: _statusColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Time Off Type'),
        CardContainer(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.event_note,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _type,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Reason'),
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _reason,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Submitted on $_submittedDate',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Attachments'),
        CardContainer(
          child: Column(
            children: [
              _buildAttachmentItem(
                icon: Icons.picture_as_pdf,
                name: 'Travel_itinerary.pdf',
                size: '2.4 MB',
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              _buildAttachmentItem(
                icon: Icons.image,
                name: 'Hotel_confirmation.jpg',
                size: '1.8 MB',
                color: AppColors.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required String name,
    required String size,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  size,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.download_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDateDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Date & Duration'),
        Row(
          children: [
            DateDurationCard(
              title: 'Duration',
              value: _duration,
              icon: Icons.access_time,
            ),
            const SizedBox(width: 12),
            DateDurationCard(
              title: 'Start Date',
              value: _startDate,
              icon: Icons.calendar_today,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            DateDurationCard(
              title: 'End Date',
              value: _endDate,
              icon: Icons.event,
            ),
            const SizedBox(width: 12),
            DateDurationCard(
              title: 'Submitted',
              value: _submittedDate,
              icon: Icons.schedule,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedPillButton(
            label: 'Cancel Request',
            icon: Icons.close,
            borderColor: AppColors.error,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cancel Request'),
                  content: const Text('Are you sure you want to cancel this time off request?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _status = 'Cancelled';
                        });
                      },
                      child: Text(
                        'Yes, Cancel',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
