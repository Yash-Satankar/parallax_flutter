import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/blocs/project_detail/project_detail_event.dart';
import 'package:parallax_mobile/blocs/project_detail/project_detail_state.dart';
import 'package:parallax_mobile/data/parallax_api.dart';

class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final ParallaxApi api;
  final String projectId;

  ProjectDetailBloc({required this.api, required this.projectId})
      : super(const ProjectDetailInitial()) {
    on<ProjectDetailLoadRequested>(_onLoad);
    on<ProjectDetailRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(
    ProjectDetailEvent event,
    Emitter<ProjectDetailState> emit,
  ) async {
    emit(const ProjectDetailLoading());
    try {
      final detail = await api.getProject(projectId);
      emit(ProjectDetailLoaded(detail));
    } catch (e) {
      emit(ProjectDetailError(e.toString()));
    }
  }
}
