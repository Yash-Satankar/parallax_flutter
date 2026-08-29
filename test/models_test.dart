import 'package:flutter_test/flutter_test.dart';
import 'package:parallax_mobile/data/models.dart';

void main() {
  group('Models Serialization Tests', () {
    test('HealthStatus parses JSON correctly', () {
      final json = {
        'ok': true,
        'model': 'grok-4.6',
        'base_url': 'https://api.x.ai/v1',
        'workspace': './workspace/projects',
        'index_queue_depth': 2,
        'preview_queue_depth': 1,
      };

      final status = HealthStatus.fromJson(json);
      expect(status.ok, isTrue);
      expect(status.model, 'grok-4.6');
      expect(status.baseUrl, 'https://api.x.ai/v1');
      expect(status.indexQueueDepth, 2);
      expect(status.previewQueueDepth, 1);
    });

    test('LLMSettings parses profiles and activeId correctly', () {
      final json = {
        'active_id': 'grok',
        'base_url': 'https://api.x.ai/v1',
        'model': 'grok-4.6',
        'api_key_set': true,
        'profiles': [
          {
            'id': 'grok',
            'label': 'Grok Studio',
            'base_url': 'https://api.x.ai/v1',
            'model': 'grok-4.6',
            'api_key_set': true,
          },
          {
            'id': 'openai',
            'label': 'OpenAI GPT-4',
            'base_url': 'https://api.openai.com/v1',
            'model': 'gpt-4.1',
            'api_key_set': true,
          }
        ],
      };

      final settings = LLMSettings.fromJson(json);
      expect(settings.activeId, 'grok');
      expect(settings.profiles.length, 2);
      expect(settings.profiles[0].label, 'Grok Studio');
      expect(settings.profiles[1].model, 'gpt-4.1');
    });

    test('ProjectRecord serialization round-trip', () {
      final now = DateTime.now();
      final record = ProjectRecord(
        id: 'proj-123',
        name: 'Cinematic Teaser',
        dir: './workspace/projects/proj-123',
        createdAt: now,
        updatedAt: now,
        mediaCount: 5,
      );

      final json = record.toJson();
      final parsed = ProjectRecord.fromJson(json);

      expect(parsed.id, 'proj-123');
      expect(parsed.name, 'Cinematic Teaser');
      expect(parsed.mediaCount, 5);
    });

    test('TimelineDocument parses multi-track clips and keyframes', () {
      final json = {
        'duration': 45.5,
        'fps': 30.0,
        'width': 1920,
        'height': 1080,
        'tracks': [
          {'id': 'v1', 'label': 'Video 1', 'kind': 'video', 'locked': false, 'muted': false},
          {'id': 'a1', 'label': 'Audio 1', 'kind': 'audio', 'locked': false, 'muted': false},
        ],
        'clips': [
          {
            'id': 'clip-1',
            'name': 'intro.mp4',
            'track': 'v1',
            'kind': 'video',
            'start': 0.0,
            'duration': 12.0,
            'color': '#6366F1',
            'transform': {'opacity': 0.8},
            'audio': {'volumeDb': -2.5, 'muted': false},
          }
        ],
      };

      final doc = TimelineDocument.fromJson(json);
      expect(doc.duration, 45.5);
      expect(doc.tracks.length, 2);
      expect(doc.clips.length, 1);
      expect(doc.clips[0].name, 'intro.mp4');
      expect(doc.clips[0].transform?.opacity, 0.8);
      expect(doc.clips[0].audio?.volumeDb, -2.5);
    });

    test('ChatMessage and DirectorActivity serialize trace events', () {
      final activity = DirectorActivity(
        id: 'step-1-act',
        kind: 'tool',
        status: 'success',
        title: 'Executing run_ffmpeg',
        name: 'run_ffmpeg',
        detail: 'ffmpeg -i input.mp4 output.mp4',
      );

      final message = ChatMessage(
        id: 'msg-1',
        role: 'assistant',
        text: 'Trimmed video and placed on track V1',
        time: DateTime.now().toIso8601String(),
        trace: [activity],
      );

      final json = message.toJson();
      final parsed = ChatMessage.fromJson(json);

      expect(parsed.role, 'assistant');
      expect(parsed.trace?.length, 1);
      expect(parsed.trace?[0].name, 'run_ffmpeg');
      expect(parsed.trace?[0].status, 'success');
    });

    test('ExportRequest produces valid JSON payload', () {
      final req = ExportRequest(
        format: 'mp4',
        resolution: '4k',
        fps: 60,
        burnCaptions: true,
      );

      final json = req.toJson();
      expect(json['format'], 'mp4');
      expect(json['resolution'], '4k');
      expect(json['fps'], 60);
      expect(json['burn_captions'], isTrue);
    });
  });
}
