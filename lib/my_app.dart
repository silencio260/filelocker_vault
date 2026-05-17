import 'package:flutter/material.dart';
import 'app_initializer_page.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

class FileLockerApp extends StatelessWidget {
  const FileLockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FileLocker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: generateRoute,
      home: const AppInitializerPage(),
    );
  }
}
