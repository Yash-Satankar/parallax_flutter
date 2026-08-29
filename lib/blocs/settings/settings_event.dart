import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

class SettingsProfileSelected extends SettingsEvent {
  final String profileId;
  const SettingsProfileSelected(this.profileId);
  @override
  List<Object?> get props => [profileId];
}
