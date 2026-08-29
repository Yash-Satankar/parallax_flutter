import 'package:equatable/equatable.dart';
import 'package:parallax_mobile/data/models.dart';

abstract class HealthState extends Equatable {
  const HealthState();
  @override
  List<Object?> get props => [];
}

class HealthInitial extends HealthState {
  const HealthInitial();
}

class HealthLoading extends HealthState {
  const HealthLoading();
}

class HealthLoaded extends HealthState {
  final HealthStatus health;
  const HealthLoaded(this.health);
  @override
  List<Object?> get props => [health];
}

class HealthError extends HealthState {
  final String message;
  const HealthError(this.message);
  @override
  List<Object?> get props => [message];
}
