import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class HistoryLoadRequested extends HistoryEvent {
  const HistoryLoadRequested();
}

class HistoryUndoRequested extends HistoryEvent {
  const HistoryUndoRequested();
}

class HistoryRedoRequested extends HistoryEvent {
  const HistoryRedoRequested();
}

class HistoryRestoreRequested extends HistoryEvent {
  final String revisionId;
  const HistoryRestoreRequested(this.revisionId);
  @override
  List<Object?> get props => [revisionId];
}

class HistoryCheckpointRequested extends HistoryEvent {
  final String label;
  const HistoryCheckpointRequested(this.label);
  @override
  List<Object?> get props => [label];
}
