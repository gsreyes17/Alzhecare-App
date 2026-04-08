import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/services/api_service.dart';

import 'data/providers/_index_.dart';

import 'features/global/login_auth.dart';

import 'core/widgets/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DiagnosticoProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => CoordinacionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AlzheCare',
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'),
              Locale('en', 'US'),
            ],
            locale: const Locale('es', 'ES'),
            home: AppInitializer(),
          );
        },
      ),
    );
  }
}
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: themeProvider.currentTheme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return authProvider.isLoggedIn
        ? _buildDashboardByRole(authProvider.userRole)
        : Login();
  }

  Widget _buildDashboardByRole(String role) {
    switch (role) {
      case 'patient':
        return const PatientShell();
      case 'doctor':
        return const DoctorShell();
      case 'admin':
        return const AdminShell();
      default:
        return const PatientShell();
    }
  }
}