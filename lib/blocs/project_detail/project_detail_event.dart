import 'package:equatable/equatable.dart';

abstract class ProjectDetailEvent extends Equatable {
  const ProjectDetailEvent();
  @override
  List<Object?> get props => [];
}

class ProjectDetailLoadRequested extends ProjectDetailEvent {
  const ProjectDetailLoadRequested();
}

class ProjectDetailRefreshRequested extends ProjectDetailEvent {
  const ProjectDetailRefreshRequested();
}
