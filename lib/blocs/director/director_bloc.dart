import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/blocs/director/director_event.dart';
import 'package:parallax_mobile/blocs/director/director_state.dart';
import 'package:parallax_mobile/data/models.dart';
import 'package:parallax_mobile/data/parallax_api.dart';

class DirectorBloc extends Bloc<DirectorEvent, DirectorState> {
  final ParallaxApi api;
  final String projectId;
  final String chatId;
  CancelToken? _cancelToken;
  final Stopwatch _stopwatch = Stopwatch();

  DirectorBloc({
    required this.api,
    required this.projectId,
    required this.chatId,
  }) : super(const DirectorState()) {
    on<DirectorLoadChat>(_onLoadChat);
    on<DirectorSendMessage>(_onSendMessage);
    on<DirectorCancelStream>(_onCancel);
    on<DirectorSetThinkingEffort>(_onSetEffort);
    on<DirectorSetProfile>(_onSetProfile);
    on<DirectorAddImage>(_onAddImage);
    on<DirectorRemoveImage>(_onRemoveImage);
    on<DirectorClearImages>(_onClearImages);
    // Internal SSE events
    on<DirectorStreamText>(_onStreamText);
    on<DirectorStreamActivity>(_onStreamActivity);
    on<DirectorStreamDone>(_onStreamDone);
    on<DirectorStreamError>(_onStreamError);

    add(const DirectorLoadChat());
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel('Bloc closed');
    return super.close();
  }

  Future<void> _onLoadChat(
    DirectorLoadChat event,
    Emitter<DirectorState> emit,
  ) async {
    try {
      final record = await api.getChat(projectId, chatId);
      emit(state.copyWith(messages: record.messages));
    } catch (_) {
      // Fresh chat — no history
    }
  }

  Future<void> _onSendMessage(
    DirectorSendMessage event,
    Emitter<DirectorState> emit,
  ) async {
    if (event.text.trim().isEmpty && (event.images?.isEmpty ?? true)) return;
    if (state.isStreaming) return;

    final userMessage = ChatMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      text: event.text.trim(),
      time: DateTime.now().toIso8601String(),
      images: event.images?.isNotEmpty == true ? event.images : null,
    );

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      stagedImages: [],
      isStreaming: true,
      currentStreamingText: '',
      currentTrace: [],
      clearError: true,
    ));

    _cancelToken = CancelToken();
    _stopwatch
      ..reset()
      ..start();

    try {
      await api.streamAgentChat(
        projectId: projectId,
        sessionId: chatId,
        message: event.text.trim(),
        profileId: state.selectedProfileId,
        thinkingEffort: state.thinkingEffort,
        images: event.images?.isNotEmpty == true ? event.images : null,
        cancelToken: _cancelToken,
        callbacks: AgentChatCallbacks(
          onText: (delta) {
            if (!isClosed) add(DirectorStreamText(delta));
          },
          onActivity: (activity) {
            if (!isClosed) add(DirectorStreamActivity(activity));
          },
          onDone: (reason, iterations) {
            _stopwatch.stop();
            if (!isClosed) {
              add(DirectorStreamDone(reason, iterations, _stopwatch.elapsedMilliseconds));
            }
          },
          onError: (err) {
            if (!isClosed) add(DirectorStreamError(err));
          },
        ),
      );
    } catch (e) {
      if (e is! DioException || e.type != DioExceptionType.cancel) {
        if (!isClosed) add(DirectorStreamError(e.toString()));
      }
    }
  }

  void _onCancel(DirectorCancelStream event, Emitter<DirectorState> emit) {
    _cancelToken?.cancel('Cancelled by user');
    emit(state.copyWith(isStreaming: false));
  }

  void _onSetEffort(DirectorSetThinkingEffort event, Emitter<DirectorState> emit) {
    emit(state.copyWith(thinkingEffort: event.effort));
  }

  void _onSetProfile(DirectorSetProfile event, Emitter<DirectorState> emit) {
    emit(state.copyWith(selectedProfileId: event.profileId));
  }

  void _onAddImage(DirectorAddImage event, Emitter<DirectorState> emit) {
    emit(state.copyWith(stagedImages: [...state.stagedImages, event.image]));
  }

  void _onRemoveImage(DirectorRemoveImage event, Emitter<DirectorState> emit) {
    final updated = List<ChatImage>.from(state.stagedImages)..removeAt(event.index);
    emit(state.copyWith(stagedImages: updated));
  }

  void _onClearImages(DirectorClearImages event, Emitter<DirectorState> emit) {
    emit(state.copyWith(stagedImages: []));
  }

  // --- Internal SSE event handlers ---

  void _onStreamText(DirectorStreamText event, Emitter<DirectorState> emit) {
    emit(state.copyWith(
      currentStreamingText: state.currentStreamingText + event.delta,
    ));
  }

  void _onStreamActivity(DirectorStreamActivity event, Emitter<DirectorState> emit) {
    final idx = state.currentTrace.indexWhere((a) => a.id == event.activity.id);
    final List<DirectorActivity> updated;
    if (idx >= 0) {
      updated = List.from(state.currentTrace)..[idx] = event.activity;
    } else {
      updated = [...state.currentTrace, event.activity];
    }
    emit(state.copyWith(currentTrace: updated));
  }

  void _onStreamDone(DirectorStreamDone event, Emitter<DirectorState> emit) {
    final assistantMessage = ChatMessage(
      id: 'asst-${DateTime.now().millisecondsSinceEpoch}',
      role: 'assistant',
      text: state.currentStreamingText.isNotEmpty
          ? state.currentStreamingText
          : 'Task completed (${event.reason})',
      time: DateTime.now().toIso8601String(),
      workedMs: event.workedMs,
      trace: state.currentTrace.isNotEmpty ? List.from(state.currentTrace) : null,
    );

    emit(state.copyWith(
      messages: [...state.messages, assistantMessage],
      isStreaming: false,
      currentStreamingText: '',
      currentTrace: [],
    ));
  }

  void _onStreamError(DirectorStreamError event, Emitter<DirectorState> emit) {
    emit(state.copyWith(
      isStreaming: false,
      error: event.message,
    ));
  }
}
