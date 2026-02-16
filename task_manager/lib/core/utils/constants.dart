class AppConstants {
  static const String baseUrl = 'https://api.example.com/v1'; // Placeholder
  static const String tokenKey = 'jwt_token';
  static const String userRoleKey = 'user_role';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String usersEndpoint = '/users';
  static const String tasksEndpoint = '/tasks';
  static const String statsEndpoint = '/stats';

  // Task Statuses
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';

  // Priorities
  static const String priorityLow = 'Low';
  static const String priorityMedium = 'Medium';
  static const String priorityHigh = 'High';
}
