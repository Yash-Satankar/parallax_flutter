import 'package:equatable/equatable.dart';
import 'package:parallax_mobile/data/models.dart';

abstract class ProjectDetailState extends Equatable {
  const ProjectDetailState();
  @override
  List<Object?> get props => [];
}

class ProjectDetailInitial extends ProjectDetailState {
  const ProjectDetailInitial();
}

class ProjectDetailLoading extends ProjectDetailState {
  const ProjectDetailLoading();
}

class ProjectDetailLoaded extends ProjectDetailState {
  final ProjectDetail detail;
  const ProjectDetailLoaded(this.detail);
  @override
  List<Object?> get props => [detail];
}

class ProjectDetailError extends ProjectDetailState {
  final String message;
  const ProjectDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
