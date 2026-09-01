import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parallax_mobile/config/theme.dart';
import 'package:parallax_mobile/data/models.dart';

/// Pro Interactive Card for Director agent thought steps and tool invocations
class DirectorTraceCard extends StatefulWidget {
  final DirectorActivity activity;

  const DirectorTraceCard({super.key, required this.activity});

  @override
  State<DirectorTraceCard> createState() => _DirectorTraceCardState();
}

class _DirectorTraceCardState extends State<DirectorTraceCard> {
  bool _expanded = false;

  IconData _getIconForTool(String? name) {
    switch (name) {
      case 'run_ffmpeg':
      case 'ffmpeg_render':
        return Icons.movie_filter_outlined;
      case 'generate_image':
        return Icons.auto_awesome;
      case 'search_gifs':
      case 'import_gif':
        return Icons.gif_box_outlined;
      case 'place_media':
      case 'modify_timeline_clips':
      case 'timeline_edit':
        return Icons.view_timeline_outlined;
      case 'analyze_audio_waveform':
      case 'analyze_audio':
        return Icons.graphic_eq;
      case 'search_web':
        return Icons.public;
      case 'download_youtube_video':
        return Icons.cloud_download_outlined;
      case 'search_transcript':
      case 'get_transcript':
      case 'add_captions':
        return Icons.subtitles_outlined;
      case 'probe_media':
      case 'inspect_file':
        return Icons.manage_search;
      default:
        return widget.activity.kind == 'thinking'
            ? Icons.psychology_outlined
            : Icons.terminal_outlined;
    }
  }

  Color _getStatusColor() {
    switch (widget.activity.status) {
      case 'active':
        return AppTheme.cyan;
      case 'success':
        return AppTheme.success;
      case 'error':
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final act = widget.activity;
    final color = _getStatusColor();
    final hasDetails = act.arguments != null || act.detail != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardElevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: act.status == 'active'
              ? color.withValues(alpha: 0.7)
              : AppTheme.borderSubtle,
          width: act.status == 'active' ? 1.4 : 1.0,
        ),
        boxShadow: act.status == 'active' ? AppTheme.shadowGlowCyan : AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: hasDetails
                ? () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: color.withValues(alpha: 0.35)),
                    ),
                    child: Icon(
                      _getIconForTool(act.name),
                      size: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.title,
                          style: AppTheme.headingSm.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (act.name != null)
                          Row(
                            children: [
                              Text(
                                act.name!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  color: AppTheme.cyan,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (act.elapsedMs != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceDark2,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${act.elapsedMs}ms',
                                    style: AppTheme.bodySm.copyWith(fontSize: 8, color: const Color(0xFF94A3B8)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (act.status == 'active')
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppTheme.cyan),
                      ),
                    )
                  else if (act.status == 'success')
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.success.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.check, size: 12, color: AppTheme.success),
                    )
                  else if (act.status == 'error')
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.close, size: 12, color: AppTheme.error),
                    ),
                  if (hasDetails) ...[
                    const SizedBox(width: 6),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16,
                      color: const Color(0xFF94A3B8),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_expanded && hasDetails) ...[
            const Divider(height: 1, color: AppTheme.borderSubtle),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (act.arguments != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.input, size: 11, color: AppTheme.cyan),
                        const SizedBox(width: 4),
                        Text(
                          'PAYLOAD',
                          style: AppTheme.labelSm.copyWith(color: AppTheme.cyan, fontSize: 9),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            final raw = act.arguments is String
                                ? act.arguments as String
                                : const JsonEncoder.withIndent('  ').convert(act.arguments);
                            Clipboard.setData(ClipboardData(text: raw));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Payload copied to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 10, color: Color(0xFF94A3B8)),
                                SizedBox(width: 3),
                                Text('Copy', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.bgDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: SelectableText(
                        act.arguments is String
                            ? act.arguments as String
                            : const JsonEncoder.withIndent('  ').convert(act.arguments),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ],
                  if (act.detail != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.output,
                          size: 11,
                          color: act.status == 'error' ? AppTheme.error : AppTheme.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'OUTPUT RESULT',
                          style: AppTheme.labelSm.copyWith(
                            color: act.status == 'error' ? AppTheme.error : AppTheme.success,
                            fontSize: 9,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: act.detail!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Output copied to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 10, color: Color(0xFF94A3B8)),
                                SizedBox(width: 3),
                                Text('Copy', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.bgDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: act.status == 'error'
                              ? AppTheme.error.withValues(alpha: 0.4)
                              : AppTheme.borderSubtle,
                        ),
                      ),
                      child: SelectableText(
                        act.detail!,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: act.status == 'error' ? const Color(0xFFFCA5A5) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
