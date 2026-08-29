import 'package:equatable/equatable.dart';
import 'package:parallax_mobile/data/models.dart';

class ExportState extends Equatable {
  final String format;
  final String resolution;
  final int fps;
  final bool burnCaptions;
  final String audioBitrate;
  final bool isExporting;
  final ExportResponse? result;
  final String? error;

  const ExportState({
    this.format = 'mp4',
    this.resolution = '1080p',
    this.fps = 30,
    this.burnCaptions = false,
    this.audioBitrate = '192k',
    this.isExporting = false,
    this.result,
    this.error,
  });

  ExportState copyWith({
    String? format,
    String? resolution,
    int? fps,
    bool? burnCaptions,
    String? audioBitrate,
    bool? isExporting,
    ExportResponse? result,
    String? error,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return ExportState(
      format: format ?? this.format,
      resolution: resolution ?? this.resolution,
      fps: fps ?? this.fps,
      burnCaptions: burnCaptions ?? this.burnCaptions,
      audioBitrate: audioBitrate ?? this.audioBitrate,
      isExporting: isExporting ?? this.isExporting,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [format, resolution, fps, burnCaptions, audioBitrate, isExporting, result, error];
}
