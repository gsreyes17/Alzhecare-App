import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../core/theme/theme_provider.dart';
import '../features/auth/presentation/auth_cubit.dart';
import '../features/auth/presentation/auth_state.dart';
import '../features/auth/presentation/auth_page.dart';
import '../features/dashboard/presentation/dashboard_shell.dart';

class AlzhecareApp extends StatelessWidget {
  const AlzhecareApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF58B9C7),
      brightness: brightness,
    );

    final scheme = isDark
        ? baseScheme.copyWith(
            surface: const Color(0xFF0F1D24),
            surfaceContainer: const Color(0xFF152A33),
            surfaceContainerHighest: const Color(0xFF1D3742),
            onSurface: const Color(0xFFE9F4F6),
            onSurfaceVariant: const Color(0xFFB6CBD1),
            primary: const Color(0xFF7ED6E4),
            onPrimary: const Color(0xFF062831),
            primaryContainer: const Color(0xFF21414B),
            onPrimaryContainer: const Color(0xFFDFF7FB),
          )
        : baseScheme.copyWith(
            surface: const Color(0xFFF7FCFD),
            surfaceContainer: const Color(0xFFF0F8FA),
            surfaceContainerHighest: const Color(0xFFE3F3F6),
            onSurface: const Color(0xFF10232A),
            onSurfaceVariant: const Color(0xFF4E6670),
            primary: const Color(0xFF2A8FA3),
            onPrimary: Colors.white,
            primaryContainer: const Color(0xFFCAEAF1),
            onPrimaryContainer: const Color(0xFF0E3A44),
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0A151B)
          : const Color(0xFFEFF7FA),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? const Color(0xFF27414A) : const Color(0xFFD5E9EF),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF28424C) : const Color(0xFFD7E9EE),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: scheme.onSurface),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    return AnimatedBuilder(
      animation: themeProvider,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Alzhecare',
          themeMode: themeProvider.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: const _AuthGate(),
        );
      },
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _splashRemoved = false;

  void _removeSplashIfNeeded(AuthState state) {
    if (!_splashRemoved && state.status != AuthStatus.loading) {
      FlutterNativeSplash.remove();
      _splashRemoved = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) => _removeSplashIfNeeded(state),
      builder: (context, state) {
        _removeSplashIfNeeded(state);

        if (state.status == AuthStatus.loading) {
          return const Scaffold(body: SizedBox.shrink());
        }

        if (state.status == AuthStatus.authenticated && state.session != null) {
          return DashboardShell(session: state.session!);
        }

        return const AuthPage();
      },
    );
  }
}
