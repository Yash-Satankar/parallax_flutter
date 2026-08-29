import 'package:equatable/equatable.dart';
import 'package:parallax_mobile/data/models.dart';

abstract class ProjectsState extends Equatable {
  const ProjectsState();
  @override
  List<Object?> get props => [];
}

class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

class ProjectsLoaded extends ProjectsState {
  final List<ProjectRecord> projects;
  const ProjectsLoaded(this.projects);
  @override
  List<Object?> get props => [projects];
}

class ProjectsError extends ProjectsState {
  final String message;
  const ProjectsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProjectCreated extends ProjectsState {
  final ProjectRecord project;
  final List<ProjectRecord> projects;
  const ProjectCreated({required this.project, required this.projects});
  @override
  List<Object?> get props => [project, projects];
}
