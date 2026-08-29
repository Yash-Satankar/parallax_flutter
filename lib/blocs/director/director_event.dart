import 'package:equatable/equatable.dart';
import 'package:parallax_mobile/data/models.dart';

abstract class DirectorEvent extends Equatable {
  const DirectorEvent();
  @override
  List<Object?> get props => [];
}

class DirectorLoadChat extends DirectorEvent {
  const DirectorLoadChat();
}

class DirectorSendMessage extends DirectorEvent {
  final String text;
  final List<ChatImage>? images;
  const DirectorSendMessage(this.text, {this.images});
  @override
  List<Object?> get props => [text, images];
}

class DirectorCancelStream extends DirectorEvent {
  const DirectorCancelStream();
}

class DirectorSetThinkingEffort extends DirectorEvent {
  final String effort; // low | medium | high
  const DirectorSetThinkingEffort(this.effort);
  @override
  List<Object?> get props => [effort];
}

class DirectorSetProfile extends DirectorEvent {
  final String? profileId;
  const DirectorSetProfile(this.profileId);
  @override
  List<Object?> get props => [profileId];
}

class DirectorAddImage extends DirectorEvent {
  final ChatImage image;
  const DirectorAddImage(this.image);
  @override
  List<Object?> get props => [image];
}

class DirectorRemoveImage extends DirectorEvent {
  final int index;
  const DirectorRemoveImage(this.index);
  @override
  List<Object?> get props => [index];
}

class DirectorClearImages extends DirectorEvent {
  const DirectorClearImages();
}

// Internal events emitted by SSE stream
class DirectorStreamText extends DirectorEvent {
  final String delta;
  const DirectorStreamText(this.delta);
  @override
  List<Object?> get props => [delta];
}

class DirectorStreamActivity extends DirectorEvent {
  final DirectorActivity activity;
  const DirectorStreamActivity(this.activity);
  @override
  List<Object?> get props => [activity];
}

class DirectorStreamDone extends DirectorEvent {
  final String reason;
  final int iterations;
  final int workedMs;
  const DirectorStreamDone(this.reason, this.iterations, this.workedMs);
  @override
  List<Object?> get props => [reason, iterations, workedMs];
}

class DirectorStreamError extends DirectorEvent {
  final String message;
  const DirectorStreamError(this.message);
  @override
  List<Object?> get props => [message];
}
