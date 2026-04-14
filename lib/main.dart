import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app/alzhecare_app.dart';
import 'core/network/api_client.dart';
import 'core/storage/session_storage.dart';
import 'core/theme/theme_provider.dart';
import 'features/admin/data/admin_appointments_repository.dart';
import 'features/admin/data/admin_users_repository.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/doctor/data/doctor_repository.dart';
import 'features/patient/data/diagnosis_repository.dart';
import 'features/patient/data/patient_notifications_repository.dart';
import 'features/patient/data/patient_requests_repository.dart';
import 'features/patient/presentation/diagnosis_cubit.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionStorage = SessionStorage();
    final apiClient = ApiClient(sessionStorage: sessionStorage);

    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider()..load(),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: sessionStorage),
          RepositoryProvider.value(value: apiClient),
          RepositoryProvider(
            create: (_) => AuthRepository(
              apiClient: apiClient,
              sessionStorage: sessionStorage,
            ),
          ),
          RepositoryProvider(
            create: (_) => DiagnosisRepository(apiClient: apiClient),
          ),
          RepositoryProvider(
            create: (_) => DoctorRepository(apiClient: apiClient),
          ),
          RepositoryProvider(
            create: (_) => PatientRequestsRepository(apiClient: apiClient),
          ),
          RepositoryProvider(
            create: (_) => AdminAppointmentsRepository(apiClient: apiClient),
          ),
          RepositoryProvider(
            create: (_) => PatientNotificationsRepository(apiClient: apiClient),
          ),
          RepositoryProvider(
            create: (_) => AdminUsersRepository(apiClient: apiClient),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  AuthCubit(authRepository: context.read<AuthRepository>())
                    ..bootstrap(),
            ),
            BlocProvider(
              create: (context) => DiagnosisCubit(
                diagnosisRepository: context.read<DiagnosisRepository>(),
              ),
            ),
          ],
          child: const AlzhecareApp(),
        ),
      ),
    );
  }
}
