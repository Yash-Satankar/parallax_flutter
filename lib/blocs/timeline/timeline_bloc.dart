import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/blocs/timeline/timeline_event.dart';
import 'package:parallax_mobile/blocs/timeline/timeline_state.dart';
import 'package:parallax_mobile/data/parallax_api.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  final ParallaxApi api;
  final String projectId;

  TimelineBloc({required this.api, required this.projectId})
      : super(const TimelineInitial()) {
    on<TimelineLoadRequested>(_onLoad);
    on<TimelineRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(
    TimelineEvent event,
    Emitter<TimelineState> emit,
  ) async {
    emit(const TimelineLoading());
    try {
      final doc = await api.getTimeline(projectId);
      emit(TimelineLoaded(doc));
    } catch (e) {
      emit(TimelineError(e.toString()));
    }
  }
}
