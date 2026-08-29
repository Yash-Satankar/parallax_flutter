import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/blocs/projects/projects_event.dart';
import 'package:parallax_mobile/blocs/projects/projects_state.dart';
import 'package:parallax_mobile/data/parallax_api.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ParallaxApi api;

  ProjectsBloc({required this.api}) : super(const ProjectsInitial()) {
    on<ProjectsLoadRequested>(_onLoad);
    on<ProjectCreateRequested>(_onCreate);
    on<ProjectDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    ProjectsLoadRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(const ProjectsLoading());
    try {
      final projects = await api.listProjects();
      emit(ProjectsLoaded(projects));
    } catch (e) {
      emit(ProjectsError(e.toString()));
    }
  }

  Future<void> _onCreate(
    ProjectCreateRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(const ProjectsLoading());
    try {
      final created = await api.createProject(event.name);
      final projects = await api.listProjects();
      emit(ProjectCreated(project: created, projects: projects));
    } catch (e) {
      emit(ProjectsError(e.toString()));
    }
  }

  Future<void> _onDelete(
    ProjectDeleteRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    // Preserve current list during delete
    final currentProjects = state is ProjectsLoaded
        ? (state as ProjectsLoaded).projects
        : state is ProjectCreated
            ? (state as ProjectCreated).projects
            : <dynamic>[];
    emit(const ProjectsLoading());
    try {
      await api.deleteProject(event.projectId);
      final projects = await api.listProjects();
      emit(ProjectsLoaded(projects));
    } catch (e) {
      // Re-emit prior projects on failure
      emit(ProjectsLoaded(currentProjects.cast()));
    }
  }
}
