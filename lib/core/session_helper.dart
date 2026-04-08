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
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return '';
    
    final metaName = user.userMetadata?['name'] ?? user.userMetadata?['full_name'];
    if (metaName != null && metaName.toString().isNotEmpty) {
      return metaName.toString();
    }
    
    final email = user.email;
    if (email != null && email.isNotEmpty) {
      final prefix = email.split('@')[0];
      if (prefix.isNotEmpty) {
        return prefix[0].toUpperCase() + prefix.substring(1);
      }
    }
    
    return 'User';
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
