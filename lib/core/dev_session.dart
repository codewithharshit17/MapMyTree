//TODO: REMOVE ENTIRE FILE BEFORE PRODUCTION
class DevSession {
  static final DevSession _instance = DevSession._internal();
  factory DevSession() => _instance;
  DevSession._internal();

  bool isActive = false;
  String userId = '';
  String userRole = ''; // 'ngo' or 'user'
  String userName = '';
  String userEmail = '';

  void loginAsNGO() {
    isActive = true;
    userId = 'test-ngo-001';
    userRole = 'ngo';
    userName = 'Green Earth NGO';
    userEmail = 'ngo@mapmytree.com';
  }

  void loginAsUser() {
    isActive = true;
    userId = 'test-user-001';
    userRole = 'user';
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
