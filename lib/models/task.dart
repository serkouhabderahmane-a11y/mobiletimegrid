enum TaskType {
  trainingVideo,
  governmentForm,
  documentUpload,
  acknowledgment,
  other,
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  skipped,
}

class OnboardingTask {
  final String id;
  final String tenantId;
  final String taskType;
  final String title;
  final String? description;
  final int orderIndex;
  final bool isRequired;
  final String? linkedVideoId;
  final String? linkedFormId;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;

  OnboardingTask({
    required this.id,
    required this.tenantId,
    required this.taskType,
    required this.title,
    this.description,
    required this.orderIndex,
    this.isRequired = true,
    this.linkedVideoId,
    this.linkedFormId,
    this.settings,
    required this.createdAt,
  });

  TaskType get type {
    switch (taskType.toLowerCase()) {
      case 'training_video':
      case 'trainingacknowledgment':
        return TaskType.trainingVideo;
      case 'government_form':
      case 'governmentforms':
        return TaskType.governmentForm;
      case 'document_upload':
      case 'documentupload':
        return TaskType.documentUpload;
      case 'acknowledgment':
        return TaskType.acknowledgment;
      default:
        return TaskType.other;
    }
  }

  factory OnboardingTask.fromJson(Map<String, dynamic> json) {
    return OnboardingTask(
      id: json['id'] ?? '',
      tenantId: json['tenant_id'] ?? json['tenantId'] ?? '',
      taskType: json['task_type'] ?? json['taskType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      orderIndex: json['order_index'] ?? json['orderIndex'] ?? 0,
      isRequired: json['is_required'] ?? json['isRequired'] ?? true,
      linkedVideoId: json['linked_video_id'] ?? json['linkedVideoId'],
      linkedFormId: json['linked_form_id'] ?? json['linkedFormId'],
      settings: json['settings'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'task_type': taskType,
      'title': title,
      'description': description,
      'order_index': orderIndex,
      'is_required': isRequired,
      'linked_video_id': linkedVideoId,
      'linked_form_id': linkedFormId,
      'settings': settings,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserTaskStatus {
  final String id;
  final String userId;
  final String taskId;
  final String status;
  final DateTime? completedAt;
  final Map<String, dynamic>? completionData;
  final DateTime updatedAt;

  UserTaskStatus({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.status,
    this.completedAt,
    this.completionData,
    required this.updatedAt,
  });

  TaskStatus get taskStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return TaskStatus.pending;
      case 'in_progress':
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'skipped':
        return TaskStatus.skipped;
      default:
        return TaskStatus.pending;
    }
  }

  factory UserTaskStatus.fromJson(Map<String, dynamic> json) {
    return UserTaskStatus(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      taskId: json['task_id'] ?? json['taskId'] ?? '',
      status: json['status'] ?? 'pending',
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      completionData: json['completion_data'] ?? json['completionData'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'task_id': taskId,
      'status': status,
      'completed_at': completedAt?.toIso8601String(),
      'completion_data': completionData,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
