import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'auth_service.dart';

class OnboardingService extends ChangeNotifier {
  static const String _tasksKey = 'onboarding_tasks';
  static const String _taskStatusKey = 'task_status';
  static const String _draftsKey = 'gov_forms_drafts';
  static const String _snapshotsKey = 'gov_forms_snapshots';

  final AuthService _authService;

  List<OnboardingTask> _tasks = [];
  Map<String, UserTaskStatus> _taskStatuses = {};
  bool _isLoading = false;
  String? _error;

  OnboardingService(this._authService);

  List<OnboardingTask> get tasks => _tasks;
  Map<String, UserTaskStatus> get taskStatuses => _taskStatuses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get completedCount => _taskStatuses.values
      .where((s) => s.taskStatus == TaskStatus.completed)
      .length;

  double get progressPercentage {
    if (_tasks.isEmpty) return 0.0;
    return completedCount / _tasks.length;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_authService.token == null || _authService.token!.startsWith('demo-')) {
        _tasks = _getDemoTasks();
      } else {
        final response = await _authService.api.get('/onboarding/tasks');
        _tasks = (response['tasks'] as List?)
                ?.map((t) => OnboardingTask.fromJson(t))
                .toList() ??
            [];
      }

      await _loadTaskStatuses();
      await _loadDrafts();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _tasks = _getDemoTasks();
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _loadTaskStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    final statusesJson = prefs.getString('${_taskStatusKey}_${_authService.currentUser?.id}');
    
    if (statusesJson != null) {
      try {
        final Map<String, dynamic> decoded = {};
        statusesJson.split(';').forEach((pair) {
          final parts = pair.split('=');
          if (parts.length == 2) {
            decoded[parts[0]] = parts[1];
          }
        });
      } catch (_) {}
    }
  }

  Future<void> _loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getString('${_draftsKey}_${_authService.currentUser?.id}');
    
    if (draftsJson != null) {
      try {
        final Map<String, dynamic> decoded = {};
        draftsJson.split(';').forEach((pair) {
          final parts = pair.split('=');
          if (parts.length == 2) {
            decoded[parts[0]] = parts[1];
          }
        });
      } catch (_) {}
    }
  }

  List<OnboardingTask> _getDemoTasks() {
    return [
      OnboardingTask(
        id: 'task-welcome',
        tenantId: 'demo-tenant',
        taskType: 'acknowledgment',
        title: 'Welcome to TimeGrid',
        description: 'Review and acknowledge company policies',
        orderIndex: 0,
        isRequired: true,
        createdAt: DateTime.now(),
      ),
      OnboardingTask(
        id: 'task-training',
        tenantId: 'demo-tenant',
        taskType: 'training_video',
        title: 'Training Videos',
        description: 'Watch required training videos',
        orderIndex: 1,
        isRequired: true,
        createdAt: DateTime.now(),
      ),
      OnboardingTask(
        id: 'task-w4',
        tenantId: 'demo-tenant',
        taskType: 'government_form',
        title: 'W-4 Tax Form',
        description: 'Complete your federal tax withholding form',
        orderIndex: 2,
        isRequired: true,
        createdAt: DateTime.now(),
      ),
      OnboardingTask(
        id: 'task-i9',
        tenantId: 'demo-tenant',
        taskType: 'government_form',
        title: 'I-9 Employment Eligibility',
        description: 'Verify your employment eligibility',
        orderIndex: 3,
        isRequired: true,
        createdAt: DateTime.now(),
      ),
      OnboardingTask(
        id: 'task-docs',
        tenantId: 'demo-tenant',
        taskType: 'document_upload',
        title: 'Document Upload',
        description: 'Upload required identification documents',
        orderIndex: 4,
        isRequired: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status, {Map<String, dynamic>? data}) async {
    final userId = _authService.currentUser?.id ?? 'demo-user';
    
    _taskStatuses[taskId] = UserTaskStatus(
      id: '${taskId}_$userId',
      userId: userId,
      taskId: taskId,
      status: status.name,
      completionData: data,
      completedAt: status == TaskStatus.completed ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final statusesString = _taskStatuses.entries
        .map((e) => '${e.key}=${e.value.status}')
        .join(';');
    await prefs.setString('${_taskStatusKey}_$userId', statusesString);

    if (_authService.token == null || _authService.token!.startsWith('demo-')) {
    } else {
      try {
        await _authService.api.put('/onboarding/tasks/$taskId/status', body: {
          'status': status.name,
          'completion_data': data,
        });
      } catch (_) {}
    }

    notifyListeners();
  }

  TaskStatus getTaskStatus(String taskId) {
    return _taskStatuses[taskId]?.taskStatus ?? TaskStatus.pending;
  }

  Future<void> saveGovFormDraft(String formType, Map<String, dynamic> data) async {
    final userId = _authService.currentUser?.id ?? 'demo-user';
    final prefs = await SharedPreferences.getInstance();
    
    final draftsString = data.entries
        .map((e) => '${e.key}=${e.value}')
        .join(';');
    await prefs.setString('${_draftsKey}_${userId}_$formType', draftsString);

    notifyListeners();
  }

  Map<String, dynamic>? getGovFormDraft(String formType) {
    final userId = _authService.currentUser?.id ?? 'demo-user';
    return null;
  }

  Future<void> submitGovForm(String formType, Map<String, dynamic> data, String signedName, bool attestation) async {
    final userId = _authService.currentUser?.id ?? 'demo-user';

    if (_authService.token == null || _authService.token!.startsWith('demo-')) {
      await updateTaskStatus('task-$formType', TaskStatus.completed, data: {
        'signed_name': signedName,
        'attestation': attestation,
        'submitted_at': DateTime.now().toIso8601String(),
      });
    } else {
      try {
        await _authService.api.post('/onboarding/gov-forms/submit', body: {
          'form_type': formType,
          'form_data': data,
          'signed_name': signedName,
          'attestation_agreed': attestation,
        });
      } catch (_) {}
    }

    notifyListeners();
  }
}
