import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/blocs/health/health_event.dart';
import 'package:parallax_mobile/blocs/health/health_state.dart';
import 'package:parallax_mobile/data/parallax_api.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final ParallaxApi api;

  HealthBloc({required this.api}) : super(const HealthInitial()) {
    on<HealthCheckRequested>(_onHealthCheckRequested);
  }

  Future<void> _onHealthCheckRequested(
    HealthCheckRequested event,
    Emitter<HealthState> emit,
  ) async {
    emit(const HealthLoading());
    try {
      final health = await api.health();
      emit(HealthLoaded(health));
    } catch (e) {
      emit(HealthError(e.toString()));
    }
  }
}
