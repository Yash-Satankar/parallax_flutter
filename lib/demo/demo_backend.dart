import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:parallax_mobile/demo/demo_config.dart';
import 'package:parallax_mobile/demo/demo_seed.dart';

/// Dio [HttpClientAdapter] that serves the Parallax REST + SSE API offline.
///
/// The real [ParallaxApi] client, its JSON parsing and every bloc run
/// unchanged; only the transport is swapped. State (projects, timelines,
/// history, chats) lives in memory for the session.
class DemoBackendAdapter implements HttpClientAdapter {
  final DemoStore store = DemoStore.seeded();

  static const _latency = Duration(milliseconds: 450);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    final method = options.method.toUpperCase();
    final body = await _readBody(options, requestStream);

    if (path == '/v1/agent/chat' && method == 'POST') {
      return _sse(_director(body), cancelFuture);
    }

    await Future<void>.delayed(_latency);
    final result = _route(method, path, body, options.uri.queryParameters);
    return ResponseBody.fromString(
      jsonEncode(result.$2),
      result.$1,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}

  Future<Map<String, dynamic>> _readBody(
    RequestOptions o,
    Stream<Uint8List>? stream,
  ) async {
    if (o.data is Map<String, dynamic>) return o.data as Map<String, dynamic>;
    if (stream == null) return const {};
    try {
      final bytes = await stream.fold<List<int>>([], (a, b) => a..addAll(b));
      final decoded = jsonDecode(utf8.decode(bytes));
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }

  (int, Object?) _route(
    String method,
    String path,
    Map<String, dynamic> body,
    Map<String, String> query,
  ) {
    final seg = path.split('/').where((s) => s.isNotEmpty).toList();
    if (path == '/health') return (200, store.health());
    if (path == '/v1/settings') {
      if (method == 'PUT') store.activeProfile = '${body['active_id']}';
      return (200, store.settings());
    }
    if (seg.length == 2 && seg[1] == 'projects') {
      if (method == 'POST') {
        return (200, store.createProject('${body['name'] ?? 'Untitled'}'));
      }
      return (
        200,
        {'projects': store.projects.map((p) => p.record()).toList()}
      );
    }
    if (seg.length >= 3 && seg[1] == 'projects') {
      final project = store.byId(seg[2]);
      if (project == null) return (404, {'error': 'project not found'});
      final rest = seg.sublist(3);
      if (rest.isEmpty) {
        if (method == 'DELETE') {
          store.projects.remove(project);
          return (200, {'ok': true});
        }
        return (200, project.detail());
      }
      switch (rest.first) {
        case 'media':
          if (method == 'POST' && rest.length == 1) {
            project.addUpload();
            return (200, {'ok': true});
          }
          if (rest.length > 1 && rest[1] == 'search') {
            return (200, {'results': project.search(query['q'] ?? '')});
          }
          return (200, {'media': project.media});
        case 'timeline':
          if (method == 'PUT') project.saveTimeline(body);
          return (200, project.timeline);
        case 'history':
          if (rest.length > 1) {
            switch (rest[1]) {
              case 'undo':
                project.undo();
              case 'redo':
                project.redo();
              case 'restore':
                project.restore('${body['revision_id']}');
            }
          }
          return (200, project.history());
        case 'checkpoints':
          if (method == 'DELETE' && rest.length > 1) {
            project.checkpoints.removeWhere((c) => c['name'] == rest[1]);
            return (200, {'ok': true});
          }
          return (200, project.addCheckpoint('${body['name']}'));
        case 'chats':
          if (rest.length == 1) {
            if (method == 'POST') {
              return (
                200,
                project.newChat('${body['title'] ?? 'New Director Chat'}')
              );
            }
            return (200, {'chats': project.chats.values.toList()});
          }
          if (method == 'DELETE') {
            project.chats.remove(rest[1]);
            return (200, {'ok': true});
          }
          final chat = project.chats[rest[1]];
          if (chat == null) return (404, {'error': 'chat not found'});
          if (method == 'PATCH') chat['title'] = body['title'];
          return (200, chat);
        case 'export':
          return (200, project.export(body));
        case 'gifs':
          return (
            200,
            {
              'results': <dynamic>[],
              'providers': <dynamic>[],
              'has_more': false
            }
          );
      }
      return (200, {'ok': true, 'note': 'Demo mode: action simulated'});
    }
    if (path.contains('gif')) {
      return (
        200,
        {'results': <dynamic>[], 'providers': <dynamic>[], 'has_more': false}
      );
    }
    return (200, {'ok': true, 'note': 'Demo mode: action simulated'});
  }

  /// Scripted Director agent run, emitted as SSE events with realistic pacing.
  Stream<(String, Map<String, dynamic>, Duration)> _director(
    Map<String, dynamic> body,
  ) async* {
    final project = store.byId('${body['project_id']}') ?? store.projects.first;
    final message = '${body['message'] ?? ''}'.toLowerCase();
    final script = directorScriptFor(message, project);
    yield (
      'session',
      {'session_id': '${body['session_id'] ?? 'default'}'},
      Duration.zero
    );
    var iteration = 1;
    for (final step in script) {
      yield (
        'step',
        {'iteration': iteration, 'phase': step.tool == null ? 'think' : 'act'},
        const Duration(milliseconds: 500)
      );
      if (step.tool != null) {
        final id = 'call-${DateTime.now().microsecondsSinceEpoch}';
        yield (
          'tool_call',
          {'id': id, 'name': step.tool, 'arguments': step.args},
          const Duration(milliseconds: 350)
        );
        step.apply?.call(project);
        yield (
          'tool_result',
          {'id': id, 'name': step.tool, 'ok': true, 'output': step.output},
          const Duration(milliseconds: 900)
        );
      }
      for (final word in _chunks(step.say)) {
        yield ('text', {'delta': word}, const Duration(milliseconds: 28));
      }
      iteration++;
    }
    project.recordChat('${body['session_id'] ?? 'default'}',
        '${body['message']}', script.map((s) => s.say).join());
    yield (
      'done',
      {'reason': 'completed', 'iterations': iteration - 1},
      const Duration(milliseconds: 200)
    );
  }

  Iterable<String> _chunks(String text) sync* {
    final re = RegExp(r'\S+\s*');
    for (final m in re.allMatches(text)) {
      yield m.group(0)!;
    }
  }

  Future<ResponseBody> _sse(
    Stream<(String, Map<String, dynamic>, Duration)> events,
    Future<void>? cancelFuture,
  ) async {
    final controller = StreamController<Uint8List>();
    var cancelled = false;
    cancelFuture?.then((_) {
      cancelled = true;
      if (!controller.isClosed) controller.close();
    });
    () async {
      await for (final (event, data, delay) in events) {
        if (cancelled) return;
        await Future<void>.delayed(delay);
        if (cancelled) return;
        controller.add(
          Uint8List.fromList(
              utf8.encode('event: $event\ndata: ${jsonEncode(data)}\n\n')),
        );
      }
      if (!controller.isClosed) await controller.close();
    }();
    return ResponseBody(
      controller.stream,
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }
}

/// Builds the base URL demo builds use (never a real host).
String demoBaseUrl() => kDemoBaseUrl;
