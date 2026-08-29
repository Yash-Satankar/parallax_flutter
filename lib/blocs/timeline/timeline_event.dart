import 'package:equatable/equatable.dart';

abstract class TimelineEvent extends Equatable {
  const TimelineEvent();
  @override
  List<Object?> get props => [];
}

class TimelineLoadRequested extends TimelineEvent {
  const TimelineLoadRequested();
}

class TimelineRefreshRequested extends TimelineEvent {
  const TimelineRefreshRequested();
}
