import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/blocs/settings/settings_event.dart';
import 'package:parallax_mobile/blocs/settings/settings_state.dart';
import 'package:parallax_mobile/data/parallax_api.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ParallaxApi api;

  SettingsBloc({required this.api}) : super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsProfileSelected>(_onProfileSelected);
  }

  Future<void> _onLoad(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await api.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onProfileSelected(
    SettingsProfileSelected event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final updated = await api.updateSettings(event.profileId);
      emit(SettingsLoaded(updated));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
