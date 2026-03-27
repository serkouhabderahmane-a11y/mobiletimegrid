import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/components.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  int _selectedTypeIndex = 0;
  final _summaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedDropdown = 'Health';

  final List<String> _documentTypes = [
    'Progress note',
    'Medication',
    'Others',
  ];

  @override
  void dispose() {
    _summaryController.dispose();
    _descriptionController.dispose();
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
              _buildTitle(),
              const SizedBox(height: AppSpacing.lg),
              _buildDocumentTypeSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildPatientRow(),
              const SizedBox(height: AppSpacing.lg),
              _buildTypeDropdown(),
              const SizedBox(height: AppSpacing.lg),
              _buildSummaryField(),
              const SizedBox(height: AppSpacing.lg),
              _buildDescriptionField(),
              const SizedBox(height: AppSpacing.lg),
              _buildUploadSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildDateTimeSection(),
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
      ],
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Add document',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDocumentTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Document type'),
        PillButtonRow(
          options: _documentTypes,
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

  Widget _buildPatientRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Entered by',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        'C',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Chriss',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Patient',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        'J',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'John',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Type'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDropdown,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: ['Health', 'Personal', 'Work'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDropdown = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Summary'),
        CustomTextField(
          hint: 'Enter summary...',
          controller: _summaryController,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Description'),
        CustomTextField(
          hint: 'Enter description...',
          controller: _descriptionController,
          maxLines: 5,
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

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Date & Time'),
        Row(
          children: [
            DateDurationCard(
              title: 'Time',
              value: '10:30 AM',
              icon: Icons.access_time,
            ),
            const SizedBox(width: 12),
            DateDurationCard(
              title: 'Date',
              value: '15 Feb 2025',
              icon: Icons.calendar_today,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return PrimaryButton(
      label: 'Submit',
      icon: Icons.arrow_forward,
      onPressed: () {},
    );
  }
}
