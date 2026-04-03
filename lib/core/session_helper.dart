import 'package:supabase_flutter/supabase_flutter.dart';
import 'dev_session.dart';

class SessionHelper {
  static String get userId {
    if (DevSession().isActive) return DevSession().userId;
    return Supabase.instance.client.auth.currentUser?.id ?? '';
  }

  static String get userRole {
    if (DevSession().isActive) return DevSession().userRole;
    // Read from your profiles table or JWT metadata
    return '';
  }

  static String get userName {
    if (DevSession().isActive) return DevSession().userName;
    return Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ??
        Supabase.instance.client.auth.currentUser?.email ??
        '';
  }

  static String get userEmail {
    if (DevSession().isActive) return DevSession().userEmail;
    return Supabase.instance.client.auth.currentUser?.email ?? '';
  }

  static bool get isLoggedIn {
    if (DevSession().isActive) return true;
    return Supabase.instance.client.auth.currentUser != null;
  }

  static bool get isNgo => userRole == 'ngo';
  static bool get isUser => userRole == 'user';
}
