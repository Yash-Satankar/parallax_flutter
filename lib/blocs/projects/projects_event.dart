import 'package:equatable/equatable.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();
  @override
  List<Object?> get props => [];
}

class ProjectsLoadRequested extends ProjectsEvent {
  const ProjectsLoadRequested();
}

class ProjectCreateRequested extends ProjectsEvent {
  final String name;
  const ProjectCreateRequested(this.name);
  @override
  List<Object?> get props => [name];
}

class ProjectDeleteRequested extends ProjectsEvent {
  final String projectId;
  const ProjectDeleteRequested(this.projectId);
  @override
  List<Object?> get props => [projectId];
}
