import 'package:equatable/equatable.dart';

abstract class MediaEvent extends Equatable {
  const MediaEvent();
  @override
  List<Object?> get props => [];
}

class MediaLoadRequested extends MediaEvent {
  const MediaLoadRequested();
}

class MediaSearchRequested extends MediaEvent {
  final String query;
  const MediaSearchRequested(this.query);
  @override
  List<Object?> get props => [query];
}

class MediaSearchCleared extends MediaEvent {
  const MediaSearchCleared();
}

class MediaUploadRequested extends MediaEvent {
  final String filePath;
  final String fileName;
  const MediaUploadRequested({required this.filePath, required this.fileName});
  @override
  List<Object?> get props => [filePath, fileName];
}

class MediaDeleteRequested extends MediaEvent {
  final String mediaPath;
  const MediaDeleteRequested(this.mediaPath);
  @override
  List<Object?> get props => [mediaPath];
}

class MediaDescribeRequested extends MediaEvent {
  final String mediaId;
  const MediaDescribeRequested(this.mediaId);
  @override
  List<Object?> get props => [mediaId];
}
