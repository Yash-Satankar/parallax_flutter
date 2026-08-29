import 'package:equatable/equatable.dart';
import 'package:parallax_mobile/data/models.dart';

class DirectorState extends Equatable {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final String currentStreamingText;
  final List<DirectorActivity> currentTrace;
  final String? error;
  final String thinkingEffort;
  final String? selectedProfileId;
  final List<ChatImage> stagedImages;

  const DirectorState({
    this.messages = const [],
    this.isStreaming = false,
    this.currentStreamingText = '',
    this.currentTrace = const [],
    this.error,
    this.thinkingEffort = 'medium',
    this.selectedProfileId,
    this.stagedImages = const [],
  });

  DirectorState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? currentStreamingText,
    List<DirectorActivity>? currentTrace,
    String? error,
    bool clearError = false,
    String? thinkingEffort,
    String? selectedProfileId,
    List<ChatImage>? stagedImages,
  }) {
    return DirectorState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      currentStreamingText: currentStreamingText ?? this.currentStreamingText,
      currentTrace: currentTrace ?? this.currentTrace,
      error: clearError ? null : (error ?? this.error),
      thinkingEffort: thinkingEffort ?? this.thinkingEffort,
      selectedProfileId: selectedProfileId ?? this.selectedProfileId,
      stagedImages: stagedImages ?? this.stagedImages,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isStreaming,
        currentStreamingText,
        currentTrace,
        error,
        thinkingEffort,
        selectedProfileId,
        stagedImages,
      ];
}
