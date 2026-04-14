# Arquitectura de la app (resumen breve)

## Enfoque general
La app sigue una arquitectura por capas y por feature:

- `core/`: infraestructura compartida (API client, almacenamiento de sesión, modelos base, tema).
- `features/`: módulos funcionales (auth, patient, doctor, admin, analysis, profile).

## Patrón principal
Se usa combinación de:

- `Repository pattern`: cada feature encapsula sus llamadas HTTP en repositorios.
- `Cubit/BLoC`: el estado de UI y flujos principales (auth, diagnóstico) se manejan con Cubit.
- `UI desacoplada`: las pantallas consumen repositorios/cubits vía providers en el árbol principal.

## Flujo de datos
1. La UI dispara una acción (ejemplo: login, buscar paciente, crear cita).
2. El repositorio invoca `ApiClient`.
3. `ApiClient` agrega headers/token y transforma respuestas/errores.
4. La UI actualiza estado local o estado de Cubit y renderiza feedback.

## Sesión y seguridad
- El token y usuario se guardan en `SessionStorage`.
- Al iniciar app se ejecuta `bootstrap()` para revalidar sesión y entrar directo al dashboard si aplica.
- Endpoints protegidos usan `Authorization: Bearer <token>` automáticamente.

## Escalabilidad
El diseño permite agregar nuevas features sin romper lo existente porque:

- Cada módulo concentra su dominio (doctor, paciente, admin).
- Los modelos son reutilizables entre pantallas.
- Las pantallas se conectan al menú por rol desde un único shell (`DashboardShell`).
