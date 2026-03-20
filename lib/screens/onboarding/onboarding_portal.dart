import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import 'training_videos_screen.dart' as training;
import 'government_forms_screen.dart' as forms;
import 'document_upload_screen.dart' as docs;

class OnboardingPortal extends StatefulWidget {
  const OnboardingPortal({super.key});

  @override
  State<OnboardingPortal> createState() => _OnboardingPortalState();
}

class _OnboardingPortalState extends State<OnboardingPortal> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingService>().loadTasks();
    });
  }

  void _navigateToStep(int step) {
    if (step >= 0 && step <= _getTotalSteps()) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  int _getTotalSteps() => 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Onboarding'),
        actions: [
          Consumer<OnboardingService>(
            builder: (context, onboarding, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${onboarding.completedCount}/${onboarding.tasks.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<OnboardingService>(
        builder: (context, onboarding, _) {
          if (onboarding.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: StepProgressIndicator(
                  currentStep: _currentStep,
                  totalSteps: _getTotalSteps(),
                  stepLabels: const ['Welcome', 'Training', 'Forms', 'Docs'],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ProgressBar(
                  progress: onboarding.progressPercentage,
                  label: 'Overall Progress',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildCurrentStep(onboarding),
              ),
              _buildNavigationButtons(onboarding),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep(OnboardingService onboarding) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep(onboarding);
      case 1:
        return const training.TrainingVideosScreen();
      case 2:
        return const forms.GovernmentFormsScreen();
      case 3:
        return const docs.DocumentUploadScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeStep(OnboardingService onboarding) {
    final task = onboarding.tasks.isNotEmpty ? onboarding.tasks[0] : null;
    final isCompleted = task != null && 
        onboarding.getTaskStatus(task.id) == TaskStatus.completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.waving_hand,
                    size: 64,
                    color: isCompleted ? Colors.green : Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to TimeGrid!',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please complete the onboarding steps below to get started.',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
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
                    'Onboarding Checklist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChecklistItem(
                    'Training Videos',
                    'Watch required training videos',
                    onboarding.getTaskStatus('task-training') == TaskStatus.completed,
                  ),
                  _buildChecklistItem(
                    'Government Forms',
                    'Complete W-4 and I-9 forms',
                    onboarding.getTaskStatus('task-w4') == TaskStatus.completed &&
                        onboarding.getTaskStatus('task-i9') == TaskStatus.completed,
                  ),
                  _buildChecklistItem(
                    'Document Upload',
                    'Upload ID and supporting documents',
                    onboarding.getTaskStatus('task-docs') == TaskStatus.completed,
                  ),
                ],
              ),
            ),
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  onboarding.updateTaskStatus(
                    onboarding.tasks[0].id,
                    TaskStatus.completed,
                  );
                },
                child: const Text('I Acknowledge'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String title, String subtitle, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(OnboardingService onboarding) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _navigateToStep(_currentStep - 1),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < _getTotalSteps()
                  ? () => _navigateToStep(_currentStep + 1)
                  : null,
              child: Text(
                _currentStep < _getTotalSteps() ? 'Next' : 'Complete',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
