import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../../widgets/animations.dart';
import 'training_videos_screen.dart' as training;
import 'government_forms_screen.dart' as forms;
import 'document_upload_screen.dart' as docs;

class OnboardingPortal extends StatefulWidget {
  const OnboardingPortal({super.key});

  @override
  State<OnboardingPortal> createState() => _OnboardingPortalState();
}

class _OnboardingPortalState extends State<OnboardingPortal>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _stepAnimationController;
  late Animation<double> _stepFadeAnimation;

  @override
  void initState() {
    super.initState();
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _stepFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _stepAnimationController,
        curve: Curves.easeOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingService>().loadTasks();
    });
    _stepAnimationController.forward();
  }

  @override
  void dispose() {
    _stepAnimationController.dispose();
    super.dispose();
  }

  void _navigateToStep(int step) {
    if (step >= 0 && step <= _getTotalSteps()) {
      _stepAnimationController.reverse().then((_) {
        setState(() {
          _currentStep = step;
        });
        _stepAnimationController.forward();
      });
    }
  }

  int _getTotalSteps() => 4;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark, primaryColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<OnboardingService>(
                  builder: (context, onboarding, _) {
                    return Column(
                      children: [
                        AnimatedStepProgressIndicator(
                          currentStep: _currentStep,
                          totalSteps: _getTotalSteps(),
                          stepLabels: const ['Welcome', 'Training', 'Forms', 'Docs'],
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 16),
                        AnimatedProgressBar(
                          progress: onboarding.progressPercentage,
                          height: 8,
                          gradientColors: [
                            primaryColor,
                            primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Progress',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '${onboarding.completedCount}/${onboarding.tasks.length} completed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<OnboardingService>(
                  builder: (context, onboarding, _) {
                    if (onboarding.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return AnimatedBuilder(
                      animation: _stepAnimationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _stepFadeAnimation,
                          child: _buildCurrentStep(onboarding),
                        );
                      },
                    );
                  },
                ),
              ),
              _buildNavigationButtons(primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          AnimatedIconButton(
            icon: Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Employee Onboarding',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Complete all steps to get started',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Consumer<OnboardingService>(
            builder: (context, onboarding, _) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${onboarding.completedCount}/${onboarding.tasks.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              );
            },
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SlideFadeTransition(
            child: AnimatedCard(
              useGlassmorphism: true,
              gradientColors: isCompleted
                  ? [
                      const Color(0xFF10B981).withValues(alpha: 0.1),
                      const Color(0xFF10B981).withValues(alpha: 0.05),
                    ]
                  : [
                      primaryColor.withValues(alpha: 0.1),
                      primaryColor.withValues(alpha: 0.05),
                    ],
              child: Column(
                children: [
                  FloatingWidget(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : primaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_circle_rounded : Icons.waving_hand_rounded,
                        size: 40,
                        color: isCompleted
                            ? const Color(0xFF10B981)
                            : primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to TimeGrid!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please complete the onboarding steps below to get started with your new role.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SlideFadeTransition(
            delay: const Duration(milliseconds: 100),
            child: AnimatedCard(
              useGlassmorphism: true,
              gradientColors: [
                isDark ? const Color(0xFF334155) : Colors.white,
                isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.checklist_rounded,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Onboarding Checklist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildChecklistItem(
                    icon: Icons.play_circle_rounded,
                    title: 'Training Videos',
                    subtitle: 'Watch required training videos',
                    isCompleted: onboarding.getTaskStatus('task-training') == TaskStatus.completed,
                    color: const Color(0xFF6366F1),
                    onTap: () => _navigateToStep(1),
                  ),
                  _buildChecklistItem(
                    icon: Icons.description_rounded,
                    title: 'Government Forms',
                    subtitle: 'Complete W-4 and I-9 forms',
                    isCompleted: onboarding.getTaskStatus('task-w4') == TaskStatus.completed &&
                        onboarding.getTaskStatus('task-i9') == TaskStatus.completed,
                    color: const Color(0xFF10B981),
                    onTap: () => _navigateToStep(2),
                  ),
                  _buildChecklistItem(
                    icon: Icons.upload_file_rounded,
                    title: 'Document Upload',
                    subtitle: 'Upload ID and supporting documents',
                    isCompleted: onboarding.getTaskStatus('task-docs') == TaskStatus.completed,
                    color: const Color(0xFFF59E0B),
                    onTap: () => _navigateToStep(3),
                  ),
                ],
              ),
            ),
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 24),
            SlideFadeTransition(
              delay: const Duration(milliseconds: 200),
              child: AnimatedButton(
                onPressed: () {
                  onboarding.updateTaskStatus(
                    onboarding.tasks[0].id,
                    TaskStatus.completed,
                  );
                },
                gradientColors: [
                  primaryColor,
                  primaryColor.withValues(alpha: 0.8),
                ],
                borderRadius: BorderRadius.circular(14),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I Acknowledge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildChecklistItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF10B981).withValues(alpha: 0.08)
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.chevron_right_rounded,
                  color: isCompleted ? const Color(0xFF10B981) : Colors.grey.shade400,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: AnimatedCard(
                onTap: () => _navigateToStep(_currentStep - 1),
                gradientColors: [
                  Colors.grey.shade200,
                  Colors.grey.shade300,
                ],
                borderRadius: BorderRadius.circular(14),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_rounded,
                        color: Color(0xFF1E293B), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Previous',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AnimatedButton(
              onPressed: _currentStep < _getTotalSteps()
                  ? () => _navigateToStep(_currentStep + 1)
                  : null,
              gradientColors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.8),
              ],
              borderRadius: BorderRadius.circular(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentStep < _getTotalSteps() ? 'Next Step' : 'Complete',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentStep < _getTotalSteps()
                        ? Icons.arrow_forward_rounded
                        : Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedStepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;
  final Color primaryColor;

  const AnimatedStepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isOdd) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 3,
                  decoration: BoxDecoration(
                    color: index ~/ 2 < currentStep
                        ? primaryColor
                        : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            final isCurrent = stepIndex == currentStep;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCurrent ? 40 : 32,
              height: isCurrent ? 40 : 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isCurrent
                    ? primaryColor
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: isCurrent ? 14 : 12,
                        ),
                      ),
              ),
            );
          }),
        ),
        if (stepLabels != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stepLabels!
                .take(totalSteps)
                .map((label) => Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
