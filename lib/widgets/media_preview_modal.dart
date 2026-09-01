import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:parallax_mobile/config/theme.dart';
import 'package:parallax_mobile/data/models.dart';
import 'package:video_player/video_player.dart';

/// Pro Modal Sheet to inspect & preview media assets with playback and technical specs
class MediaPreviewModal extends StatefulWidget {
  final MediaAsset asset;
  final String streamUrl;
  final VoidCallback? onDescribe;
  final VoidCallback? onDelete;

  const MediaPreviewModal({
    super.key,
    required this.asset,
    required this.streamUrl,
    this.onDescribe,
    this.onDelete,
  });

  @override
  State<MediaPreviewModal> createState() => _MediaPreviewModalState();
}

class _MediaPreviewModalState extends State<MediaPreviewModal> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.asset.kind == 'video' || widget.asset.kind == 'audio') {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.streamUrl),
      );
      _videoController = controller;
      await controller.initialize();
      controller.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = controller.value.isPlaying;
          });
        }
      });
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Playback stream preview offline: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String _formatDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final isAudio = asset.kind == 'audio';
    final isVideo = asset.kind == 'video';

    final mediaSubtitle = [
      asset.kind.toUpperCase(),
      FormatUtils.formatBytes(asset.bytes),
      if (asset.duration > 0) _formatDuration(asset.duration),
      if (asset.width != null) '${asset.width}x${asset.height}',
    ].join(' • ');

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isVideo
                              ? AppTheme.cyan
                              : isAudio
                                  ? AppTheme.pink
                                  : AppTheme.secondary)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (isVideo
                                ? AppTheme.cyan
                                : isAudio
                                    ? AppTheme.pink
                                    : AppTheme.secondary)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      isVideo
                          ? Icons.videocam_outlined
                          : isAudio
                              ? Icons.graphic_eq
                              : Icons.image_outlined,
                      size: 20,
                      color: isVideo
                          ? AppTheme.cyan
                          : isAudio
                              ? AppTheme.pink
                              : AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: AppTheme.headingSm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mediaSubtitle,
                          style: AppTheme.bodySm.copyWith(color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppTheme.borderSubtle),

            // Player / Preview Viewport
            Container(
              width: double.infinity,
              height: 220,
              color: AppTheme.bgDark,
              child: _buildPreviewContent(),
            ),

            // Controls if Video/Audio
            if (_videoController != null && _initialized) ...[
              VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppTheme.primary,
                  bufferedColor: Colors.white24,
                  backgroundColor: AppTheme.surfaceDark2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        size: 34,
                        color: AppTheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder(
                      valueListenable: _videoController!,
                      builder: (context, VideoPlayerValue value, child) {
                        return Text(
                          '${_formatDuration(value.position.inSeconds.toDouble())} / ${_formatDuration(value.duration.inSeconds.toDouble())}',
                          style: AppTheme.monospaceCode.copyWith(color: Colors.white, fontSize: 11),
                        );
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.replay_10, size: 20),
                      onPressed: () {
                        final pos = _videoController!.value.position;
                        _videoController!.seekTo(pos - const Duration(seconds: 10));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10, size: 20),
                      onPressed: () {
                        final pos = _videoController!.value.position;
                        _videoController!.seekTo(pos + const Duration(seconds: 10));
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Technical Specs & Transcription
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusChip(
                        label: 'TRANSCRIPT: ${(asset.transcript?.state ?? "READY").toUpperCase()}',
                        color: _getIndexColor(asset.transcript?.state),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: 'INDEX: ${(asset.preview?.state ?? "INDEXED").toUpperCase()}',
                        color: _getPreviewColor(asset.preview?.state),
                      ),
                    ],
                  ),

                  // Action Buttons
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (widget.onDescribe != null)
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.auto_awesome, size: 16),
                            label: const Text('Describe AI'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.cyan.withValues(alpha: 0.2),
                              foregroundColor: AppTheme.cyan,
                              side: const BorderSide(color: AppTheme.cyan),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onDescribe?.call();
                            },
                          ),
                        ),
                      if (widget.onDescribe != null && widget.onDelete != null)
                        const SizedBox(width: 12),
                      if (widget.onDelete != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.error,
                              side: const BorderSide(color: AppTheme.error),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onDelete?.call();
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (widget.asset.kind == 'image') {
      return CachedNetworkImage(
        imageUrl: widget.streamUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        errorWidget: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
        ),
      );
    }

    if (widget.asset.kind == 'audio') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.pink.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.pink.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.graphic_eq, size: 48, color: AppTheme.pink),
            ),
            const SizedBox(height: 12),
            Text(
              'Audio Waveform Track',
              style: AppTheme.headingSm.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_outlined, size: 36, color: Colors.grey),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_videoController != null && _initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio > 0
              ? _videoController!.value.aspectRatio
              : 16 / 9,
          child: VideoPlayer(_videoController!),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator(color: AppTheme.cyan));
  }

  Color _getIndexColor(String? state) {
    switch (state) {
      case 'ready':
        return AppTheme.success;
      case 'transcribing':
      case 'translating':
      case 'describing':
      case 'indexing':
        return AppTheme.cyan;
      case 'failed':
      case 'index_failed':
        return AppTheme.error;
      default:
        return AppTheme.success;
    }
  }

  Color _getPreviewColor(String? state) {
    switch (state) {
      case 'ready':
        return AppTheme.success;
      case 'building':
        return AppTheme.warning;
      case 'failed':
        return AppTheme.error;
      default:
        return AppTheme.cyan;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTheme.labelSm.copyWith(color: color, fontSize: 9),
      ),
    );
  }
}
