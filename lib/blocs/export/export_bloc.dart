import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/blocs/export/export_event.dart';
import 'package:parallax_mobile/blocs/export/export_state.dart';
import 'package:parallax_mobile/data/models.dart';
import 'package:parallax_mobile/data/parallax_api.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ParallaxApi api;
  final String projectId;

  ExportBloc({required this.api, required this.projectId})
      : super(const ExportState()) {
    on<ExportFormatChanged>((e, emit) => emit(state.copyWith(format: e.format)));
    on<ExportResolutionChanged>((e, emit) => emit(state.copyWith(resolution: e.resolution)));
    on<ExportFpsChanged>((e, emit) => emit(state.copyWith(fps: e.fps)));
    on<ExportBurnCaptionsToggled>((e, emit) => emit(state.copyWith(burnCaptions: e.value)));
    on<ExportAudioBitrateChanged>((e, emit) => emit(state.copyWith(audioBitrate: e.bitrate)));
    on<ExportReset>((e, emit) => emit(const ExportState()));
    on<ExportStartRequested>(_onExport);
  }

  Future<void> _onExport(
    ExportStartRequested event,
    Emitter<ExportState> emit,
  ) async {
    emit(state.copyWith(isExporting: true, clearResult: true, clearError: true));
    try {
      final request = ExportRequest(
        format: state.format,
        resolution: state.resolution,
        fps: state.fps,
        burnCaptions: state.burnCaptions,
        audioBitrate: state.audioBitrate,
      );
      final response = await api.exportProject(projectId, request);
      emit(state.copyWith(isExporting: false, result: response));
    } catch (e) {
      emit(state.copyWith(isExporting: false, error: e.toString()));
    }
  }
}
