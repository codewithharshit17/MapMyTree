//TODO: REMOVE ENTIRE FILE BEFORE PRODUCTION
class DevSession {
  static final DevSession _instance = DevSession._internal();
  factory DevSession() => _instance;
  DevSession._internal();

  bool isActive = false;
  String userId = '';
  String userRole = ''; // 'ngo_admin', 'ngo_volunteer', 'normal_user'
  String userName = '';
  String userEmail = '';

  void loginAsNGOAdmin() {
    isActive = true;
    userId = 'test-ngo-admin-001';
    userRole = 'ngo_admin';
    userName = 'Green Earth Admin';
    userEmail = 'ngo_admin@mapmytree.com';
  }

  void loginAsNGO() {
    // Keep for backward compatibility or rename to NGO Volunteer
    loginAsNGOVolunteer();
  }

  void loginAsNGOVolunteer() {
    isActive = true;
    userId = 'test-ngo-volunteer-001';
    userRole = 'ngo_volunteer';
    userName = 'Green Earth Volunteer';
    userEmail = 'ngo_volunteer@mapmytree.com';
  }

  void loginAsUser() {
    isActive = true;
    userId = 'test-user-001';
    userRole = 'normal_user';
    userName = 'Harshit Tester';
    userEmail = 'user@mapmytree.com';
  }

  void clear() {
    isActive = false;
    userId = '';
    userRole = '';
    userName = '';
    userEmail = '';
  }
}
