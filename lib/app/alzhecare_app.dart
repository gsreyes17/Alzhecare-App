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
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A6F8F),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF4F7FB),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.blueGrey.shade50),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A6F8F),
              brightness: Brightness.dark,
            ),
          ),
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
