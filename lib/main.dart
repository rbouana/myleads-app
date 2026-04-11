import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize encrypted SQLite storage and restore session if any
  await StorageService.init();

  runApp(const ProviderScope(child: MyLeadsApp()));
}

class MyLeadsApp extends StatelessWidget {
  const MyLeadsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Leads',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
