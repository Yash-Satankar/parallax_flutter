import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:parallax_mobile/config/theme.dart';
import 'package:parallax_mobile/data/models.dart';

/// Pro Multi-track NLE Sequence Timeline Widget with Interactive Editing Actions
class TimelineTrackView extends StatefulWidget {
  final TimelineDocument timeline;
  final void Function(TimelineDocument updatedTimeline)? onTimelineChanged;

  const TimelineTrackView({
    super.key,
    required this.timeline,
    this.onTimelineChanged,
  });

  @override
  State<TimelineTrackView> createState() => _TimelineTrackViewState();
}

class _TimelineTrackViewState extends State<TimelineTrackView>
    with SingleTickerProviderStateMixin {
  double _zoom = 36.0; // pixels per second
  double _playhead = 0.0; // current playhead in seconds
  bool _isPlaying = false;
  final ScrollController _scrollController = ScrollController();
  String? _selectedClipId;

  // Advances the playhead in real time while playing (preview scrub only).
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;

  double get _totalDuration =>
      widget.timeline.duration > 0 ? widget.timeline.duration : 45.0;

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    setState(() {
      _playhead += dt;
      if (_playhead >= _totalDuration) {
        _playhead = _totalDuration;
        _setPlaying(false);
      }
    });
    _followPlayhead();
  }

  void _followPlayhead() {
    if (!_scrollController.hasClients) return;
    final x = _playhead * _zoom;
    final pos = _scrollController.position;
    final view = pos.viewportDimension;
    if (x > pos.pixels + view * 0.8 || x < pos.pixels) {
      _scrollController.jumpTo(
        (x - view * 0.2).clamp(0.0, pos.maxScrollExtent),
      );
    }
  }

  void _setPlaying(bool playing) {
    _isPlaying = playing;
    if (playing) {
      if (_playhead >= _totalDuration) _playhead = 0;
      _lastTick = Duration.zero;
      if (!_ticker.isActive) _ticker.start();
    } else if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return AppTheme.cyan;
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.replaceFirst('#', ''), radix: 16) + 0xFF000000);
      }
      return AppTheme.cyan;
    } catch (_) {
      return AppTheme.cyan;
    }
  }

  void _openClipInspector(Clip clip) {
    setState(() {
      _selectedClipId = clip.id;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ClipInspectorSheet(
        clip: clip,
        onUpdate: (updatedClip) {
          final updatedClips = widget.timeline.clips.map((c) {
            return c.id == updatedClip.id ? updatedClip : c;
          }).toList();

          final updatedDoc = TimelineDocument(
            duration: widget.timeline.duration,
            fps: widget.timeline.fps,
            width: widget.timeline.width,
            height: widget.timeline.height,
            tracks: widget.timeline.tracks,
            clips: updatedClips,
          );

          widget.onTimelineChanged?.call(updatedDoc);
        },
      ),
    );
  }

  void _splitSelectedClip() {
    if (_selectedClipId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap a clip to select it for splitting')),
      );
      return;
    }

    final clipIndex = widget.timeline.clips.indexWhere((c) => c.id == _selectedClipId);
    if (clipIndex < 0) return;

    final targetClip = widget.timeline.clips[clipIndex];
    final splitTime = _playhead;

    if (splitTime <= targetClip.start || splitTime >= (targetClip.start + targetClip.duration)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Move playhead inside the selected clip to split')),
      );
      return;
    }

    final firstDuration = splitTime - targetClip.start;
    final secondDuration = targetClip.duration - firstDuration;

    final firstClip = Clip(
      id: targetClip.id,
      name: '${targetClip.name} (Part 1)',
      track: targetClip.track,
      kind: targetClip.kind,
      start: targetClip.start,
      duration: firstDuration,
      sourceIn: targetClip.sourceIn,
      sourceDuration: firstDuration,
      thumb: targetClip.thumb,
      src: targetClip.src,
      mediaPath: targetClip.mediaPath,
      mediaType: targetClip.mediaType,
      width: targetClip.width,
      height: targetClip.height,
      color: targetClip.color,
      enabled: targetClip.enabled,
      audio: targetClip.audio,
      transform: targetClip.transform,
      grade: targetClip.grade,
    );

    final secondClip = Clip(
      id: 'clip-${DateTime.now().millisecondsSinceEpoch}',
      name: '${targetClip.name} (Part 2)',
      track: targetClip.track,
      kind: targetClip.kind,
      start: splitTime,
      duration: secondDuration,
      sourceIn: (targetClip.sourceIn ?? 0.0) + firstDuration,
      sourceDuration: secondDuration,
      thumb: targetClip.thumb,
      src: targetClip.src,
      mediaPath: targetClip.mediaPath,
      mediaType: targetClip.mediaType,
      width: targetClip.width,
      height: targetClip.height,
      color: targetClip.color,
      enabled: targetClip.enabled,
      audio: targetClip.audio,
      transform: targetClip.transform,
      grade: targetClip.grade,
    );

    final updatedClips = List<Clip>.from(widget.timeline.clips);
    updatedClips[clipIndex] = firstClip;
    updatedClips.insert(clipIndex + 1, secondClip);

    final updatedDoc = TimelineDocument(
      duration: widget.timeline.duration,
      fps: widget.timeline.fps,
      width: widget.timeline.width,
      height: widget.timeline.height,
      tracks: widget.timeline.tracks,
      clips: updatedClips,
    );

    widget.onTimelineChanged?.call(updatedDoc);
    setState(() => _selectedClipId = secondClip.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clip split into two parts at playhead')),
    );
  }

  void _duplicateSelectedClip() {
    if (_selectedClipId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a clip to duplicate')),
      );
      return;
    }

    final clip = widget.timeline.clips.firstWhere((c) => c.id == _selectedClipId);
    final duplicated = Clip(
      id: 'clip-${DateTime.now().millisecondsSinceEpoch}',
      name: '${clip.name} (Copy)',
      track: clip.track,
      kind: clip.kind,
      start: clip.start + clip.duration + 0.1,
      duration: clip.duration,
      sourceIn: clip.sourceIn,
      sourceDuration: clip.sourceDuration,
      thumb: clip.thumb,
      src: clip.src,
      mediaPath: clip.mediaPath,
      mediaType: clip.mediaType,
      width: clip.width,
      height: clip.height,
      color: clip.color,
      enabled: clip.enabled,
      audio: clip.audio,
      transform: clip.transform,
      grade: clip.grade,
    );

    final updatedClips = [...widget.timeline.clips, duplicated];
    final updatedDoc = TimelineDocument(
      duration: (duplicated.start + duplicated.duration > widget.timeline.duration)
          ? duplicated.start + duplicated.duration
          : widget.timeline.duration,
      fps: widget.timeline.fps,
      width: widget.timeline.width,
      height: widget.timeline.height,
      tracks: widget.timeline.tracks,
      clips: updatedClips,
    );

    widget.onTimelineChanged?.call(updatedDoc);
    setState(() => _selectedClipId = duplicated.id);
  }

  void _deleteSelectedClip() {
    if (_selectedClipId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a clip to delete')),
      );
      return;
    }

    final updatedClips = widget.timeline.clips.where((c) => c.id != _selectedClipId).toList();
    final updatedDoc = TimelineDocument(
      duration: widget.timeline.duration,
      fps: widget.timeline.fps,
      width: widget.timeline.width,
      height: widget.timeline.height,
      tracks: widget.timeline.tracks,
      clips: updatedClips,
    );

    widget.onTimelineChanged?.call(updatedDoc);
    setState(() => _selectedClipId = null);
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = widget.timeline.duration > 0 ? widget.timeline.duration : 45.0;
    final timelineWidth = (totalDuration * _zoom).clamp(400.0, 10000.0);

    return Column(
      children: [
        // Mini Preview & HUD Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceDark,
            border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
          ),
          child: Row(
            children: [
              // Digital Timecode Display HUD
              Flexible(
                flex: 6,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.bgDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: AppTheme.cyan),
                    const SizedBox(width: 6),
                    Text(
                      FormatUtils.formatTimecode(_playhead),
                      style: AppTheme.timecodeLarge.copyWith(fontSize: 12),
                    ),
                    Text(
                      ' / ${FormatUtils.formatTimecode(totalDuration)}',
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${widget.timeline.fps.toInt()} FPS',
                  style: AppTheme.labelSm.copyWith(color: Colors.white70, fontSize: 9),
                ),
              ),
              const Spacer(),
              // Zoom Controls
              IconButton(
                icon: const Icon(Icons.zoom_out, size: 18, color: Color(0xFF94A3B8)),
                onPressed: () {
                  setState(() {
                    _zoom = (_zoom - 8.0).clamp(16.0, 80.0);
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
              SizedBox(
                width: 64,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 2,
                    activeTrackColor: AppTheme.primary,
                    inactiveTrackColor: AppTheme.surfaceDark2,
                    thumbColor: AppTheme.primary,
                  ),
                  child: Slider(
                    value: _zoom,
                    min: 16.0,
                    max: 80.0,
                    onChanged: (val) => setState(() => _zoom = val),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, size: 18, color: Color(0xFF94A3B8)),
                onPressed: () {
                  setState(() {
                    _zoom = (_zoom + 8.0).clamp(16.0, 80.0);
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ],
          ),
        ),

        // Scrollable Multi-track Surface
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Track Headers (Left sidebar)
              Container(
                width: 84,
                color: AppTheme.surfaceDark,
                child: Column(
                  children: [
                    // Time header spacer
                    Container(
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppTheme.bgDark,
                        border: Border(
                          bottom: BorderSide(color: AppTheme.borderSubtle),
                          right: BorderSide(color: AppTheme.borderSubtle),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'TRACKS',
                        style: AppTheme.labelSm.copyWith(color: const Color(0xFF64748B), fontSize: 9),
                      ),
                    ),
                    // Track Lane Labels
                    ...widget.timeline.tracks.map((track) {
                      final isAudio = track.kind == 'audio';
                      return Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppTheme.borderSubtle),
                            right: BorderSide(color: AppTheme.borderSubtle),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isAudio ? AppTheme.pink : AppTheme.cyan,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    track.label,
                                    style: AppTheme.headingSm.copyWith(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isAudio
                                        ? AppTheme.pink.withValues(alpha: 0.2)
                                        : AppTheme.cyan.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    track.kind.toUpperCase(),
                                    style: TextStyle(
                                      color: isAudio ? AppTheme.pink : AppTheme.cyan,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (track.muted)
                                  const Icon(Icons.volume_off, size: 11, color: AppTheme.error),
                                if (track.locked)
                                  const Icon(Icons.lock, size: 11, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Tracks and Clip Canvas with Magnetic Playhead
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: timelineWidth,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time ruler
                            GestureDetector(
                              onTapDown: (details) {
                                setState(() {
                                  _playhead = (details.localPosition.dx / _zoom).clamp(0.0, totalDuration);
                                });
                              },
                              child: Container(
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppTheme.bgDark,
                                  border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
                                ),
                                child: CustomPaint(
                                  size: Size(timelineWidth, 32),
                                  painter: _RulerPainter(zoom: _zoom, duration: totalDuration),
                                ),
                              ),
                            ),

                            // Track lanes
                            ...widget.timeline.tracks.map((track) {
                              final trackClips = widget.timeline.clips
                                  .where((c) => c.track == track.id)
                                  .toList();
                              final isAudio = track.kind == 'audio';

                              return Container(
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: AppTheme.bgDark,
                                  border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
                                ),
                                child: Stack(
                                  children: [
                                    ...trackClips.map((clip) {
                                      final left = clip.start * _zoom;
                                      final width = (clip.duration * _zoom).clamp(32.0, 5000.0);
                                      final clipColor = _parseColor(clip.color);
                                      final isSelected = _selectedClipId == clip.id;

                                      return Positioned(
                                        left: left,
                                        top: 5,
                                        width: width,
                                        height: 46,
                                        child: GestureDetector(
                                          onTap: () => _openClipInspector(clip),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  clipColor.withValues(alpha: isSelected ? 0.45 : 0.28),
                                                  clipColor.withValues(alpha: isSelected ? 0.35 : 0.18),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isSelected ? Colors.white : clipColor,
                                                width: isSelected ? 1.8 : 1.2,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: clipColor.withValues(alpha: 0.5),
                                                        blurRadius: 10,
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                            child: Stack(
                                              children: [
                                                // Waveform simulated texture for audio clips
                                                if (isAudio)
                                                  Positioned.fill(
                                                    child: CustomPaint(
                                                      painter: _WaveformTexturePainter(color: clipColor),
                                                    ),
                                                  ),
                                                // Clip Info
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          isAudio
                                                              ? Icons.graphic_eq
                                                              : Icons.movie_creation_outlined,
                                                          size: 11,
                                                          color: Colors.white70,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            clip.name,
                                                            style: AppTheme.headingSm.copyWith(
                                                              fontSize: 10,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w700,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${clip.duration.toStringAsFixed(1)}s',
                                                      style: AppTheme.monospaceCode.copyWith(
                                                        fontSize: 9,
                                                        color: clipColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),

                        // Glowing Magnetic Playhead Cursor
                        Positioned(
                          left: _playhead * _zoom - 6,
                          top: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            child: Column(
                              children: [
                                // Top Pin Head
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.warning,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.warning,
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                // Vertical Line
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    decoration: BoxDecoration(
                                      color: AppTheme.warning,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.warning.withValues(alpha: 0.6),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Timeline Pro Tool Deck (Bottom Action Bar)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceDark,
            border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Play/Pause Trigger
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _setPlaying(!_isPlaying)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: AppTheme.shadowGlowPrimary,
                  ),
                  child: Row(
                    children: [
                      Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 18, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        _isPlaying ? 'PAUSE' : 'PLAY',
                        style: AppTheme.labelSm.copyWith(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              _buildProToolBtn(
                icon: Icons.content_cut,
                label: 'Split',
                onTap: _splitSelectedClip,
              ),
              _buildProToolBtn(
                icon: Icons.tune,
                label: 'Inspect',
                onTap: () {
                  if (_selectedClipId != null) {
                    final clip = widget.timeline.clips.firstWhere((c) => c.id == _selectedClipId);
                    _openClipInspector(clip);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tap a clip first to inspect parameters')),
                    );
                  }
                },
              ),
              _buildProToolBtn(
                icon: Icons.copy_outlined,
                label: 'Duplicate',
                onTap: _duplicateSelectedClip,
              ),
              _buildProToolBtn(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: AppTheme.error,
                onTap: _deleteSelectedClip,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProToolBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFFE2E8F0),
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTheme.labelSm.copyWith(color: color.withValues(alpha: 0.8), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double zoom;
  final double duration;

  _RulerPainter({required this.zoom, required this.duration});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1;

    final subLinePaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 0.8;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final step = zoom > 40 ? 1 : (zoom > 20 ? 2 : 5);

    for (int sec = 0; sec <= duration.toInt() + 10; sec += step) {
      final x = sec * zoom;
      canvas.drawLine(Offset(x, 16), Offset(x, 32), linePaint);

      // Minor subdivision ticks
      if (zoom > 25) {
        canvas.drawLine(Offset(x + zoom / 2, 22), Offset(x + zoom / 2, 32), subLinePaint);
      }

      textPainter.text = TextSpan(
        text: '${sec}s',
        style: const TextStyle(
          fontFamily: 'JetBrainsMono',
          color: Color(0xFF94A3B8),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 2, 3));
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) =>
      oldDelegate.zoom != zoom || oldDelegate.duration != duration;
}

class _WaveformTexturePainter extends CustomPainter {
  final Color color;

  _WaveformTexturePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final midY = size.height / 2;
    final heights = [6, 12, 18, 10, 15, 8, 14, 20, 16, 10, 12, 18, 14, 8, 16, 12];

    for (int i = 0; i < size.width.toInt(); i += 4) {
      final h = heights[(i ~/ 4) % heights.length].toDouble();
      canvas.drawLine(Offset(i.toDouble(), midY - h / 2), Offset(i.toDouble(), midY + h / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformTexturePainter oldDelegate) => false;
}

/// Clip Inspector Sheet
class _ClipInspectorSheet extends StatefulWidget {
  final Clip clip;
  final void Function(Clip updatedClip) onUpdate;

  const _ClipInspectorSheet({required this.clip, required this.onUpdate});

  @override
  State<_ClipInspectorSheet> createState() => _ClipInspectorSheetState();
}

class _ClipInspectorSheetState extends State<_ClipInspectorSheet> {
  late double _volumeDb;
  late double _opacity;
  late double _exposure;
  late double _saturation;
  late bool _muted;

  @override
  void initState() {
    super.initState();
    _volumeDb = widget.clip.audio?.volumeDb ?? 0.0;
    _muted = widget.clip.audio?.muted ?? false;
    _opacity = widget.clip.transform?.opacity ?? 1.0;
    _exposure = widget.clip.grade?.exposure ?? 0.0;
    _saturation = widget.clip.grade?.saturation ?? 1.0;
  }

  void _applyChanges() {
    final updatedClip = Clip(
      id: widget.clip.id,
      name: widget.clip.name,
      track: widget.clip.track,
      kind: widget.clip.kind,
      start: widget.clip.start,
      duration: widget.clip.duration,
      sourceIn: widget.clip.sourceIn,
      sourceDuration: widget.clip.sourceDuration,
      thumb: widget.clip.thumb,
      src: widget.clip.src,
      mediaPath: widget.clip.mediaPath,
      mediaType: widget.clip.mediaType,
      width: widget.clip.width,
      height: widget.clip.height,
      color: widget.clip.color,
      enabled: widget.clip.enabled,
      audio: TimelineAudio(volumeDb: _volumeDb, muted: _muted),
      transform: TimelineTransform(opacity: _opacity),
      grade: TimelineColor(exposure: _exposure, saturation: _saturation),
    );

    widget.onUpdate(updatedClip);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.tune, size: 18, color: AppTheme.cyan),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.clip.name,
                      style: AppTheme.headingSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'CLIP PARAMETERS',
                      style: AppTheme.labelSm.copyWith(color: AppTheme.cyan, fontSize: 9),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: _applyChanges,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Audio Settings
          Text(
            'AUDIO GAIN (${_volumeDb.toStringAsFixed(1)} dB)',
            style: AppTheme.labelSm.copyWith(color: AppTheme.pink),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(_muted ? Icons.volume_off : Icons.volume_up,
                    color: _muted ? AppTheme.error : AppTheme.pink),
                onPressed: () => setState(() => _muted = !_muted),
              ),
              Expanded(
                child: Slider(
                  value: _volumeDb,
                  min: -24.0,
                  max: 12.0,
                  activeColor: AppTheme.pink,
                  onChanged: (val) => setState(() => _volumeDb = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Opacity
          Text(
            'OPACITY (${(_opacity * 100).toInt()}%)',
            style: AppTheme.labelSm.copyWith(color: AppTheme.secondary),
          ),
          Slider(
            value: _opacity,
            min: 0.0,
            max: 1.0,
            activeColor: AppTheme.secondary,
            onChanged: (val) => setState(() => _opacity = val),
          ),
          const SizedBox(height: 12),
          // Exposure
          Text(
            'EXPOSURE (${_exposure.toStringAsFixed(1)})',
            style: AppTheme.labelSm.copyWith(color: AppTheme.warning),
          ),
          Slider(
            value: _exposure,
            min: -2.0,
            max: 2.0,
            activeColor: AppTheme.warning,
            onChanged: (val) => setState(() => _exposure = val),
          ),
        ],
      ),
    );
  }
}
