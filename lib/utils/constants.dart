class Constants {
  static const String appName = 'TimeGrid';
  static const String appVersion = '1.0.0';
  
  static const String apiBaseUrl = 'http://localhost:8000/api';
  
  static const Duration apiTimeout = Duration(seconds: 30);
  
  static const String authTokenKey = 'auth_token';
  static const String userKey = 'auth_user';
  static const String tenantKey = 'auth_tenant';
  
  static const String onboardingTasksKey = 'onboarding_tasks';
  static const String taskStatusKey = 'task_status';
  static const String govFormsDraftsKey = 'gov_forms_drafts';
  static const String govFormsSnapshotsKey = 'gov_forms_snapshots';
  static const String videoProgressKey = 'video_progress';
  static const String timeEntriesKey = 'time_entries';
  
  static const List<String> supportedDocumentExtensions = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'doc',
    'docx',
  ];
  
  static const int maxFileSize = 10 * 1024 * 1024;
}
