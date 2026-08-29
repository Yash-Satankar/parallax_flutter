import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/blocs/history/history_event.dart';
import 'package:parallax_mobile/blocs/history/history_state.dart';
import 'package:parallax_mobile/data/parallax_api.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ParallaxApi api;
  final String projectId;

  HistoryBloc({required this.api, required this.projectId})
      : super(const HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoad);
    on<HistoryUndoRequested>(_onUndo);
    on<HistoryRedoRequested>(_onRedo);
    on<HistoryRestoreRequested>(_onRestore);
    on<HistoryCheckpointRequested>(_onCheckpoint);
  }

  Future<void> _onLoad(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    try {
      final history = await api.getHistory(projectId);
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onUndo(
    HistoryUndoRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    try {
      await api.undoHistory(projectId);
      final history = await api.getHistory(projectId);
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onRedo(
    HistoryRedoRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    try {
      await api.redoHistory(projectId);
      final history = await api.getHistory(projectId);
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onRestore(
    HistoryRestoreRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    try {
      await api.restoreHistory(projectId, event.revisionId);
      final history = await api.getHistory(projectId);
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onCheckpoint(
    HistoryCheckpointRequested event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await api.createCheckpoint(projectId, event.label);
      final history = await api.getHistory(projectId);
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
