class TrainingVideo {
  final String id;
  final String tenantId;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int durationSeconds;
  final String? taskId;
  final DateTime createdAt;

  TrainingVideo({
    required this.id,
    required this.tenantId,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.durationSeconds,
    this.taskId,
    required this.createdAt,
  });

  factory TrainingVideo.fromJson(Map<String, dynamic> json) {
    return TrainingVideo(
      id: json['id'] ?? '',
      tenantId: json['tenant_id'] ?? json['tenantId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      videoUrl: json['video_url'] ?? json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      durationSeconds: json['duration_seconds'] ?? json['durationSeconds'] ?? 0,
      taskId: json['task_id'] ?? json['taskId'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'duration_seconds': durationSeconds,
      'task_id': taskId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class VideoProgress {
  final String id;
  final String videoId;
  final String userId;
  final int watchedSeconds;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime updatedAt;

  VideoProgress({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.watchedSeconds,
    required this.isCompleted,
    this.completedAt,
    required this.updatedAt,
  });

  factory VideoProgress.fromJson(Map<String, dynamic> json) {
    return VideoProgress(
      id: json['id'] ?? '',
      videoId: json['video_id'] ?? json['videoId'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      watchedSeconds: json['watched_seconds'] ?? json['watchedSeconds'] ?? 0,
      isCompleted: json['is_completed'] ?? json['isCompleted'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_id': videoId,
      'user_id': userId,
      'watched_seconds': watchedSeconds,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
