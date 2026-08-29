import 'package:equatable/equatable.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();
  @override
  List<Object?> get props => [];
}

class ExportFormatChanged extends ExportEvent {
  final String format;
  const ExportFormatChanged(this.format);
  @override
  List<Object?> get props => [format];
}

class ExportResolutionChanged extends ExportEvent {
  final String resolution;
  const ExportResolutionChanged(this.resolution);
  @override
  List<Object?> get props => [resolution];
}

class ExportFpsChanged extends ExportEvent {
  final int fps;
  const ExportFpsChanged(this.fps);
  @override
  List<Object?> get props => [fps];
}

class ExportBurnCaptionsToggled extends ExportEvent {
  final bool value;
  const ExportBurnCaptionsToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class ExportAudioBitrateChanged extends ExportEvent {
  final String bitrate;
  const ExportAudioBitrateChanged(this.bitrate);
  @override
  List<Object?> get props => [bitrate];
}

class ExportStartRequested extends ExportEvent {
  const ExportStartRequested();
}

class ExportReset extends ExportEvent {
  const ExportReset();
}
