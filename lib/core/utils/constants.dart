class Constants {
  static const String PREF_NAME = 'pref_name';
  static const String PREF_NOTIF_SETTING = 'pref_notif_setting';
  static const String PREF_TOKEN = 'pref_token';
  static const String PREF_REFRESH_TOKEN = 'pref_refresh_token';
  static const String PREF_EXPIRED_TOKEN = 'pref_expired_token';
  static const String PREF_EXPIRED_REFRESH_TOKEN = 'pref_expired_refresh_token';
  
  // API Endpoints
  static const String BASE_URL = 'https://api.example.com';
  static const String LOGIN_ENDPOINT = '/auth/login';
  static const String REFRESH_TOKEN_ENDPOINT = '/auth/refresh-token';
  static const String ATTENDANCE_TODAY_ENDPOINT = '/attendance/today';
  static const String ATTENDANCE_MONTH_ENDPOINT = '/attendance/month';
  static const String SCHEDULE_ENDPOINT = '/schedule';
  static const String SCHEDULE_BANNED_ENDPOINT = '/schedule/banned';
  
  // Error Messages
  static const String ERROR_NETWORK = 'Network error occurred';
  static const String ERROR_UNKNOWN = 'Unknown error occurred';
  static const String ERROR_UNAUTHORIZED = 'Unauthorized access';
  static const String ERROR_SERVER = 'Server error occurred';
  
  // Notification
  static const String NOTIFICATION_CHANNEL_ID = 'attendance_channel';
  static const String NOTIFICATION_CHANNEL_NAME = 'Attendance Notifications';
  static const String NOTIFICATION_CHANNEL_DESC = 'Notifications for attendance reminders';
}
