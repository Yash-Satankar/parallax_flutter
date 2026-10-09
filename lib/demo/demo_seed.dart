// SAMPLE DATA for the offline demo build. Project names, media files,
// transcripts and Director replies are illustrative; no real footage is
// bundled (thumbnails are generated gradients).

import 'package:parallax_mobile/demo/demo_config.dart';

class DirectorStep {
  final String say;
  final String? tool;
  final Map<String, dynamic>? args;
  final Object? output;
  final void Function(DemoProject p)? apply;

  const DirectorStep(this.say, {this.tool, this.args, this.output, this.apply});
}

class DemoStore {
  final List<DemoProject> projects;
  String activeProfile = 'demo';

  DemoStore(this.projects);

  factory DemoStore.seeded() => DemoStore([
        DemoProject.diwali(),
        DemoProject.monsoon(),
        DemoProject.pitch(),
        DemoProject.wedding(),
      ]);

  DemoProject? byId(String id) {
    for (final p in projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  Map<String, dynamic> health() => {
        'ok': true,
        'model': 'Demo engine',
        'base_url': kDemoBaseUrl,
        'workspace': 'demo-workspace',
        'index_queue_depth': 0,
        'preview_queue_depth': 0,
      };

  Map<String, dynamic> settings() => {
        'active_id': activeProfile,
        'base_url': kDemoBaseUrl,
        'model': 'scripted-director',
        'api_key_set': false,
        'profiles': [
          {
            'id': 'demo',
            'label': 'Demo Director (offline, scripted)',
            'base_url': kDemoBaseUrl,
            'model': 'scripted-director',
            'api_key_set': false,
          },
        ],
      };

  Map<String, dynamic> createProject(String name) {
    final p = DemoProject.empty(name);
    projects.insert(0, p);
    return p.record();
  }
}

class DemoProject {
  final String id;
  String name;
  final DateTime created;
  DateTime updated;
  final List<Map<String, dynamic>> media;
  Map<String, dynamic> timeline;
  final List<Map<String, dynamic>> revisions = [];
  final List<Map<String, dynamic>> checkpoints = [];
  final Map<String, Map<String, dynamic>> chats = {};
  int _cursor = -1;
  final List<Map<String, dynamic>> _snapshots = [];

  DemoProject({
    required this.id,
    required this.name,
    required this.created,
    required this.media,
    required this.timeline,
  }) : updated = created;

  static final DateTime _now = DateTime.now();

  static Map<String, dynamic> _asset(
    String name,
    String kind,
    double duration, {
    int? w,
    int? h,
    int bytes = 0,
    String transcript = '',
  }) {
    final ct = switch (kind) {
      'video' => 'video/mp4',
      'audio' => 'audio/mpeg',
      _ => 'image/jpeg',
    };
    return {
      'id': name,
      'name': name,
      'path': 'media/$name',
      'kind': kind,
      'content_type': ct,
      'content_url': '$kDemoThumbScheme$name:$kind',
      'bytes': bytes,
      'duration': duration,
      if (w != null) 'width': w,
      if (h != null) 'height': h,
      'modified_at': _now.subtract(const Duration(days: 1)).toIso8601String(),
      if (kind != 'image')
        'transcript': {
          'path': 'media/$name',
          'state': 'ready',
          'duration': duration,
          'can_describe': true,
          'transcript_text': transcript,
        },
      'preview': {
        'path': 'media/$name',
        'state': 'ready',
        'poster_path': '$kDemoThumbScheme$name:$kind',
      },
    };
  }

  static Map<String, dynamic> _clip(
    String id,
    String name,
    String track,
    String kind,
    double start,
    double duration,
    String color, {
    String? media,
  }) =>
      {
        'id': id,
        'name': name,
        'track': track,
        'kind': kind,
        'start': start,
        'duration': duration,
        'color': color,
        'enabled': true,
        if (media != null) 'media_path': 'media/$media',
        if (media != null) 'thumb': '$kDemoThumbScheme$media:$kind',
      };

  static List<Map<String, dynamic>> _tracks() => [
        {'id': 'v2', 'label': 'Overlay', 'kind': 'video'},
        {'id': 'v1', 'label': 'Video 1', 'kind': 'video'},
        {'id': 't1', 'label': 'Titles', 'kind': 'title'},
        {'id': 'a1', 'label': 'Voiceover', 'kind': 'audio'},
        {'id': 'a2', 'label': 'Music', 'kind': 'audio'},
      ];

  factory DemoProject.diwali() {
    final p = DemoProject(
      id: 'diwali-promo',
      name: 'Diwali Sale Promo · 30s',
      created: _now.subtract(const Duration(days: 3)),
      media: [
        _asset('diya_closeup.mp4', 'video', 8.4,
            w: 1920,
            h: 1080,
            bytes: 18400000,
            transcript:
                'Light up your Diwali with our biggest festive offers.'),
        _asset('rangoli_timelapse.mp4', 'video', 12.0,
            w: 1920, h: 1080, bytes: 26100000),
        _asset('family_unboxing.mp4', 'video', 9.6,
            w: 1080,
            h: 1920,
            bytes: 21000000,
            transcript: 'This is exactly what we wanted for the new home!'),
        _asset('store_walkthrough.mp4', 'video', 15.2,
            w: 1920, h: 1080, bytes: 33500000),
        _asset('voiceover_hindi.mp3', 'audio', 28.5,
            bytes: 1100000,
            transcript:
                'Is Diwali, ghar laaiye khushiyaan. Flat 40% off, sirf is hafte.'),
        _asset('shehnai_festive_bed.mp3', 'audio', 30.0, bytes: 1200000),
        _asset('logo_lockup.png', 'image', 0, w: 1200, h: 1200, bytes: 210000),
      ],
      timeline: {
        'duration': 30.0,
        'fps': 30,
        'width': 1920,
        'height': 1080,
        'tracks': _tracks(),
        'clips': [
          _clip('c1', 'Diya close-up', 'v1', 'video', 0, 4.5, '#F59E0B',
              media: 'diya_closeup.mp4'),
          _clip('c2', 'Rangoli timelapse', 'v1', 'video', 4.5, 6.0, '#EC4899',
              media: 'rangoli_timelapse.mp4'),
          _clip('c3', 'Family unboxing', 'v1', 'video', 10.5, 7.5, '#8B5CF6',
              media: 'family_unboxing.mp4'),
          _clip('c4', 'Store walkthrough', 'v1', 'video', 18.0, 8.0, '#06B6D4',
              media: 'store_walkthrough.mp4'),
          _clip('c5', 'Logo lockup', 'v1', 'video', 26.0, 4.0, '#6366F1',
              media: 'logo_lockup.png'),
          _clip('c6', 'Sparkle overlay', 'v2', 'video', 2.0, 3.0, '#FBBF24'),
          _clip('c7', '40% OFF', 'v2', 'video', 19.5, 4.0, '#EF4444'),
          _clip('c8', 'Shubh Deepavali', 't1', 'title', 0.5, 3.5, '#F97316'),
          _clip('c9', 'Flat 40% off · this week only', 't1', 'title', 18.5, 5.0,
              '#F97316'),
          _clip('c10', 'Hindi voiceover', 'a1', 'audio', 1.0, 27.5, '#10B981',
              media: 'voiceover_hindi.mp3'),
          _clip('c11', 'Shehnai festive bed', 'a2', 'audio', 0, 30.0, '#14B8A6',
              media: 'shehnai_festive_bed.mp3'),
        ],
      },
    );
    p._seedHistory([
      'Imported 7 media files',
      'Director: built 30s rough cut from brief',
      'Director: added "Shubh Deepavali" title',
      'Trimmed rangoli timelapse to 6s',
      'Director: ducked music under voiceover',
    ]);
    p.checkpoints.add({
      'name': 'client-review-v1',
      'revision_id': p.revisions[2]['id'],
      'timestamp': _now.subtract(const Duration(days: 1)).toIso8601String(),
    });
    p.chats['default'] = {
      'id': 'default',
      'title': 'Diwali promo cut',
      'created_at': _now.subtract(const Duration(days: 2)).toIso8601String(),
      'updated_at': _now.subtract(const Duration(hours: 3)).toIso8601String(),
      'messages': [
        {
          'id': 'm1',
          'role': 'user',
          'text':
              'Make a 30 second Diwali sale promo from these clips. Hindi voiceover, festive music, end on the logo.',
          'time': _now.subtract(const Duration(days: 2)).toIso8601String(),
        },
        {
          'id': 'm2',
          'role': 'assistant',
          'text':
              'Done. I built a 30s cut: diya close-up → rangoli → family unboxing → store walkthrough, ending on the logo at 26s. The Hindi voiceover runs from 1s, the shehnai bed is ducked under it, and there are two titles: "Shubh Deepavali" and the 40% offer.',
          'time': _now.subtract(const Duration(days: 2)).toIso8601String(),
          'worked_ms': 14200,
          'trace': [
            {
              'id': 't1',
              'kind': 'tool',
              'status': 'success',
              'title': 'search_transcript succeeded',
              'name': 'search_transcript'
            },
            {
              'id': 't2',
              'kind': 'tool',
              'status': 'success',
              'title': 'place_media succeeded',
              'name': 'place_media'
            },
            {
              'id': 't3',
              'kind': 'tool',
              'status': 'success',
              'title': 'timeline_edit succeeded',
              'name': 'timeline_edit'
            },
          ],
        },
      ],
    };
    return p;
  }

  factory DemoProject.monsoon() {
    final p = DemoProject(
      id: 'monsoon-vlog',
      name: 'Mumbai Monsoon Vlog',
      created: _now.subtract(const Duration(days: 6)),
      media: [
        _asset('marine_drive_waves.mp4', 'video', 22.0,
            w: 3840, h: 2160, bytes: 98000000),
        _asset('cutting_chai_stall.mp4', 'video', 14.5,
            w: 1920,
            h: 1080,
            bytes: 31000000,
            transcript: 'Nothing beats cutting chai when it pours like this.'),
        _asset('local_train_window.mp4', 'video', 18.0,
            w: 1920, h: 1080, bytes: 40000000),
        _asset('vlog_narration.mp3', 'audio', 54.0,
            bytes: 2100000,
            transcript:
                'Mumbai in the monsoon is a different city altogether.'),
      ],
      timeline: {
        'duration': 58.0,
        'fps': 30,
        'width': 1920,
        'height': 1080,
        'tracks': _tracks(),
        'clips': [
          _clip('m1', 'Marine Drive waves', 'v1', 'video', 0, 16, '#0EA5E9',
              media: 'marine_drive_waves.mp4'),
          _clip('m2', 'Cutting chai stall', 'v1', 'video', 16, 14, '#F59E0B',
              media: 'cutting_chai_stall.mp4'),
          _clip('m3', 'Local train window', 'v1', 'video', 30, 18, '#22C55E',
              media: 'local_train_window.mp4'),
          _clip('m4', 'Mumbai · July', 't1', 'title', 1, 4, '#F97316'),
          _clip('m5', 'Narration', 'a1', 'audio', 2, 54, '#10B981',
              media: 'vlog_narration.mp3'),
        ],
      },
    );
    p._seedHistory(['Imported 4 media files', 'Rough cut', 'Added title']);
    return p;
  }

  factory DemoProject.pitch() {
    final p = DemoProject(
      id: 'pitch-blr',
      name: 'Startup Pitch · Bengaluru',
      created: _now.subtract(const Duration(days: 10)),
      media: [
        _asset('founder_interview.mp4', 'video', 95.0,
            w: 1920,
            h: 1080,
            bytes: 210000000,
            transcript:
                'We help kirana stores go digital in under ten minutes.'),
        _asset('product_screen_capture.mp4', 'video', 40.0,
            w: 1920, h: 1080, bytes: 60000000),
      ],
      timeline: {
        'duration': 90.0,
        'fps': 30,
        'width': 1920,
        'height': 1080,
        'tracks': _tracks(),
        'clips': [
          _clip('p1', 'Founder intro', 'v1', 'video', 0, 35, '#6366F1',
              media: 'founder_interview.mp4'),
          _clip('p2', 'Product demo', 'v1', 'video', 35, 30, '#06B6D4',
              media: 'product_screen_capture.mp4'),
          _clip('p3', 'Founder close', 'v1', 'video', 65, 25, '#6366F1',
              media: 'founder_interview.mp4'),
          _clip('p4', 'Lower third: Priya Rao, Founder', 't1', 'title', 3, 5,
              '#F97316'),
        ],
      },
    );
    p._seedHistory(['Imported 2 media files', 'Assembled interview cut']);
    return p;
  }

  factory DemoProject.wedding() {
    final p = DemoProject(
      id: 'wedding-jaipur',
      name: 'Wedding Highlights · Jaipur',
      created: _now.subtract(const Duration(days: 14)),
      media: [
        _asset('baraat_drone.mp4', 'video', 30.0,
            w: 3840, h: 2160, bytes: 140000000),
        _asset('pheras.mp4', 'video', 42.0, w: 1920, h: 1080, bytes: 90000000),
        _asset('sangeet_dance.mp4', 'video', 36.0,
            w: 1920, h: 1080, bytes: 80000000),
      ],
      timeline: {
        'duration': 0.0,
        'fps': 30,
        'width': 1920,
        'height': 1080,
        'tracks': _tracks(),
        'clips': <dynamic>[],
      },
    );
    p._seedHistory(['Imported 3 media files']);
    return p;
  }

  factory DemoProject.empty(String name) => DemoProject(
        id: 'p-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        created: DateTime.now(),
        media: [],
        timeline: {
          'duration': 0.0,
          'fps': 30,
          'width': 1920,
          'height': 1080,
          'tracks': _tracks(),
          'clips': <dynamic>[],
        },
      ).._seedHistory(['Created project']);

  void _seedHistory(List<String> messages) {
    for (var i = 0; i < messages.length; i++) {
      _push(messages[i], created.add(Duration(hours: i * 3 + 1)));
    }
  }

  void _push(String message, [DateTime? at]) {
    // Drop redo branch.
    if (_cursor < revisions.length - 1) {
      revisions.removeRange(_cursor + 1, revisions.length);
      _snapshots.removeRange(_cursor + 1, _snapshots.length);
    }
    final id = 'r${revisions.length + 1}';
    revisions.add({
      'id': id,
      'parent': revisions.isEmpty ? null : revisions.last['id'],
      'message': message,
      'timestamp': (at ?? DateTime.now()).toIso8601String(),
    });
    _snapshots.add(_copy(timeline));
    _cursor = revisions.length - 1;
    updated = at ?? DateTime.now();
  }

  static Map<String, dynamic> _copy(Map<String, dynamic> t) => {
        ...t,
        'tracks': [
          for (final x in t['tracks'] as List)
            Map<String, dynamic>.from(x as Map)
        ],
        'clips': [
          for (final x in t['clips'] as List)
            Map<String, dynamic>.from(x as Map)
        ],
      };

  Map<String, dynamic> record() => {
        'id': id,
        'name': name,
        'dir': 'projects/$id',
        'created_at': created.toIso8601String(),
        'updated_at': updated.toIso8601String(),
        'media_count': media.length,
      };

  Map<String, dynamic> detail() => {'project': record(), 'media': media};

  List<Map<String, dynamic>> search(String q) {
    final query = q.toLowerCase();
    final hits = <Map<String, dynamic>>[];
    for (final m in media) {
      final text = '${(m['transcript'] as Map?)?['transcript_text'] ?? ''}';
      final name = '${m['name']}';
      if (query.isEmpty ||
          text.toLowerCase().contains(query) ||
          name.toLowerCase().contains(query)) {
        hits.add({
          'path': m['path'],
          'name': name,
          'kind': m['kind'],
          'score': 0.82,
          'text_en': text.isEmpty ? 'Visual match: $name' : text,
          'spoken_en': text.isEmpty ? null : text,
          'start': 1.2,
          'end': 4.8,
        });
      }
    }
    return hits;
  }

  void addUpload() {
    final n = media.length + 1;
    media.add(_asset('upload_$n.mp4', 'video', 6.0,
        w: 1080, h: 1920, bytes: 9000000));
    updated = DateTime.now();
  }

  void saveTimeline(Map<String, dynamic> body) {
    if (body['clips'] is! List) return;
    timeline = _copy({...timeline, ...body});
    _push('Edited timeline');
  }

  void undo() {
    if (_cursor <= 0) return;
    _cursor--;
    timeline = _copy(_snapshots[_cursor]);
  }

  void redo() {
    if (_cursor >= revisions.length - 1) return;
    _cursor++;
    timeline = _copy(_snapshots[_cursor]);
  }

  void restore(String revisionId) {
    final i = revisions.indexWhere((r) => r['id'] == revisionId);
    if (i < 0) return;
    _cursor = i;
    timeline = _copy(_snapshots[i]);
  }

  Map<String, dynamic> history() => {
        'current_revision': revisions.isEmpty ? '' : revisions[_cursor]['id'],
        'revisions': [
          for (final r in revisions)
            {
              ...r,
              if (checkpoints.any((c) => c['revision_id'] == r['id']))
                'checkpoint': checkpoints
                    .firstWhere((c) => c['revision_id'] == r['id'])['name'],
            },
        ],
        'checkpoints': checkpoints,
        'can_undo': _cursor > 0,
        'can_redo': _cursor < revisions.length - 1,
      };

  Map<String, dynamic> addCheckpoint(String name) {
    final c = {
      'name': name,
      'revision_id': revisions.isEmpty ? '' : revisions[_cursor]['id'],
      'timestamp': DateTime.now().toIso8601String(),
    };
    checkpoints.add(c);
    return c;
  }

  Map<String, dynamic> newChat(String title) {
    final id = 'chat-${DateTime.now().millisecondsSinceEpoch}';
    final c = {
      'id': id,
      'title': title,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'messages': <dynamic>[],
    };
    chats[id] = c;
    return c;
  }

  void recordChat(String chatId, String user, String assistant) {
    final chat = chats.putIfAbsent(
      chatId,
      () => {
        'id': chatId,
        'title': 'Director chat',
        'created_at': DateTime.now().toIso8601String(),
        'messages': <dynamic>[],
      },
    );
    final now = DateTime.now().toIso8601String();
    chat['messages'] = List<dynamic>.from(chat['messages'] as List)
      ..addAll([
        {'id': 'u$now', 'role': 'user', 'text': user, 'time': now},
        {'id': 'a$now', 'role': 'assistant', 'text': assistant, 'time': now},
      ]);
    chat['updated_at'] = now;
  }

  Map<String, dynamic> export(Map<String, dynamic> req) {
    final fmt = '${req['format'] ?? 'mp4'}';
    final res = '${req['resolution'] ?? '1080p'}';
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return {
      'job_id': 'job-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'completed',
      'output_path': 'exports/${slug}_$res.$fmt',
      'progress': 1.0,
    };
  }

  void ensureTrack(String id, String label) {
    final tracks = List<dynamic>.from(timeline['tracks'] as List);
    if (tracks.any((t) => (t as Map)['id'] == id)) return;
    final at = tracks.indexWhere((t) => (t as Map)['id'] == 't1');
    tracks.insert(at < 0 ? tracks.length : at + 1, {
      'id': id,
      'label': label,
      'kind': 'title',
    });
    timeline['tracks'] = tracks;
  }

  /// Adds the clip the Director "creates" and records a revision.
  void directorAdd(Map<String, dynamic> clip, String message) {
    final clips = List<dynamic>.from(timeline['clips'] as List)
      ..removeWhere((c) => (c as Map)['id'] == clip['id'])
      ..add(clip);
    timeline['clips'] = clips;
    final end = (clip['start'] as double) + (clip['duration'] as double);
    if (end > (timeline['duration'] as num).toDouble()) {
      timeline['duration'] = end;
    }
    _push('Director: $message');
  }
}

/// Picks a scripted Director run based on keywords in the user's message.
List<DirectorStep> directorScriptFor(String message, DemoProject p) {
  if (message.contains('caption') || message.contains('subtitle')) {
    return [
      const DirectorStep('Let me read the voiceover transcript first. '),
      const DirectorStep(
        'I found 3 spoken lines. ',
        tool: 'get_transcript',
        args: {'path': 'media/voiceover_hindi.mp3'},
        output: {'segments': 3, 'language': 'hi'},
      ),
      DirectorStep(
        'Captions are on a new track, timed to the voiceover, in Hindi with English below. ',
        tool: 'add_captions',
        args: {
          'track': 'c1',
          'style': 'bold-bottom',
          'languages': ['hi', 'en']
        },
        output: {'captions': 3},
        apply: (p) => p
          ..ensureTrack('c1', 'Captions')
          ..directorAdd(
            DemoProject._clip('cap1', 'Captions (hi + en)', 'c1', 'caption',
                1.0, 27.0, '#E879F9'),
            'added captions',
          ),
      ),
      const DirectorStep('Open the Timeline tab to review them.'),
    ];
  }
  if (message.contains('short') ||
      message.contains('reel') ||
      message.contains('15')) {
    return [
      const DirectorStep(
          'A 15-second vertical reel works best with the strongest beats only. '),
      const DirectorStep(
        'I picked the diya close-up, the unboxing reaction and the offer card. ',
        tool: 'search_transcript',
        args: {'query': 'offer reaction'},
        output: {'hits': 2},
      ),
      DirectorStep(
        'I added a 9:16 reframe pass to the overlay track so you can compare. ',
        tool: 'modify_timeline_clips',
        args: {'aspect': '9:16', 'target_duration': 15},
        output: {'clips_changed': 3},
        apply: (p) => p.directorAdd(
          DemoProject._clip(
              'reel1', '9:16 reframe pass', 'v2', 'video', 0, 15.0, '#A855F7'),
          'added 9:16 reframe pass',
        ),
      ),
      const DirectorStep('Export it as a vertical MP4 from the Export tab.'),
    ];
  }
  return [
    const DirectorStep('Looking at the current cut and the music first. '),
    const DirectorStep(
      'The shehnai bed peaks at 12.4s and 24.8s; I will cut on those beats. ',
      tool: 'analyze_audio',
      args: {'path': 'media/shehnai_festive_bed.mp3'},
      output: {
        'beats': [4.1, 8.3, 12.4, 16.6, 20.7, 24.8]
      },
    ),
    DirectorStep(
      'I added a "Shop now" end card on the titles track at 26s, and snapped the store walkthrough to the 12.4s beat. ',
      tool: 'timeline_edit',
      args: {'add': 'title', 'text': 'Shop now · link in bio', 'at': 26.0},
      output: {'ok': true},
      apply: (p) => p.directorAdd(
        DemoProject._clip('end1', 'Shop now · link in bio', 't1', 'title', 26.0,
            4.0, '#22D3EE'),
        'added end card',
      ),
    ),
    const DirectorStep('Want captions for the voiceover too? Just ask.'),
  ];
}
