import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/blocs/health/health_bloc.dart';
import 'package:parallax_mobile/blocs/health/health_event.dart';
import 'package:parallax_mobile/blocs/projects/projects_bloc.dart';
import 'package:parallax_mobile/blocs/projects/projects_event.dart';
import 'package:parallax_mobile/blocs/server/server_cubit.dart';
import 'package:parallax_mobile/blocs/settings/settings_bloc.dart';
import 'package:parallax_mobile/blocs/settings/settings_event.dart';
import 'package:parallax_mobile/config/router.dart';
import 'package:parallax_mobile/config/theme.dart';
import 'package:parallax_mobile/data/parallax_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ParallaxApp());
}

class ParallaxApp extends StatefulWidget {
  const ParallaxApp({super.key});

  @override
  State<ParallaxApp> createState() => _ParallaxAppState();
}

class _ParallaxAppState extends State<ParallaxApp> {
  late final ServerCubit _serverCubit;
  late final ParallaxApi _api;

  @override
  void initState() {
    super.initState();
    final baseUrl = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8080'
        : 'http://localhost:8080';

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {'Accept': 'application/json'},
    ));

    _serverCubit = ServerCubit();
    _api = ParallaxApi(dio, baseUrl: baseUrl);
  }

  @override
  void dispose() {
    _serverCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ServerCubit>.value(value: _serverCubit),
        BlocProvider<HealthBloc>(
          create: (_) => HealthBloc(api: _api)..add(const HealthCheckRequested()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => SettingsBloc(api: _api)..add(const SettingsLoadRequested()),
        ),
        BlocProvider<ProjectsBloc>(
          create: (_) => ProjectsBloc(api: _api)..add(const ProjectsLoadRequested()),
        ),
      ],
      child: _AppCore(api: _api),
    );
  }
}

/// Rebuilds Dio and API client whenever the server URL is changed in settings.
class _AppCore extends StatelessWidget {
  final ParallaxApi api;

  const _AppCore({required this.api});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Parallax Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: buildAppRouter(api),
    );
  }
}
