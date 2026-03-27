import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/components.dart';

class RequestTimeOffScreen extends StatefulWidget {
  const RequestTimeOffScreen({super.key});

  @override
  State<RequestTimeOffScreen> createState() => _RequestTimeOffScreenState();
}

class _RequestTimeOffScreenState extends State<RequestTimeOffScreen> {
  int _selectedTypeIndex = 0;
  final _reasonController = TextEditingController();
  int _characterCount = 0;

  final List<String> _timeOffTypes = [
    'Paid Time Off',
    'Sick Leave',
    'Vacation',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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
              _buildTimeOffTypeSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildTimeOffReasonSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildUploadSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildDateDurationSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildSubmitButton(),
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            'AR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
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

  Widget _buildTimeOffTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Time Off Type'),
        PillButtonRow(
          options: _timeOffTypes,
          selectedIndex: _selectedTypeIndex,
          onSelected: (index) {
            setState(() {
              _selectedTypeIndex = index;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimeOffReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Time Off Reason'),
        CustomTextField(
          hint: 'Enter your reason here...',
          controller: _reasonController,
          maxLines: 5,
          maxLength: 500,
          onChanged: (value) {
            setState(() {
              _characterCount = value.length;
            });
          },
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Attachments'),
        UploadBox(onTap: () {}),
      ],
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
              value: '3 days',
              icon: Icons.access_time,
            ),
            const SizedBox(width: 12),
            DateDurationCard(
              title: 'Date',
              value: '10th - 12th Feb',
              icon: Icons.calendar_today,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return PrimaryButton(
      label: 'Submit Request',
      icon: Icons.arrow_forward,
      onPressed: () {},
    );
  }
}
