import 'package:equatable/equatable.dart';
import 'package:parallax_mobile/data/models.dart';

abstract class TimelineState extends Equatable {
  const TimelineState();
  @override
  List<Object?> get props => [];
}

class TimelineInitial extends TimelineState {
  const TimelineInitial();
}

class TimelineLoading extends TimelineState {
  const TimelineLoading();
}

class TimelineLoaded extends TimelineState {
  final TimelineDocument document;
  const TimelineLoaded(this.document);
  @override
  List<Object?> get props => [document];
}

class TimelineError extends TimelineState {
  final String message;
  const TimelineError(this.message);
  @override
  List<Object?> get props => [message];
}
