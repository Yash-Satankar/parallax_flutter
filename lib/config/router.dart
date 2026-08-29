import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parallax_mobile/blocs/director/director_bloc.dart';
import 'package:parallax_mobile/blocs/director/director_event.dart';
import 'package:parallax_mobile/blocs/export/export_bloc.dart';
import 'package:parallax_mobile/blocs/history/history_bloc.dart';
import 'package:parallax_mobile/blocs/history/history_event.dart';
import 'package:parallax_mobile/blocs/media/media_bloc.dart';
import 'package:parallax_mobile/blocs/media/media_event.dart';
import 'package:parallax_mobile/blocs/project_detail/project_detail_bloc.dart';
import 'package:parallax_mobile/blocs/project_detail/project_detail_event.dart';
import 'package:parallax_mobile/blocs/timeline/timeline_bloc.dart';
import 'package:parallax_mobile/blocs/timeline/timeline_event.dart';
import 'package:parallax_mobile/data/parallax_api.dart';
import 'package:parallax_mobile/screens/home_screen.dart';
import 'package:parallax_mobile/screens/project_workspace_screen.dart';
import 'package:parallax_mobile/screens/settings_screen.dart';

GoRouter buildAppRouter(ParallaxApi api) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/project/:projectId',
        builder: (context, state) => _projectWorkspace(
          api: api,
          projectId: state.pathParameters['projectId']!,
          initialTab: 0,
        ),
        routes: [
          GoRoute(
            path: 'media',
            builder: (context, state) => _projectWorkspace(
              api: api,
              projectId: state.pathParameters['projectId']!,
              initialTab: 1,
            ),
          ),
          GoRoute(
            path: 'timeline',
            builder: (context, state) => _projectWorkspace(
              api: api,
              projectId: state.pathParameters['projectId']!,
              initialTab: 2,
            ),
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => _projectWorkspace(
              api: api,
              projectId: state.pathParameters['projectId']!,
              initialTab: 3,
            ),
          ),
          GoRoute(
            path: 'export',
            builder: (context, state) => _projectWorkspace(
              api: api,
              projectId: state.pathParameters['projectId']!,
              initialTab: 4,
            ),
          ),
          GoRoute(
            path: 'chat/:chatId',
            builder: (context, state) => _projectWorkspace(
              api: api,
              projectId: state.pathParameters['projectId']!,
              initialTab: 0,
              chatId: state.pathParameters['chatId'],
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
}

/// Wraps [ProjectWorkspaceScreen] with all scoped per-project BlocProviders.
Widget _projectWorkspace({
  required ParallaxApi api,
  required String projectId,
  required int initialTab,
  String? chatId,
}) {
  final resolvedChatId = chatId ?? 'default';
  return MultiBlocProvider(
    providers: [
      BlocProvider<ProjectDetailBloc>(
        create: (_) => ProjectDetailBloc(api: api, projectId: projectId)
          ..add(const ProjectDetailLoadRequested()),
      ),
      BlocProvider<MediaBloc>(
        create: (_) => MediaBloc(api: api, projectId: projectId)
          ..add(const MediaLoadRequested()),
      ),
      BlocProvider<DirectorBloc>(
        create: (_) => DirectorBloc(api: api, projectId: projectId, chatId: resolvedChatId)
          ..add(const DirectorLoadChat()),
      ),
      BlocProvider<TimelineBloc>(
        create: (_) => TimelineBloc(api: api, projectId: projectId)
          ..add(const TimelineLoadRequested()),
      ),
      BlocProvider<HistoryBloc>(
        create: (_) => HistoryBloc(api: api, projectId: projectId)
          ..add(const HistoryLoadRequested()),
      ),
      BlocProvider<ExportBloc>(
        create: (_) => ExportBloc(api: api, projectId: projectId),
      ),
    ],
    child: ProjectWorkspaceScreen(
      projectId: projectId,
      initialTab: initialTab,
    ),
  );
}
