import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:parallax_mobile/data/models.dart';

/// Callbacks for Director SSE Chat Stream
class AgentChatCallbacks {
  final void Function(String sessionId)? onSession;
  final void Function(int iteration, String phase)? onStep;
  final void Function(String deltaText)? onText;
  final void Function(DirectorActivity activity)? onActivity;
  final void Function(String id, String name, dynamic args)? onToolCall;
  final void Function(String id, String name, bool ok, dynamic output, String? error)? onToolResult;
  final void Function(String reason, int iterations)? onDone;
  final void Function(String error)? onError;

  AgentChatCallbacks({
    this.onSession,
    this.onStep,
    this.onText,
    this.onActivity,
    this.onToolCall,
    this.onToolResult,
    this.onDone,
    this.onError,
  });
}

/// Parallax REST & SSE API Client
class ParallaxApi {
  final Dio _dio;
  String _baseUrl;

  ParallaxApi(this._dio, {String baseUrl = 'http://localhost:8080'})
      : _baseUrl = baseUrl.replaceAll(RegExp(r'/$'), '');

  String get baseUrl => _baseUrl;

  void setBaseUrl(String newUrl) {
    _baseUrl = newUrl.replaceAll(RegExp(r'/$'), '');
    _dio.options.baseUrl = _baseUrl;
  }

  // -------------------------------------------------------------
  // Health & Settings
  // -------------------------------------------------------------

  Future<HealthStatus> health() async {
    final response = await _dio.get('$_baseUrl/health');
    if (response.data is Map<String, dynamic>) {
      return HealthStatus.fromJson(response.data as Map<String, dynamic>);
    }
    return HealthStatus(
      ok: true,
      model: 'unknown',
      baseUrl: _baseUrl,
      workspace: '',
    );
  }

  Future<LLMSettings> getSettings() async {
    final response = await _dio.get('$_baseUrl/v1/settings');
    return LLMSettings.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LLMSettings> updateSettings(String activeId) async {
    final response = await _dio.put(
      '$_baseUrl/v1/settings',
      data: {'active_id': activeId},
    );
    return LLMSettings.fromJson(response.data as Map<String, dynamic>);
  }

  // -------------------------------------------------------------
  // Projects
  // -------------------------------------------------------------

  Future<List<ProjectRecord>> listProjects() async {
    final response = await _dio.get('$_baseUrl/v1/projects');
    final data = response.data;
    if (data is Map<String, dynamic> && data['projects'] is List) {
      return (data['projects'] as List<dynamic>)
          .map((p) => ProjectRecord.fromJson(p as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<ProjectRecord> createProject(String name) async {
    final response = await _dio.post(
      '$_baseUrl/v1/projects',
      data: {'name': name},
    );
    final data = response.data as Map<String, dynamic>;
    if (data.containsKey('project')) {
      return ProjectRecord.fromJson(data['project'] as Map<String, dynamic>);
    }
    return ProjectRecord.fromJson(data);
  }

  Future<ProjectDetail> getProject(String projectId) async {
    final response = await _dio.get('$_baseUrl/v1/projects/$projectId');
    return ProjectDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteProject(String projectId) async {
    await _dio.delete('$_baseUrl/v1/projects/$projectId');
  }

  // -------------------------------------------------------------
  // Media Bin & Semantic Search
  // -------------------------------------------------------------

  Future<List<MediaAsset>> listMedia(String projectId) async {
    final response = await _dio.get('$_baseUrl/v1/projects/$projectId/media');
    final data = response.data;
    if (data is Map<String, dynamic> && data['media'] is List) {
      return (data['media'] as List<dynamic>)
          .map((m) => MediaAsset.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<MediaSearchHit>> searchMedia(
    String projectId,
    String query, {
    int limit = 24,
  }) async {
    if (query.trim().isEmpty) return [];
    final response = await _dio.get(
      '$_baseUrl/v1/projects/$projectId/media/search',
      queryParameters: {'q': query.trim(), 'limit': limit},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['results'] is List) {
      return (data['results'] as List<dynamic>)
          .map((r) => MediaSearchHit.fromJson(r as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> uploadMediaFile({
    required String projectId,
    required String filePath,
    required String fileName,
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    await _dio.post(
      '$_baseUrl/v1/projects/$projectId/media',
      data: formData,
      onSendProgress: onProgress,
    );
  }

  Future<void> uploadMediaBytes({
    required String projectId,
    required List<int> bytes,
    required String fileName,
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    await _dio.post(
      '$_baseUrl/v1/projects/$projectId/media',
      data: formData,
      onSendProgress: onProgress,
    );
  }

  Future<void> describeMedia(String projectId, String path) async {
    await _dio.post(
      '$_baseUrl/v1/projects/$projectId/media/describe',
      data: {'path': path},
    );
  }

  Future<void> deleteMedia(String projectId, String path) async {
    await _dio.delete('$_baseUrl/v1/projects/$projectId/files/$path');
  }

  String getFileUrl(String projectId, String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.replaceAll(RegExp(r'^/+'), '');
    return '$_baseUrl/v1/projects/$projectId/files/$cleanPath';
  }

  // -------------------------------------------------------------
  // Chats & Director Session History
  // -------------------------------------------------------------

  Future<List<ChatRecord>> listChats(String projectId) async {
    final response = await _dio.get('$_baseUrl/v1/projects/$projectId/chats');
    final data = response.data;
    if (data is Map<String, dynamic> && data['chats'] is List) {
      return (data['chats'] as List<dynamic>)
          .map((c) => ChatRecord.fromJson(c as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<ChatRecord> createChat(String projectId, {String title = 'New Director Chat'}) async {
    final response = await _dio.post(
      '$_baseUrl/v1/projects/$projectId/chats',
      data: {'title': title},
    );
    return ChatRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ChatRecord> getChat(String projectId, String chatId) async {
    final response = await _dio.get('$_baseUrl/v1/projects/$projectId/chats/$chatId');
    return ChatRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ChatRecord> renameChat(String projectId, String chatId, String title) async {
    final response = await _dio.patch(
      '$_baseUrl/v1/projects/$projectId/chats/$chatId',
      data: {'title': title},
    );
    return ChatRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteChat(String projectId, String chatId) async {
    await _dio.delete('$_baseUrl/v1/projects/$projectId/chats/$chatId');
  }

  // -------------------------------------------------------------
  // Director SSE Agent Chat Streaming
  // -------------------------------------------------------------

  Future<void> streamAgentChat({
    required String projectId,
    required String message,
    String? sessionId,
    String? profileId,
    String thinkingEffort = 'medium',
    List<ChatImage>? images,
    required AgentChatCallbacks callbacks,
    CancelToken? cancelToken,
  }) async {
    final requestBody = <String, dynamic>{
      'project_id': projectId,
      'message': message,
      'thinking_effort': thinkingEffort,
      if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
      if (profileId != null && profileId.isNotEmpty) 'profile_id': profileId,
      if (images != null && images.isNotEmpty)
        'images': images
            .map((img) => {
                  if (img.name != null) 'name': img.name,
                  if (img.mime != null) 'mime': img.mime,
                  'data': img.data ?? img.url,
                })
            .toList(),
    };

    final response = await _dio.post<ResponseBody>(
      '$_baseUrl/v1/agent/chat',
      data: requestBody,
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Accept': 'text/event-stream',
          'Content-Type': 'application/json',
        },
      ),
      cancelToken: cancelToken,
    );

    final stream = response.data?.stream;
    if (stream == null) {
      callbacks.onError?.call('No response stream received from backend');
      return;
    }

    String buffer = '';
    String currentEvent = '';

    await for (final chunk in stream) {
      final text = utf8.decode(chunk);
      buffer += text;

      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // keep incomplete trailing line

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) {
          // Event boundary
          currentEvent = '';
          continue;
        }

        if (trimmed.startsWith('event:')) {
          currentEvent = trimmed.substring(6).trim();
          continue;
        }

        if (trimmed.startsWith('data:')) {
          final dataStr = trimmed.substring(5).trim();
          if (dataStr.isEmpty) continue;

          try {
            final parsed = jsonDecode(dataStr);
            if (parsed is Map<String, dynamic>) {
              _dispatchSSEEvent(currentEvent, parsed, callbacks);
            }
          } catch (_) {
            // raw text fallback
            if (currentEvent == 'text') {
              callbacks.onText?.call(dataStr);
            }
          }
        }
      }
    }

    if (buffer.trim().isNotEmpty) {
      if (buffer.trim().startsWith('data:')) {
        final dataStr = buffer.trim().substring(5).trim();
        try {
          final parsed = jsonDecode(dataStr);
          if (parsed is Map<String, dynamic>) {
            _dispatchSSEEvent(currentEvent, parsed, callbacks);
          }
        } catch (_) {}
      }
    }
  }

  void _dispatchSSEEvent(
    String event,
    Map<String, dynamic> data,
    AgentChatCallbacks callbacks,
  ) {
    switch (event) {
      case 'session':
        final sid = data['session_id']?.toString() ?? '';
        callbacks.onSession?.call(sid);
        break;

      case 'step':
        final iteration = (data['iteration'] as num?)?.toInt() ?? 1;
        final phase = data['phase']?.toString() ?? 'think';
        callbacks.onStep?.call(iteration, phase);
        callbacks.onActivity?.call(
          DirectorActivity(
            id: 'step-$iteration-$phase',
            kind: 'thinking',
            status: 'active',
            title: phase == 'act' ? 'Acting (Iteration $iteration)' : 'Thinking (Iteration $iteration)...',
            iteration: iteration,
          ),
        );
        break;

      case 'text':
        final delta = data['delta']?.toString() ?? '';
        callbacks.onText?.call(delta);
        break;

      case 'tool_call':
        final id = data['id']?.toString() ?? '';
        final name = data['name']?.toString() ?? 'tool';
        final args = data['arguments'];
        callbacks.onToolCall?.call(id, name, args);
        callbacks.onActivity?.call(
          DirectorActivity(
            id: id,
            kind: 'tool',
            status: 'active',
            title: 'Executing $name',
            name: name,
            arguments: args,
          ),
        );
        break;

      case 'tool_result':
        final id = data['id']?.toString() ?? '';
        final name = data['name']?.toString() ?? 'tool';
        final ok = data['ok'] == true;
        final output = data['output'];
        final error = data['error']?.toString();
        callbacks.onToolResult?.call(id, name, ok, output, error);
        callbacks.onActivity?.call(
          DirectorActivity(
            id: id,
            kind: 'tool',
            status: ok ? 'success' : 'error',
            title: '$name ${ok ? "succeeded" : "failed"}',
            name: name,
            detail: error ?? (output != null ? jsonEncode(output) : null),
          ),
        );
        break;

      case 'done':
        final reason = data['reason']?.toString() ?? 'finished';
        final iters = (data['iterations'] as num?)?.toInt() ?? 0;
        callbacks.onDone?.call(reason, iters);
        break;

      case 'error':
        final msg = data['message']?.toString() ?? 'Unknown agent error';
        callbacks.onError?.call(msg);
        break;
    }
  }

  // -------------------------------------------------------------
  // Timeline
  // -------------------------------------------------------------

  Future<TimelineDocument> getTimeline(String projectId) async {
    final response = await _dio.get('$_baseUrl/v1/projects/$projectId/timeline');
    return TimelineDocument.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TimelineDocument> updateTimeline(
    String projectId,
    TimelineDocument timeline,
  ) async {
    final response = await _dio.put(
      '$_baseUrl/v1/projects/$projectId/timeline',
      data: timeline.toJson(),
    );
    return TimelineDocument.fromJson(response.data as Map<String, dynamic>);
  }

  // -------------------------------------------------------------
  // Project Revisions & History
  // -------------------------------------------------------------

  Future<ProjectHistory> getHistory(String projectId) async {
    final response = await _dio.get('$_baseUrl/v1/projects/$projectId/history');
    return ProjectHistory.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProjectHistory> undoHistory(String projectId) async {
    final response = await _dio.post('$_baseUrl/v1/projects/$projectId/history/undo');
    return ProjectHistory.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProjectHistory> redoHistory(String projectId) async {
    final response = await _dio.post('$_baseUrl/v1/projects/$projectId/history/redo');
    return ProjectHistory.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProjectHistory> restoreHistory(String projectId, String revisionId) async {
    final response = await _dio.post(
      '$_baseUrl/v1/projects/$projectId/history/restore',
      data: {'revision_id': revisionId},
    );
    return ProjectHistory.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CheckpointRecord> createCheckpoint(
    String projectId,
    String name, {
    String? revisionId,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/v1/projects/$projectId/checkpoints',
      data: {
        'name': name,
        if (revisionId != null) 'revision_id': revisionId,
      },
    );
    return CheckpointRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCheckpoint(String projectId, String name) async {
    await _dio.delete('$_baseUrl/v1/projects/$projectId/checkpoints/$name');
  }

  // -------------------------------------------------------------
  // Export Render
  // -------------------------------------------------------------

  Future<ExportResponse> exportProject(
    String projectId,
    ExportRequest request,
  ) async {
    final response = await _dio.post(
      '$_baseUrl/v1/projects/$projectId/export',
      data: request.toJson(),
    );
    return ExportResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
