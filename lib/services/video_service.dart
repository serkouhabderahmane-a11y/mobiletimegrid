import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'auth_service.dart';

class VideoService extends ChangeNotifier {
  static const String _progressKey = 'video_progress';

  final AuthService _authService;

  List<TrainingVideo> _videos = [];
  Map<String, VideoProgress> _progress = {};
  bool _isLoading = false;
  String? _error;

  VideoService(this._authService);

  List<TrainingVideo> get videos => _videos;
  Map<String, VideoProgress> get progress => _progress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get watchedCount => _progress.values.where((p) => p.isCompleted).length;
  
  double get progressPercentage {
    if (_videos.isEmpty) return 0.0;
    return watchedCount / _videos.length;
  }

  Future<void> loadVideos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_authService.token == null || _authService.token!.startsWith('demo-')) {
        _videos = _getDemoVideos();
      } else {
        final response = await _authService.api.get('/onboarding/training-videos');
        _videos = (response['videos'] as List?)
                ?.map((v) => TrainingVideo.fromJson(v))
                .toList() ??
            [];
      }

      await _loadProgress();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _videos = _getDemoVideos();
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _authService.currentUser?.id ?? 'demo-user';
    final progressJson = prefs.getString('${_progressKey}_$userId');

    if (progressJson != null) {
      try {
        final parts = progressJson.split(';');
        for (final part in parts) {
          final kv = part.split('=');
          if (kv.length == 3) {
            _progress[kv[0]] = VideoProgress(
              id: kv[0],
              videoId: kv[0],
              userId: userId,
              watchedSeconds: int.tryParse(kv[1]) ?? 0,
              isCompleted: kv[2] == '1',
              updatedAt: DateTime.now(),
            );
          }
        }
      } catch (_) {}
    }
  }

  List<TrainingVideo> _getDemoVideos() {
    return [
      TrainingVideo(
        id: 'demo-video-001',
        tenantId: 'demo-tenant',
        title: 'Workplace Safety Basics',
        description: 'Learn essential workplace safety practices and procedures.',
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
        thumbnailUrl: null,
        durationSeconds: 120,
        taskId: 'task-training',
        createdAt: DateTime.now(),
      ),
      TrainingVideo(
        id: 'demo-video-002',
        tenantId: 'demo-tenant',
        title: 'Anti-Harassment Training',
        description: 'Understanding workplace harassment policies and prevention.',
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
        thumbnailUrl: null,
        durationSeconds: 300,
        taskId: 'task-training',
        createdAt: DateTime.now(),
      ),
      TrainingVideo(
        id: 'demo-video-003',
        tenantId: 'demo-tenant',
        title: 'Time Tracking System Tutorial',
        description: 'How to use the TimeGrid time tracking system.',
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
        thumbnailUrl: null,
        durationSeconds: 180,
        taskId: 'task-training',
        createdAt: DateTime.now(),
      ),
    ];
  }

  bool isVideoCompleted(String videoId) {
    return _progress[videoId]?.isCompleted ?? false;
  }

  Future<void> markVideoProgress(String videoId, int watchedSeconds) async {
    final userId = _authService.currentUser?.id ?? 'demo-user';
    final video = _videos.firstWhere((v) => v.id == videoId);
    final isCompleted = watchedSeconds >= video.durationSeconds * 0.9;

    _progress[videoId] = VideoProgress(
      id: videoId,
      videoId: videoId,
      userId: userId,
      watchedSeconds: watchedSeconds,
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final progressString = _progress.entries
        .map((e) => '${e.key}=${e.value.watchedSeconds}=${e.value.isCompleted ? 1 : 0}')
        .join(';');
    await prefs.setString('${_progressKey}_$userId', progressString);

    if (_authService.token == null || _authService.token!.startsWith('demo-')) {
    } else {
      try {
        await _authService.api.post('/onboarding/training-videos/progress', body: {
          'video_id': videoId,
          'watched_seconds': watchedSeconds,
          'is_completed': isCompleted,
        });
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> markVideoCompleted(String videoId) async {
    await markVideoProgress(videoId, _videos.firstWhere((v) => v.id == videoId).durationSeconds);
  }
}
