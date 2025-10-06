class Endpoints {
  static const String idToken = '/auth/google/id-token';
  static const String signup = '/auth/signup';
  static const String sendOtp = '/auth/otp';
  static const String verifyOtp = '/auth/verify-otp';

  static String getAllTopics = '/topics/';

  static String followTopicsBulk = '/user/topics/bulk-follow';

  static String getTopicsByCategories = '/topics/categories/';

  static String createRoom = '/rooms/create';

  static String fetchUserNotifications = '/notifications/user/';

  static String discussionRandomTopic = '/discussion-topics/random/';

  static String updateProfile = '/user/profile/update';

  static String currentActiveRoom = '/rooms/current-active-room';

  static String submitRatings = '/ratings/batch-submit/';

  static String activeRooms = '/rooms/active';

  static String search = '/users/search';

  static String users = '/users';

  static String sendCommuneRequest = '/communes/requests/';

  static String communeRequestsSent = '/communes/sent';

  static String communes = '/communes/';

  static var rejectCommune = '/reject/';

  static String getTopicsFollowedByUser = '/user/followed-topics';
}
