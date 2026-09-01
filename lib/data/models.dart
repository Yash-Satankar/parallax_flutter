
/// Health status returned by GET /health
class HealthStatus {
  final bool ok;
  final String model;
  final String baseUrl;
  final String workspace;
  final Map<String, dynamic>? uploads;
  final int indexQueueDepth;
  final int previewQueueDepth;

  HealthStatus({
    required this.ok,
    required this.model,
    required this.baseUrl,
    required this.workspace,
    this.uploads,
    this.indexQueueDepth = 0,
    this.previewQueueDepth = 0,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      ok: json['ok'] == true,
      model: json['model']?.toString() ?? '',
      baseUrl: json['base_url']?.toString() ?? '',
      workspace: json['workspace']?.toString() ?? '',
      uploads: json['uploads'] is Map<String, dynamic> ? json['uploads'] : null,
      indexQueueDepth: (json['index_queue_depth'] as num?)?.toInt() ?? 0,
      previewQueueDepth: (json['preview_queue_depth'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'ok': ok,
        'model': model,
        'base_url': baseUrl,
        'workspace': workspace,
        if (uploads != null) 'uploads': uploads,
        'index_queue_depth': indexQueueDepth,
        'preview_queue_depth': previewQueueDepth,
      };
}

/// LLM Profile configuration
class LLMProfile {
  final String id;
  final String label;
  final String baseUrl;
  final String model;
  final bool apiKeySet;

  LLMProfile({
    required this.id,
    required this.label,
    required this.baseUrl,
    required this.model,
    required this.apiKeySet,
  });

  factory LLMProfile.fromJson(Map<String, dynamic> json) {
    return LLMProfile(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? json['id']?.toString() ?? '',
      baseUrl: json['base_url']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      apiKeySet: json['api_key_set'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'base_url': baseUrl,
        'model': model,
        'api_key_set': apiKeySet,
      };
}

/// Settings returned by GET /v1/settings
class LLMSettings {
  final String activeId;
  final String baseUrl;
  final String model;
  final bool apiKeySet;
  final List<LLMProfile> profiles;

  LLMSettings({
    required this.activeId,
    required this.baseUrl,
    required this.model,
    required this.apiKeySet,
    required this.profiles,
  });

  factory LLMSettings.fromJson(Map<String, dynamic> json) {
    final profilesList = (json['profiles'] as List<dynamic>?)
            ?.map((p) => LLMProfile.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];
    return LLMSettings(
      activeId: json['active_id']?.toString() ?? '',
      baseUrl: json['base_url']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      apiKeySet: json['api_key_set'] == true,
      profiles: profilesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'active_id': activeId,
        'base_url': baseUrl,
        'model': model,
        'api_key_set': apiKeySet,
        'profiles': profiles.map((p) => p.toJson()).toList(),
      };
}

/// Project record
class ProjectRecord {
  final String id;
  final String name;
  final String? dir;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int mediaCount;

  ProjectRecord({
    required this.id,
    required this.name,
    this.dir,
    required this.createdAt,
    required this.updatedAt,
    this.mediaCount = 0,
  });

  factory ProjectRecord.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return ProjectRecord(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled Project',
      dir: json['dir']?.toString(),
      createdAt: parseDate(json['created_at'] ?? json['created']),
      updatedAt: parseDate(json['updated_at'] ?? json['modified_at'] ?? json['created_at']),
      mediaCount: (json['media_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (dir != null) 'dir': dir,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'media_count': mediaCount,
      };
}

/// Project detail with media list
class ProjectDetail {
  final ProjectRecord project;
  final List<MediaAsset> media;

  ProjectDetail({
    required this.project,
    required this.media,
  });

  factory ProjectDetail.fromJson(Map<String, dynamic> json) {
    final projJson = json['project'] is Map<String, dynamic>
        ? json['project'] as Map<String, dynamic>
        : json;
    final mediaList = (json['media'] as List<dynamic>?)
            ?.map((m) => MediaAsset.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];
    return ProjectDetail(
      project: ProjectRecord.fromJson(projJson),
      media: mediaList,
    );
  }
}

/// Transcript timings
class TranscriptTimings {
  final double? uploadMs;
  final double? queueMs;
  final double? extractMs;
  final double? transcribeMs;
  final double? translateMs;
  final double? describeMs;
  final double? indexMs;
  final double? totalMs;
  final bool? cached;
  final String? model;
  final String? device;

  TranscriptTimings({
    this.uploadMs,
    this.queueMs,
    this.extractMs,
    this.transcribeMs,
    this.translateMs,
    this.describeMs,
    this.indexMs,
    this.totalMs,
    this.cached,
    this.model,
    this.device,
  });

  factory TranscriptTimings.fromJson(Map<String, dynamic> json) {
    return TranscriptTimings(
      uploadMs: (json['upload_ms'] as num?)?.toDouble(),
      queueMs: (json['queue_ms'] as num?)?.toDouble(),
      extractMs: (json['extract_ms'] as num?)?.toDouble(),
      transcribeMs: (json['transcribe_ms'] as num?)?.toDouble(),
      translateMs: (json['translate_ms'] as num?)?.toDouble(),
      describeMs: (json['describe_ms'] as num?)?.toDouble(),
      indexMs: (json['index_ms'] as num?)?.toDouble(),
      totalMs: (json['total_ms'] as num?)?.toDouble(),
      cached: json['cached'] == true,
      model: json['model']?.toString(),
      device: json['device']?.toString(),
    );
  }
}

/// Status of media transcription & semantic indexing
class TranscriptIndexStatus {
  final String path;
  final String state; // queued, transcribing, translating, describing, indexing, ready, index_failed, failed, skipped
  final String? hash;
  final String? error;
  final String? progress;
  final double? at;
  final double? duration;
  final TranscriptTimings? timings;
  final bool canDescribe;
  final String? startedAt;
  final String? stageStartedAt;
  final String? updatedAt;

  TranscriptIndexStatus({
    required this.path,
    required this.state,
    this.hash,
    this.error,
    this.progress,
    this.at,
    this.duration,
    this.timings,
    this.canDescribe = false,
    this.startedAt,
    this.stageStartedAt,
    this.updatedAt,
  });

  factory TranscriptIndexStatus.fromJson(Map<String, dynamic> json) {
    return TranscriptIndexStatus(
      path: json['path']?.toString() ?? '',
      state: json['state']?.toString() ?? 'queued',
      hash: json['hash']?.toString(),
      error: json['error']?.toString(),
      progress: json['progress']?.toString(),
      at: (json['at'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toDouble(),
      timings: json['timings'] is Map<String, dynamic>
          ? TranscriptTimings.fromJson(json['timings'] as Map<String, dynamic>)
          : null,
      canDescribe: json['can_describe'] == true,
      startedAt: json['started_at']?.toString(),
      stageStartedAt: json['stage_started_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

/// Media preview generation status
class MediaPreviewStatus {
  final String path;
  final String state; // original, queued, building, ready, failed
  final String? urlPath;
  final String? posterPath;
  final List<String>? timelineFrames;
  final bool? timelinePending;
  final String? progress;
  final String? error;
  final String? reason;
  final String? codec;
  final String? encoder;
  final String? device;
  final bool? hardware;
  final String? pipeline;

  MediaPreviewStatus({
    required this.path,
    required this.state,
    this.urlPath,
    this.posterPath,
    this.timelineFrames,
    this.timelinePending,
    this.progress,
    this.error,
    this.reason,
    this.codec,
    this.encoder,
    this.device,
    this.hardware,
    this.pipeline,
  });

  factory MediaPreviewStatus.fromJson(Map<String, dynamic> json) {
    final frames = (json['timeline_frames'] as List<dynamic>?)
        ?.map((f) => f.toString())
        .toList();
    return MediaPreviewStatus(
      path: json['path']?.toString() ?? '',
      state: json['state']?.toString() ?? 'original',
      urlPath: json['url_path']?.toString(),
      posterPath: json['poster_path']?.toString(),
      timelineFrames: frames,
      timelinePending: json['timeline_pending'] == true,
      progress: json['progress']?.toString(),
      error: json['error']?.toString(),
      reason: json['reason']?.toString(),
      codec: json['codec']?.toString(),
      encoder: json['encoder']?.toString(),
      device: json['device']?.toString(),
      hardware: json['hardware'] == true,
      pipeline: json['pipeline']?.toString(),
    );
  }
}

/// Media Asset in project bin
class MediaAsset {
  final String id;
  final String name;
  final String path;
  final String kind; // video, audio, image, subtitle, file
  final String contentType;
  final String contentUrl;
  final int bytes;
  final double duration;
  final int? width;
  final int? height;
  final DateTime modifiedAt;
  final TranscriptIndexStatus? transcript;
  final MediaPreviewStatus? preview;

  MediaAsset({
    required this.id,
    required this.name,
    required this.path,
    required this.kind,
    required this.contentType,
    required this.contentUrl,
    required this.bytes,
    required this.duration,
    this.width,
    this.height,
    required this.modifiedAt,
    this.transcript,
    this.preview,
  });

  String get thumb => preview?.posterPath ?? contentUrl;
  String? get mediaType => kind;
  String? get indexState => transcript?.state;

  factory MediaAsset.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return MediaAsset(
      id: json['id']?.toString() ?? json['path']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled',
      path: json['path']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'file',
      contentType: json['content_type']?.toString() ?? '',
      contentUrl: json['content_url']?.toString() ?? '',
      bytes: (json['bytes'] as num?)?.toInt() ?? 0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      modifiedAt: parseDate(json['modified_at']),
      transcript: json['transcript'] is Map<String, dynamic>
          ? TranscriptIndexStatus.fromJson(json['transcript'] as Map<String, dynamic>)
          : null,
      preview: json['preview'] is Map<String, dynamic>
          ? MediaPreviewStatus.fromJson(json['preview'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'kind': kind,
        'content_type': contentType,
        'content_url': contentUrl,
        'bytes': bytes,
        'duration': duration,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        'modified_at': modifiedAt.toIso8601String(),
      };
}

/// Semantic search hit from Qdrant vector index
class MediaSearchHit {
  final String? path;
  final String? name;
  final String? kind;
  final double score;
  final String? textEn;
  final String? spokenEn;
  final double? start;
  final double? end;
  final String? sceneId;

  MediaSearchHit({
    this.path,
    this.name,
    this.kind,
    required this.score,
    this.textEn,
    this.spokenEn,
    this.start,
    this.end,
    this.sceneId,
  });

  factory MediaSearchHit.fromJson(Map<String, dynamic> json) {
    return MediaSearchHit(
      path: json['path']?.toString(),
      name: json['name']?.toString(),
      kind: json['kind']?.toString(),
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      textEn: json['text_en']?.toString(),
      spokenEn: json['spoken_en']?.toString(),
      start: (json['start'] as num?)?.toDouble(),
      end: (json['end'] as num?)?.toDouble(),
      sceneId: json['scene_id']?.toString(),
    );
  }
}

/// Director Activity trace item
class DirectorActivity {
  final String id;
  final String kind; // thinking, tool
  final String status; // active, success, error
  final String title;
  final String? name;
  final String? detail;
  final dynamic arguments;
  final int? iteration;
  final int? elapsedMs;
  final String? progressPhase;
  final int? progressPercent;

  DirectorActivity({
    required this.id,
    required this.kind,
    required this.status,
    required this.title,
    this.name,
    this.detail,
    this.arguments,
    this.iteration,
    this.elapsedMs,
    this.progressPhase,
    this.progressPercent,
  });

  factory DirectorActivity.fromJson(Map<String, dynamic> json) {
    return DirectorActivity(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'thinking',
      status: json['status']?.toString() ?? 'success',
      title: json['title']?.toString() ?? '',
      name: json['name']?.toString(),
      detail: json['detail']?.toString() ?? json['output']?.toString(),
      arguments: json['arguments'],
      iteration: (json['iteration'] as num?)?.toInt(),
      elapsedMs: (json['elapsedMs'] as num?)?.toInt(),
      progressPhase: json['progressPhase']?.toString(),
      progressPercent: (json['progressPercent'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'status': status,
        'title': title,
        if (name != null) 'name': name,
        if (detail != null) 'detail': detail,
        if (arguments != null) 'arguments': arguments,
        if (iteration != null) 'iteration': iteration,
      };
}

/// Attached image in Chat
class ChatImage {
  final String? name;
  final String? mime;
  final String? path;
  final String url;
  final String? data; // base64 payload

  ChatImage({
    this.name,
    this.mime,
    this.path,
    required this.url,
    this.data,
  });

  factory ChatImage.fromJson(Map<String, dynamic> json) {
    return ChatImage(
      name: json['name']?.toString(),
      mime: json['mime']?.toString(),
      path: json['path']?.toString(),
      url: json['url']?.toString() ?? '',
      data: json['data']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (mime != null) 'mime': mime,
        if (path != null) 'path': path,
        'url': url,
        if (data != null) 'data': data,
      };
}

/// Chat message
class ChatMessage {
  final String id;
  final String role; // user, assistant, system
  final String text;
  final String time;
  final List<ChatImage>? images;
  final int? workedMs;
  final List<DirectorActivity>? trace;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.time,
    this.images,
    this.workedMs,
    this.trace,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final imgList = (json['images'] as List<dynamic>?)
        ?.map((i) => ChatImage.fromJson(i as Map<String, dynamic>))
        .toList();
    final traceList = (json['trace'] as List<dynamic>?)
        ?.map((t) => DirectorActivity.fromJson(t as Map<String, dynamic>))
        .toList();
    return ChatMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: json['role']?.toString() ?? 'assistant',
      text: json['text']?.toString() ?? json['content']?.toString() ?? '',
      time: json['time']?.toString() ?? DateTime.now().toIso8601String(),
      images: imgList,
      workedMs: (json['worked_ms'] as num?)?.toInt() ?? (json['workedMs'] as num?)?.toInt(),
      trace: traceList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'text': text,
        'time': time,
        if (images != null) 'images': images!.map((i) => i.toJson()).toList(),
        if (workedMs != null) 'worked_ms': workedMs,
        if (trace != null) 'trace': trace!.map((t) => t.toJson()).toList(),
      };
}

/// Persisted Chat conversation thread
class ChatRecord {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  ChatRecord({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  factory ChatRecord.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final msgList = (json['messages'] as List<dynamic>?)
            ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];
    return ChatRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'New Director Chat',
      createdAt: parseDate(json['created_at'] ?? json['created']),
      updatedAt: parseDate(json['updated_at'] ?? json['modified_at'] ?? json['created_at']),
      messages: msgList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };
}

/// Timeline clip transform
class TimelineTransform {
  final double? x;
  final double? y;
  final double? scaleX;
  final double? scaleY;
  final double? rotation;
  final double? opacity;

  TimelineTransform({
    this.x,
    this.y,
    this.scaleX,
    this.scaleY,
    this.rotation,
    this.opacity,
  });

  factory TimelineTransform.fromJson(Map<String, dynamic> json) {
    return TimelineTransform(
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
      scaleX: (json['scaleX'] as num?)?.toDouble(),
      scaleY: (json['scaleY'] as num?)?.toDouble(),
      rotation: (json['rotation'] as num?)?.toDouble(),
      opacity: (json['opacity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (x != null) 'x': x,
        if (y != null) 'y': y,
        if (scaleX != null) 'scaleX': scaleX,
        if (scaleY != null) 'scaleY': scaleY,
        if (rotation != null) 'rotation': rotation,
        if (opacity != null) 'opacity': opacity,
      };
}

/// Timeline clip audio settings
class TimelineAudio {
  final double? volumeDb;
  final bool? muted;
  final double? pan;

  TimelineAudio({this.volumeDb, this.muted, this.pan});

  factory TimelineAudio.fromJson(Map<String, dynamic> json) {
    return TimelineAudio(
      volumeDb: (json['volumeDb'] as num?)?.toDouble(),
      muted: json['muted'] == true,
      pan: (json['pan'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (volumeDb != null) 'volumeDb': volumeDb,
        if (muted != null) 'muted': muted,
        if (pan != null) 'pan': pan,
      };
}

/// Timeline clip color grade
class TimelineColor {
  final double? exposure;
  final double? contrast;
  final double? saturation;
  final double? temperature;

  TimelineColor({this.exposure, this.contrast, this.saturation, this.temperature});

  factory TimelineColor.fromJson(Map<String, dynamic> json) {
    return TimelineColor(
      exposure: (json['exposure'] as num?)?.toDouble(),
      contrast: (json['contrast'] as num?)?.toDouble(),
      saturation: (json['saturation'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (exposure != null) 'exposure': exposure,
        if (contrast != null) 'contrast': contrast,
        if (saturation != null) 'saturation': saturation,
        if (temperature != null) 'temperature': temperature,
      };
}

/// Timeline Clip
class Clip {
  final String id;
  final String name;
  final String track;
  final String kind; // video, audio, title, caption
  final double start;
  final double duration;
  final double? sourceIn;
  final double? sourceDuration;
  final String? thumb;
  final String? src;
  final String? mediaPath;
  final String? mediaType;
  final int? width;
  final int? height;
  final String color;
  final bool enabled;
  final TimelineTransform? transform;
  final TimelineAudio? audio;
  final TimelineColor? grade;

  Clip({
    required this.id,
    required this.name,
    required this.track,
    required this.kind,
    required this.start,
    required this.duration,
    this.sourceIn,
    this.sourceDuration,
    this.thumb,
    this.src,
    this.mediaPath,
    this.mediaType,
    this.width,
    this.height,
    this.color = '#6366F1',
    this.enabled = true,
    this.transform,
    this.audio,
    this.grade,
  });

  factory Clip.fromJson(Map<String, dynamic> json) {
    return Clip(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Clip',
      track: json['track']?.toString() ?? 'v1',
      kind: json['kind']?.toString() ?? 'video',
      start: (json['start'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toDouble() ?? 1.0,
      sourceIn: (json['sourceIn'] as num?)?.toDouble(),
      sourceDuration: (json['sourceDuration'] as num?)?.toDouble(),
      thumb: json['thumb']?.toString(),
      src: json['src']?.toString(),
      mediaPath: json['mediaPath']?.toString() ?? json['media_path']?.toString(),
      mediaType: json['mediaType']?.toString() ?? json['media_type']?.toString(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      color: json['color']?.toString() ?? '#6366F1',
      enabled: json['enabled'] != false,
      transform: json['transform'] is Map<String, dynamic>
          ? TimelineTransform.fromJson(json['transform'] as Map<String, dynamic>)
          : null,
      audio: json['audio'] is Map<String, dynamic>
          ? TimelineAudio.fromJson(json['audio'] as Map<String, dynamic>)
          : null,
      grade: json['grade'] is Map<String, dynamic>
          ? TimelineColor.fromJson(json['grade'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'track': track,
        'kind': kind,
        'start': start,
        'duration': duration,
        if (sourceIn != null) 'sourceIn': sourceIn,
        if (sourceDuration != null) 'sourceDuration': sourceDuration,
        if (thumb != null) 'thumb': thumb,
        if (src != null) 'src': src,
        if (mediaPath != null) 'mediaPath': mediaPath,
        if (mediaType != null) 'mediaType': mediaType,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        'color': color,
        'enabled': enabled,
        if (transform != null) 'transform': transform!.toJson(),
        if (audio != null) 'audio': audio!.toJson(),
        if (grade != null) 'grade': grade!.toJson(),
      };
}

/// Timeline Track
class Track {
  final String id;
  final String label;
  final String kind; // video, audio, title, caption
  final bool locked;
  final bool muted;

  Track({
    required this.id,
    required this.label,
    required this.kind,
    this.locked = false,
    this.muted = false,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Track',
      kind: json['kind']?.toString() ?? 'video',
      locked: json['locked'] == true,
      muted: json['muted'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'kind': kind,
        'locked': locked,
        'muted': muted,
      };
}

/// Complete Sequence Timeline Document
class TimelineDocument {
  final double duration;
  final double fps;
  final int width;
  final int height;
  final List<Track> tracks;
  final List<Clip> clips;

  TimelineDocument({
    required this.duration,
    this.fps = 30.0,
    this.width = 1920,
    this.height = 1080,
    required this.tracks,
    required this.clips,
  });

  factory TimelineDocument.fromJson(Map<String, dynamic> json) {
    final tracksList = (json['tracks'] as List<dynamic>?)
            ?.map((t) => Track.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];
    final clipsList = (json['clips'] as List<dynamic>?)
            ?.map((c) => Clip.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];
    return TimelineDocument(
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      fps: (json['fps'] as num?)?.toDouble() ?? 30.0,
      width: (json['width'] as num?)?.toInt() ?? 1920,
      height: (json['height'] as num?)?.toInt() ?? 1080,
      tracks: tracksList,
      clips: clipsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'duration': duration,
        'fps': fps,
        'width': width,
        'height': height,
        'tracks': tracks.map((t) => t.toJson()).toList(),
        'clips': clips.map((c) => c.toJson()).toList(),
      };
}

/// Project History Revision
class RevisionRecord {
  final String id;
  final String? parent;
  final String message;
  final DateTime timestamp;
  final String? checkpoint;

  RevisionRecord({
    required this.id,
    this.parent,
    required this.message,
    required this.timestamp,
    this.checkpoint,
  });

  factory RevisionRecord.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return RevisionRecord(
      id: json['id']?.toString() ?? '',
      parent: json['parent']?.toString(),
      message: json['message']?.toString() ?? 'Timeline change',
      timestamp: parseDate(json['timestamp'] ?? json['time']),
      checkpoint: json['checkpoint']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (parent != null) 'parent': parent,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        if (checkpoint != null) 'checkpoint': checkpoint,
      };
}

/// Named Checkpoint
class CheckpointRecord {
  final String name;
  final String revisionId;
  final DateTime timestamp;

  CheckpointRecord({
    required this.name,
    required this.revisionId,
    required this.timestamp,
  });

  factory CheckpointRecord.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return CheckpointRecord(
      name: json['name']?.toString() ?? '',
      revisionId: json['revision_id']?.toString() ?? json['revisionId']?.toString() ?? '',
      timestamp: parseDate(json['timestamp']),
    );
  }
}

/// History state returned by GET /v1/projects/{id}/history
class ProjectHistory {
  final String currentRevision;
  final List<RevisionRecord> revisions;
  final List<CheckpointRecord> checkpoints;
  final bool canUndo;
  final bool canRedo;

  ProjectHistory({
    required this.currentRevision,
    required this.revisions,
    required this.checkpoints,
    required this.canUndo,
    required this.canRedo,
  });

  factory ProjectHistory.fromJson(Map<String, dynamic> json) {
    final revs = (json['revisions'] as List<dynamic>?)
            ?.map((r) => RevisionRecord.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];
    final chks = (json['checkpoints'] as List<dynamic>?)
            ?.map((c) => CheckpointRecord.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];
    return ProjectHistory(
      currentRevision: json['current_revision']?.toString() ?? json['currentRevision']?.toString() ?? '',
      revisions: revs,
      checkpoints: chks,
      canUndo: json['can_undo'] == true || json['canUndo'] == true,
      canRedo: json['can_redo'] == true || json['canRedo'] == true,
    );
  }
}

/// Export request options
class ExportRequest {
  final String format; // mp4, mov, webm, gif, mp3
  final String resolution; // 1080p, 720p, 4k, source
  final int fps;
  final String audioBitrate;
  final bool burnCaptions;

  ExportRequest({
    this.format = 'mp4',
    this.resolution = '1080p',
    this.fps = 30,
    this.audioBitrate = '192k',
    this.burnCaptions = false,
  });

  Map<String, dynamic> toJson() => {
        'format': format,
        'resolution': resolution,
        'fps': fps,
        'audio_bitrate': audioBitrate,
        'burn_captions': burnCaptions,
      };
}

/// Export response
class ExportResponse {
  final String? jobId;
  final String status;
  final String? outputPath;
  final String? downloadUrl;
  final double? progress;
  final String? error;

  ExportResponse({
    this.jobId,
    required this.status,
    this.outputPath,
    this.downloadUrl,
    this.progress,
    this.error,
  });

  factory ExportResponse.fromJson(Map<String, dynamic> json) {
    return ExportResponse(
      jobId: json['job_id']?.toString() ?? json['jobId']?.toString(),
      status: json['status']?.toString() ?? 'completed',
      outputPath: json['output_path']?.toString() ?? json['outputPath']?.toString(),
      downloadUrl: json['download_url']?.toString() ?? json['downloadUrl']?.toString(),
      progress: (json['progress'] as num?)?.toDouble(),
      error: json['error']?.toString(),
    );
  }
}

/// GIF Search Result returned by GET /v1/gifs
class GIFSearchResult {
  final String id;
  final String provider; // giphy, tenor, klipy
  final String title;
  final String url;
  final String previewUrl;
  final int width;
  final int height;
  final double duration;
  final String importRef;

  GIFSearchResult({
    required this.id,
    required this.provider,
    required this.title,
    required this.url,
    required this.previewUrl,
    required this.width,
    required this.height,
    this.duration = 0.0,
    required this.importRef,
  });

  factory GIFSearchResult.fromJson(Map<String, dynamic> json) {
    return GIFSearchResult(
      id: json['id']?.toString() ?? '',
      provider: json['provider']?.toString() ?? 'giphy',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'GIF',
      url: json['url']?.toString() ?? json['src']?.toString() ?? '',
      previewUrl: json['preview_url']?.toString() ??
          json['previewUrl']?.toString() ??
          json['url']?.toString() ??
          '',
      width: (json['width'] as num?)?.toInt() ?? 320,
      height: (json['height'] as num?)?.toInt() ?? 240,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      importRef: json['import_ref']?.toString() ??
          json['importRef']?.toString() ??
          json['url']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'provider': provider,
        'title': title,
        'url': url,
        'preview_url': previewUrl,
        'width': width,
        'height': height,
        'duration': duration,
        'import_ref': importRef,
      };
}

/// GIF Search Response with pagination
class GIFSearchResponse {
  final List<GIFSearchResult> results;
  final List<String> providers;
  final int nextOffset;
  final bool hasMore;

  GIFSearchResponse({
    required this.results,
    this.providers = const [],
    this.nextOffset = 0,
    this.hasMore = false,
  });

  factory GIFSearchResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['results'] as List<dynamic>?)
            ?.map((r) => GIFSearchResult.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];
    final provs = (json['providers'] as List<dynamic>?)
            ?.map((p) => p.toString())
            .toList() ??
        [];
    return GIFSearchResponse(
      results: list,
      providers: provs,
      nextOffset: (json['next_offset'] as num?)?.toInt() ?? 0,
      hasMore: json['has_more'] == true,
    );
  }
}

/// Predefined Studio Project Presets for Quick Start
class ProjectPreset {
  final String id;
  final String title;
  final String subtitle;
  final String aspectRatio;
  final int width;
  final int height;
  final int fps;
  final String badge;
  final String iconName;

  const ProjectPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.aspectRatio,
    required this.width,
    required this.height,
    required this.fps,
    required this.badge,
    required this.iconName,
  });

  static const List<ProjectPreset> presets = [
    ProjectPreset(
      id: 'cinema_4k',
      title: '4K Cinema',
      subtitle: '3840×2160 • 24 FPS • 16:9',
      aspectRatio: '16:9',
      width: 3840,
      height: 2160,
      fps: 24,
      badge: 'CINEMA UHD',
      iconName: 'movie',
    ),
    ProjectPreset(
      id: 'social_reels',
      title: 'Reels & Shorts',
      subtitle: '1080×1920 • 60 FPS • 9:16',
      aspectRatio: '9:16',
      width: 1080,
      height: 1920,
      fps: 60,
      badge: 'VERTICAL PRO',
      iconName: 'smartphone',
    ),
    ProjectPreset(
      id: 'podcast_square',
      title: 'Podcast & Audio',
      subtitle: '1080×1080 • 30 FPS • 1:1',
      aspectRatio: '1:1',
      width: 1080,
      height: 1080,
      fps: 30,
      badge: 'SQUARE 1:1',
      iconName: 'mic',
    ),
    ProjectPreset(
      id: 'social_portrait',
      title: 'Social Promo',
      subtitle: '1080×1350 • 30 FPS • 4:5',
      aspectRatio: '4:5',
      width: 1080,
      height: 1350,
      fps: 30,
      badge: 'FEED 4:5',
      iconName: 'video_library',
    ),
  ];
}

/// Helper formatting utilities for file sizes, timestamps, and timecodes
class FormatUtils {
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String formatTimecode(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    final ms = ((seconds - secs) * 100).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}';
  }

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 45) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

