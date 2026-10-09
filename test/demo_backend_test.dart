import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parallax_mobile/data/models.dart';
import 'package:parallax_mobile/data/parallax_api.dart';
import 'package:parallax_mobile/demo/demo_backend.dart';
import 'package:parallax_mobile/demo/demo_config.dart';

ParallaxApi _api() {
  final dio = Dio(BaseOptions(baseUrl: kDemoBaseUrl))
    ..httpClientAdapter = DemoBackendAdapter();
  return ParallaxApi(dio, baseUrl: kDemoBaseUrl);
}

void main() {
  test('projects, media and timeline parse through the real client', () async {
    final api = _api();
    final projects = await api.listProjects();
    expect(projects, hasLength(4));
    final id = projects.first.id;
    expect(await api.listMedia(id), isNotEmpty);
    final tl = await api.getTimeline(id);
    expect(tl.tracks, isNotEmpty);
    expect(tl.clips, isNotEmpty);
  });

  test('Director SSE run edits the timeline and records history', () async {
    final api = _api();
    final id = (await api.listProjects()).first.id;
    final before = (await api.getTimeline(id)).clips.length;
    final text = StringBuffer();
    String? doneReason;
    await api.streamAgentChat(
      projectId: id,
      message: 'add captions',
      sessionId: 'default',
      callbacks: AgentChatCallbacks(
        onText: text.write,
        onDone: (r, _) => doneReason = r,
      ),
    );
    expect(doneReason, 'completed');
    expect(text.toString(), contains('Captions'));
    expect((await api.getTimeline(id)).clips.length, before + 1);
    final history = await api.getHistory(id);
    expect(history.revisions.last.message, contains('captions'));
    expect(history.canUndo, isTrue);
  });

  test('export returns a completed job', () async {
    final api = _api();
    final id = (await api.listProjects()).first.id;
    final res = await api.exportProject(id, ExportRequest(format: 'mp4'));
    expect(res.status, 'completed');
    expect(res.outputPath, endsWith('.mp4'));
  });
}
