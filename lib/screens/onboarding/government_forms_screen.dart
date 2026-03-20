import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class GovernmentFormsScreen extends StatefulWidget {
  const GovernmentFormsScreen({super.key});

  @override
  State<GovernmentFormsScreen> createState() => _GovernmentFormsScreenState();
}

class _GovernmentFormsScreenState extends State<GovernmentFormsScreen> {
  int _currentForm = 0;
  bool _formStatusSaved = false;
  DateTime? _lastSaved;

  final _w4FormKey = GlobalKey<FormState>();
  final _i9FormKey = GlobalKey<FormState>();

  String _w4FilingStatus = 'single';
  int _w4Allowances = 0;
  bool _w4MultipleJobs = false;
  double _w4ExtraWithholding = 0;

  String _i9CitizenshipStatus = 'us_citizen';
  String _i9LastName = '';
  String _i9FirstName = '';
  DateTime? _i9DateOfBirth;

  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedForms();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _loadSavedForms() {
    final onboarding = context.read<OnboardingService>();
    final w4Draft = onboarding.getGovFormDraft('w4');
    final i9Draft = onboarding.getGovFormDraft('i9');

    if (w4Draft != null) {
      setState(() {
        _w4FilingStatus = w4Draft['filing_status'] ?? 'single';
        _w4Allowances = w4Draft['allowances'] ?? 0;
        _w4MultipleJobs = w4Draft['multiple_jobs'] ?? false;
        _w4ExtraWithholding = (w4Draft['extra_withholding'] ?? 0).toDouble();
      });
    }

    if (i9Draft != null) {
      setState(() {
        _i9CitizenshipStatus = i9Draft['citizenship_status'] ?? 'us_citizen';
        _i9LastName = i9Draft['last_name'] ?? '';
        _i9FirstName = i9Draft['first_name'] ?? '';
        if (i9Draft['date_of_birth'] != null) {
          _i9DateOfBirth = DateTime.tryParse(i9Draft['date_of_birth']);
        }
      });
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _saveDraft);
  }

  Future<void> _saveDraft() async {
    final onboarding = context.read<OnboardingService>();
    final formType = _currentForm == 0 ? 'w4' : 'i9';

    if (formType == 'w4') {
      await onboarding.saveGovFormDraft('w4', {
        'filing_status': _w4FilingStatus,
        'allowances': _w4Allowances,
        'multiple_jobs': _w4MultipleJobs,
        'extra_withholding': _w4ExtraWithholding,
      });
    } else {
      await onboarding.saveGovFormDraft('i9', {
        'citizenship_status': _i9CitizenshipStatus,
        'last_name': _i9LastName,
        'first_name': _i9FirstName,
        'date_of_birth': _i9DateOfBirth?.toIso8601String(),
      });
    }

    if (mounted) {
      setState(() {
        _formStatusSaved = true;
        _lastSaved = DateTime.now();
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _formStatusSaved = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingService>(
      builder: (context, onboarding, _) {
        final w4Status = onboarding.getTaskStatus('task-w4');
        final i9Status = onboarding.getTaskStatus('task-i9');
        final isW4Complete = w4Status == TaskStatus.completed;
        final isI9Complete = i9Status == TaskStatus.completed;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _FormTab(
                      label: 'W-4 Form',
                      isSelected: _currentForm == 0,
                      isComplete: isW4Complete,
                      onTap: () => setState(() => _currentForm = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FormTab(
                      label: 'I-9 Form',
                      isSelected: _currentForm == 1,
                      isComplete: isI9Complete,
                      onTap: () => setState(() => _currentForm = 1),
                    ),
                  ),
                ],
              ),
            ),
            if (_formStatusSaved || _lastSaved != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: Colors.green.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Draft saved',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _currentForm == 0
                  ? _buildW4Form(isW4Complete)
                  : _buildI9Form(isI9Complete),
            ),
          ],
        );
      },
    );
  }

  Widget _buildW4Form(bool isReadOnly) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _w4FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'W-4 Employee\'s Withholding Certificate',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (isReadOnly)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Submitted',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This form determines how much federal income tax should be withheld from your paycheck.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Step 1: Filing Status',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...['single', 'married_filing_jointly', 'head_of_household'].map((status) {
                      return RadioListTile<String>(
                        title: Text(_getFilingStatusLabel(status)),
                        value: status,
                        groupValue: _w4FilingStatus,
                        onChanged: isReadOnly
                            ? null
                            : (value) {
                                setState(() => _w4FilingStatus = value!);
                                _scheduleAutoSave();
                              },
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Step 2: Multiple Jobs or Spouse Works',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('I have more than one job or my spouse works'),
                      value: _w4MultipleJobs,
                      onChanged: isReadOnly
                          ? null
                          : (value) {
                              setState(() => _w4MultipleJobs = value!);
                              _scheduleAutoSave();
                            },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Step 3: Claim Dependents',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _w4Allowances,
                      decoration: const InputDecoration(
                        labelText: 'Number of Dependents',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(10, (i) => i)
                          .map((i) => DropdownMenuItem(
                                value: i,
                                child: Text('$i'),
                              ))
                          .toList(),
                      onChanged: isReadOnly
                          ? null
                          : (value) {
                              setState(() => _w4Allowances = value!);
                              _scheduleAutoSave();
                            },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SignatureField(
              label: 'Electronic Signature',
              onChanged: (value) {},
              isRequired: true,
              enabled: !isReadOnly,
            ),
            const SizedBox(height: 16),
            AttestationCheckbox(
              label: 'I certify that I have examined this form and to the best of my knowledge and belief, it is true, correct, and complete.',
              value: true,
              onChanged: (value) {},
              enabled: !isReadOnly,
            ),
            const SizedBox(height: 24),
            if (!isReadOnly)
              ElevatedButton(
                onPressed: () async {
                  if (_w4FormKey.currentState!.validate()) {
                    await _saveDraft();
                    final onboarding = context.read<OnboardingService>();
                    await onboarding.submitGovForm('w4', {
                      'filing_status': _w4FilingStatus,
                      'allowances': _w4Allowances,
                      'multiple_jobs': _w4MultipleJobs,
                    }, 'User Signature', true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Submit W-4 Form'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildI9Form(bool isReadOnly) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _i9FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'I-9 Employment Eligibility Verification',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (isReadOnly)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Submitted',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This form verifies the identity and employment authorization of individuals hired in the United States.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Section 1: Employee Information',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _i9CitizenshipStatus,
                      decoration: const InputDecoration(
                        labelText: 'Citizenship Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'us_citizen', child: Text('U.S. Citizen')),
                        DropdownMenuItem(value: 'noncitizen_national', child: Text('Noncitizen National')),
                        DropdownMenuItem(value: 'lawful_permanent_resident', child: Text('Lawful Permanent Resident')),
                        DropdownMenuItem(value: 'authorized_alien', child: Text('Authorized Alien')),
                      ],
                      onChanged: isReadOnly
                          ? null
                          : (value) {
                              setState(() => _i9CitizenshipStatus = value!);
                              _scheduleAutoSave();
                            },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _i9LastName,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _i9LastName = value;
                              _scheduleAutoSave();
                            },
                            enabled: !isReadOnly,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _i9FirstName,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _i9FirstName = value;
                              _scheduleAutoSave();
                            },
                            enabled: !isReadOnly,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: isReadOnly
                          ? null
                          : () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _i9DateOfBirth ?? DateTime(1990),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _i9DateOfBirth = date);
                                _scheduleAutoSave();
                              }
                            },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _i9DateOfBirth != null
                              ? '${_i9DateOfBirth!.month}/${_i9DateOfBirth!.day}/${_i9DateOfBirth!.year}'
                              : 'Select date',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SignatureField(
              label: 'Electronic Signature',
              onChanged: (value) {},
              isRequired: true,
              enabled: !isReadOnly,
            ),
            const SizedBox(height: 16),
            AttestationCheckbox(
              label: 'I attest, under penalty of perjury, that I am (check one): I am a citizen of the United States, or I am a noncitizen national of the United States, or I am a lawful permanent resident of the United States, or I am an alien authorized to work in the United States.',
              value: true,
              onChanged: (value) {},
              enabled: !isReadOnly,
            ),
            const SizedBox(height: 24),
            if (!isReadOnly)
              ElevatedButton(
                onPressed: () async {
                  if (_i9FormKey.currentState!.validate()) {
                    await _saveDraft();
                    final onboarding = context.read<OnboardingService>();
                    await onboarding.submitGovForm('i9', {
                      'citizenship_status': _i9CitizenshipStatus,
                      'last_name': _i9LastName,
                      'first_name': _i9FirstName,
                      'date_of_birth': _i9DateOfBirth?.toIso8601String(),
                    }, 'User Signature', true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Submit I-9 Form'),
              ),
          ],
        ),
      ),
    );
  }

  String _getFilingStatusLabel(String status) {
    switch (status) {
      case 'single':
        return 'Single or Married filing separately';
      case 'married_filing_jointly':
        return 'Married filing jointly or Qualifying surviving spouse';
      case 'head_of_household':
        return 'Head of household';
      default:
        return status;
    }
  }
}

class _FormTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isComplete;
  final VoidCallback onTap;

  const _FormTab({
    required this.label,
    required this.isSelected,
    required this.isComplete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isComplete) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle,
                size: 16,
                color: isSelected ? Colors.white : Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
