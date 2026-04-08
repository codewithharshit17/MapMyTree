import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/ngo/ngo_shell_screen.dart';
import 'screens/user/user_shell_screen.dart';
import 'screens/ngo/tree_info_screen.dart';

// TODO: Replace these with your actual Supabase project values from:
// Supabase Dashboard → Project Settings → API
const String _supabaseUrl = 'https://lkfhtwtmdiwcyriejcwy.supabase.co';
const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxrZmh0d3RtZGl3Y3lyaWVqY3d5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2NTUxMDQsImV4cCI6MjA5MTIzMTEwNH0.5Bu5w3hvcreFqZL7rj5w4-w2UGgUWDGdQ3QS5YDAE3o';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
      ],
      child: const MapMyTreeApp(),
    ),
  );
}

class MapMyTreeApp extends StatelessWidget {
  const MapMyTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapMyTree',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/ngo-dashboard': (context) => const NgoShellScreen(),
        '/user-dashboard': (context) => const UserShellScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/tree/')) {
          final treeId = settings.name!.replaceFirst('/tree/', '');
          return MaterialPageRoute(
            builder: (context) => TreeInfoScreen(treeId: treeId),
          );
        }
        return null;
      },
    );
  }
}
