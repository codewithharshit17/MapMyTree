import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/ngo_dashboard_provider.dart';

// TODO: Replace these with your actual Supabase project values from:
// Supabase Dashboard → Project Settings → API
const String _supabaseUrl = 'https://mkghlxbdwnigpjfvomgb.supabase.co';
const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1rZ2hseGJkd25pZ3BqZnZvbWdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNzkzMzMsImV4cCI6MjA4OTg1NTMzM30.coP_jg5OwuwYtFheJ1kkDcHBRwXXusVlwg0pyrEPh1s';

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
        ChangeNotifierProvider(create: (_) => NgoDashboardProvider()),
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
    );
  }
}
