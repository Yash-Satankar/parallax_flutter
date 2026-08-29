import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:parallax_mobile/blocs/director/director_bloc.dart';
import 'package:parallax_mobile/blocs/director/director_event.dart';
import 'package:parallax_mobile/blocs/director/director_state.dart';
import 'package:parallax_mobile/blocs/export/export_bloc.dart';
import 'package:parallax_mobile/blocs/export/export_event.dart';
import 'package:parallax_mobile/blocs/export/export_state.dart';
import 'package:parallax_mobile/blocs/history/history_bloc.dart';
import 'package:parallax_mobile/blocs/history/history_event.dart';
import 'package:parallax_mobile/blocs/history/history_state.dart';
import 'package:parallax_mobile/blocs/media/media_bloc.dart';
import 'package:parallax_mobile/blocs/media/media_event.dart';
import 'package:parallax_mobile/blocs/media/media_state.dart';
import 'package:parallax_mobile/blocs/project_detail/project_detail_bloc.dart';
import 'package:parallax_mobile/blocs/project_detail/project_detail_event.dart';
import 'package:parallax_mobile/blocs/project_detail/project_detail_state.dart';
import 'package:parallax_mobile/blocs/timeline/timeline_bloc.dart';
import 'package:parallax_mobile/blocs/timeline/timeline_event.dart';
import 'package:parallax_mobile/blocs/timeline/timeline_state.dart';
import 'package:parallax_mobile/config/theme.dart';
import 'package:parallax_mobile/data/models.dart';
import 'package:parallax_mobile/widgets/director_trace_card.dart';
import 'package:parallax_mobile/widgets/media_preview_modal.dart';
import 'package:parallax_mobile/widgets/timeline_track_view.dart';

/// Pro Studio Project Workspace Screen housing Director AI, Media Bin, Timeline, History, & Export
class ProjectWorkspaceScreen extends StatefulWidget {
  final String projectId;
  final int initialTab;

  const ProjectWorkspaceScreen({
    Key? key,
    required this.projectId,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  State<ProjectWorkspaceScreen> createState() => _ProjectWorkspaceScreenState();
}

class _ProjectWorkspaceScreenState extends State<ProjectWorkspaceScreen> {
  late int _currentTab;
  final TextEditingController _chatInputController = TextEditingController();
  final TextEditingController _mediaSearchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<String> _quickPrompts = [
    '✨ Cut on beat drop at 12.0s',
    '🎨 Apply Cinematic Teal & Orange LUT',
    '⚡ Add 2x Speed Ramp to action clip',
    '🔍 Find vehicle chase scenes',
    '🔊 Auto-duck background music for dialog',
  ];

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    _mediaSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark.withValues(alpha: 0.95),
        title: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
          builder: (context, state) {
            if (state is ProjectDetailLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.detail.project.name,
                    style: AppTheme.headingSm.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'STUDIO WORKSPACE',
                        style: AppTheme.labelSm.copyWith(
                          color: AppTheme.cyan,
                          fontSize: 8,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return const Text('Parallax Studio');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 18, color: Color(0xFFCBD5E1)),
            onPressed: () {
              context.read<ProjectDetailBloc>().add(const ProjectDetailRefreshRequested());
              context.read<MediaBloc>().add(const MediaLoadRequested());
              context.read<TimelineBloc>().add(const TimelineRefreshRequested());
              context.read<HistoryBloc>().add(const HistoryLoadRequested());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 18, color: Color(0xFFCBD5E1)),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildDirectorChatTab(),
          _buildMediaBinTab(),
          _buildTimelineTab(),
          _buildHistoryTab(),
          _buildExportTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceDark,
          border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (index) => setState(() => _currentTab = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined),
              activeIcon: Icon(Icons.psychology),
              label: 'Director AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library_outlined),
              activeIcon: Icon(Icons.video_library),
              label: 'Media Bin',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_timeline_outlined),
              activeIcon: Icon(Icons.view_timeline),
              label: 'Timeline',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.file_download_outlined),
              activeIcon: Icon(Icons.file_download),
              label: 'Export',
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // TAB 0: Director AI Chat & Live SSE Streaming Agent
  // =============================================================

  Widget _buildDirectorChatTab() {
    return BlocBuilder<DirectorBloc, DirectorState>(
      builder: (context, chatState) {
        return Column(
          children: [
            // Chat Header with Thinking Effort Selector & Session Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceDark,
                border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 12, color: AppTheme.cyan),
                        const SizedBox(width: 6),
                        Text(
                          'Director Assistant',
                          style: AppTheme.labelSm.copyWith(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Thinking Effort Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, size: 13, color: AppTheme.warning),
                        const SizedBox(width: 4),
                        DropdownButton<String>(
                          value: chatState.thinkingEffort,
                          underline: const SizedBox.shrink(),
                          isDense: true,
                          dropdownColor: AppTheme.cardDark,
                          style: AppTheme.labelSm.copyWith(color: Colors.white, fontSize: 10),
                          items: const [
                            DropdownMenuItem(value: 'low', child: Text('Flash (Fast)')),
                            DropdownMenuItem(value: 'medium', child: Text('Medium')),
                            DropdownMenuItem(value: 'high', child: Text('Deep Reasoning')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              context.read<DirectorBloc>().add(DirectorSetThinkingEffort(val));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Message List
            Expanded(
              child: chatState.messages.isEmpty && !chatState.isStreaming
                  ? _buildChatEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: chatState.messages.length + (chatState.isStreaming ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatState.messages.length && chatState.isStreaming) {
                          return _buildStreamingMessageItem(chatState);
                        }
                        return _buildMessageItem(chatState.messages[index]);
                      },
                    ),
            ),

            // Quick Prompt Suggestions Carousel
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: AppTheme.surfaceDark,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _quickPrompts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _chatInputController.text = _quickPrompts[index].replaceFirst(RegExp(r'^[^\w]+'), '').trim();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _quickPrompts[index],
                        style: AppTheme.labelSm.copyWith(
                          color: const Color(0xFFCBD5E1),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Error banner
            if (chatState.error != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppTheme.error.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16, color: AppTheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatState.error!,
                        style: const TextStyle(color: AppTheme.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Staged Images Strip
            if (chatState.stagedImages.isNotEmpty)
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: AppTheme.surfaceDark,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chatState.stagedImages.length,
                  itemBuilder: (context, index) {
                    final img = chatState.stagedImages[index];
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.cyan),
                            image: DecorationImage(
                              image: NetworkImage(img.url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => context.read<DirectorBloc>().add(DirectorRemoveImage(index)),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // Chat Input Dock
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceDark,
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.cyan, size: 22),
                    onPressed: () => _pickChatImage(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _chatInputController,
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Ask Director to edit, search, or grade...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  chatState.isStreaming
                      ? IconButton(
                          icon: const Icon(Icons.stop_circle, color: AppTheme.error, size: 30),
                          onPressed: () => context.read<DirectorBloc>().add(const DirectorCancelStream()),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.shadowGlowPrimary,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                            onPressed: () {
                              final text = _chatInputController.text.trim();
                              if (text.isNotEmpty || chatState.stagedImages.isNotEmpty) {
                                context.read<DirectorBloc>().add(
                                      DirectorSendMessage(
                                        text,
                                        images: chatState.stagedImages.isNotEmpty
                                            ? List.from(chatState.stagedImages)
                                            : null,
                                      ),
                                    );
                                _chatInputController.clear();
                              }
                            },
                          ),
                        ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowGlowPrimary,
            ),
            child: const Icon(Icons.psychology, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('Director AI Assistant', style: AppTheme.headingMd),
          const SizedBox(height: 6),
          Text(
            'Your multimodal video co-director. Instruct the AI in plain text to cut footage, align beats, search dialogue, and apply cinematic color grades.',
            style: AppTheme.bodySm.copyWith(color: const Color(0xFF94A3B8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: isUser ? null : Border.all(color: AppTheme.borderSubtle),
          boxShadow: AppTheme.shadowSm,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.images != null && message.images!.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.images!.map((img) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: img.url,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.black26,
                        child: const Icon(Icons.image),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
            SelectableText(
              message.text,
              style: AppTheme.bodyMd.copyWith(
                color: Colors.white,
                fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                height: 1.45,
              ),
            ),
            if (message.trace != null && message.trace!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppTheme.borderSubtle),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.account_tree_outlined, size: 12, color: AppTheme.cyan),
                  const SizedBox(width: 4),
                  Text(
                    'EXECUTION TRACE (${message.trace!.length} steps)',
                    style: AppTheme.labelSm.copyWith(color: AppTheme.cyan, fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...message.trace!.map((act) => DirectorTraceCard(activity: act)),
            ],
            if (message.workedMs != null) ...[
              const SizedBox(height: 6),
              Text(
                'Elapsed: ${(message.workedMs! / 1000).toStringAsFixed(1)}s',
                style: AppTheme.bodySm.copyWith(fontSize: 9, color: const Color(0xFF64748B)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreamingMessageItem(DirectorState state) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.6)),
          boxShadow: AppTheme.shadowGlowCyan,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cyan),
                ),
                const SizedBox(width: 8),
                Text(
                  'Director is responding...',
                  style: AppTheme.labelSm.copyWith(color: AppTheme.cyan, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              state.currentStreamingText.isNotEmpty
                  ? state.currentStreamingText
                  : 'Thinking & analyzing timeline context...',
              style: AppTheme.bodyMd.copyWith(color: Colors.white),
            ),
            if (state.currentTrace.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppTheme.borderSubtle),
              const SizedBox(height: 6),
              ...state.currentTrace.map((act) => DirectorTraceCard(activity: act)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickChatImage(BuildContext context) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      final bytes = await picked.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      context.read<DirectorBloc>().add(
            DirectorAddImage(ChatImage(
              name: picked.name,
              mime: 'image/jpeg',
              url: picked.path,
              data: base64String,
            )),
          );
    }
  }

  // =============================================================
  // TAB 1: Media Bin & Semantic Search
  // =============================================================

  Widget _buildMediaBinTab() {
    return BlocBuilder<MediaBloc, MediaState>(
      builder: (context, mediaState) {
        final isSearching = mediaState is MediaLoaded && mediaState.searchQuery.isNotEmpty;
        final assets = mediaState is MediaLoaded
            ? mediaState.assets
            : mediaState is MediaUploading
                ? mediaState.existingAssets
                : mediaState is MediaError
                    ? mediaState.existingAssets
                    : <MediaAsset>[];
        final searchHits = mediaState is MediaLoaded ? mediaState.searchHits : <MediaSearchHit>[];
        final searching = mediaState is MediaLoaded && mediaState.isSearching;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Upload Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mediaSearchController,
                      decoration: InputDecoration(
                        hintText: 'Semantic search (speech, scenes, captions)...',
                        prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                        suffixIcon: isSearching
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _mediaSearchController.clear();
                                  context.read<MediaBloc>().add(const MediaSearchCleared());
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          context.read<MediaBloc>().add(MediaSearchRequested(val.trim()));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    icon: mediaState is MediaUploading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.upload_file, size: 16),
                    label: const Text('Upload'),
                    onPressed: mediaState is MediaUploading ? null : () => _showUploadPicker(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Upload error banner
              if (mediaState is MediaError) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(mediaState.message,
                      style: const TextStyle(color: AppTheme.error, fontSize: 11)),
                ),
              ],

              // Search Results
              if (isSearching) ...[
                Text('SEMANTIC MATCHES',
                    style: AppTheme.labelSm.copyWith(color: AppTheme.cyan, letterSpacing: 0.8)),
                const SizedBox(height: 8),
                if (searching)
                  const Center(child: CircularProgressIndicator(color: AppTheme.cyan))
                else if (searchHits.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No semantic matches found for your query.'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchHits.length,
                    itemBuilder: (context, index) {
                      final hit = searchHits[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.cyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.subtitles, size: 18, color: AppTheme.cyan),
                          ),
                          title: Text(hit.name ?? hit.path ?? 'Media',
                              style: AppTheme.headingSm.copyWith(fontSize: 12)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hit.spokenEn != null || hit.textEn != null)
                                Text(
                                  '"${hit.spokenEn ?? hit.textEn}"',
                                  style: AppTheme.bodySm.copyWith(color: Colors.white70),
                                ),
                              if (hit.start != null)
                                Text(
                                  'Time: ${hit.start!.toStringAsFixed(1)}s - ${hit.end?.toStringAsFixed(1)}s',
                                  style: AppTheme.monospaceCode.copyWith(fontSize: 9),
                                ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(hit.score * 100).toInt()}% match',
                              style: AppTheme.labelSm.copyWith(color: AppTheme.primary, fontSize: 9),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],

              // Media Assets Grid
              Text('MEDIA ASSETS (${assets.length})',
                  style: AppTheme.labelSm.copyWith(color: const Color(0xFF94A3B8), letterSpacing: 0.8)),
              const SizedBox(height: 8),

              if (mediaState is MediaLoading || mediaState is MediaInitial)
                const Center(child: CircularProgressIndicator())
              else if (assets.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.video_library_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No media in project bin', style: AppTheme.headingSm),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Media'),
                          onPressed: () => _showUploadPicker(context),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.84,
                  ),
                  itemCount: assets.length,
                  itemBuilder: (context, index) => _buildMediaAssetCard(context, assets[index]),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaAssetCard(BuildContext context, MediaAsset asset) {
    final mediaBloc = context.read<MediaBloc>();
    final fileUrl = mediaBloc.api.getFileUrl(widget.projectId, asset.path);
    final isVideo = asset.kind == 'video';
    final isAudio = asset.kind == 'audio';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: AppTheme.shadowSm,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => MediaPreviewModal(
              asset: asset,
              streamUrl: fileUrl,
              onDescribe: () {
                context.read<MediaBloc>().add(MediaDescribeRequested(asset.path));
              },
              onDelete: () {
                context.read<MediaBloc>().add(MediaDeleteRequested(asset.path));
                Navigator.pop(context);
              },
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isVideo ? AppTheme.primary : isAudio ? AppTheme.pink : AppTheme.cyan)
                          .withValues(alpha: 0.25),
                      AppTheme.surfaceDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        isVideo
                            ? Icons.videocam
                            : isAudio
                                ? Icons.graphic_eq
                                : Icons.image,
                        size: 32,
                        color: isVideo
                            ? AppTheme.cyan
                            : isAudio
                                ? AppTheme.pink
                                : AppTheme.secondary,
                      ),
                    ),
                    if (asset.duration > 0)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${asset.duration.toStringAsFixed(1)}s',
                            style: AppTheme.monospaceCode.copyWith(fontSize: 9, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: AppTheme.headingSm.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        asset.kind.toUpperCase(),
                        style: AppTheme.labelSm.copyWith(
                          fontSize: 9,
                          color: isVideo
                              ? AppTheme.cyan
                              : isAudio
                                  ? AppTheme.pink
                                  : AppTheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        asset.transcript?.state ?? 'ready',
                        style: AppTheme.labelSm.copyWith(fontSize: 8, color: AppTheme.success),
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

  Future<void> _showUploadPicker(BuildContext context) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      context.read<MediaBloc>().add(
            MediaUploadRequested(
              filePath: picked.path,
              fileName: picked.name,
            ),
          );
    }
  }

  // =============================================================
  // TAB 2: Multi-Track Timeline Editor
  // =============================================================

  Widget _buildTimelineTab() {
    return BlocBuilder<TimelineBloc, TimelineState>(
      builder: (context, state) {
        if (state is TimelineLoading || state is TimelineInitial) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (state is TimelineError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 40, color: AppTheme.error),
                const SizedBox(height: 8),
                Text('Failed to load timeline: ${state.message}'),
                FilledButton(
                  onPressed: () => context.read<TimelineBloc>().add(const TimelineRefreshRequested()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is TimelineLoaded) {
          final timeline = state.document;
          return Column(
            children: [
              Expanded(
                child: TimelineTrackView(
                  timeline: timeline,
                  onTimelineChanged: (updatedDoc) async {
                    await context.read<TimelineBloc>().api.updateTimeline(
                          widget.projectId,
                          updatedDoc,
                        );
                    if (mounted) {
                      context.read<TimelineBloc>().add(const TimelineRefreshRequested());
                    }
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // =============================================================
  // TAB 3: History & Revisions & Checkpoints
  // =============================================================

  Widget _buildHistoryTab() {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading || state is HistoryInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HistoryError) {
          return Center(child: Text('History error: ${state.message}'));
        }
        if (state is HistoryLoaded) {
          final history = state.history;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Undo / Redo / Checkpoint Toolbar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.undo, size: 16),
                        label: const Text('Undo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: history.canUndo
                            ? () {
                                context.read<HistoryBloc>().add(const HistoryUndoRequested());
                                context.read<TimelineBloc>().add(const TimelineRefreshRequested());
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.redo, size: 16),
                        label: const Text('Redo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: history.canRedo
                            ? () {
                                context.read<HistoryBloc>().add(const HistoryRedoRequested());
                                context.read<TimelineBloc>().add(const TimelineRefreshRequested());
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                      label: const Text('Checkpoint'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showCreateCheckpointDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Text(
                  'REVISION TIMELINE (${history.revisions.length})',
                  style: AppTheme.labelSm.copyWith(color: AppTheme.cyan, letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: history.revisions.isEmpty
                      ? const Center(child: Text('No revisions recorded yet'))
                      : ListView.builder(
                          itemCount: history.revisions.length,
                          itemBuilder: (context, index) {
                            final rev = history.revisions[index];
                            final isCurrent = rev.id == history.currentRevision;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.cardDark,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isCurrent ? AppTheme.primary : AppTheme.borderSubtle,
                                  width: isCurrent ? 1.8 : 1.0,
                                ),
                                boxShadow: isCurrent ? AppTheme.shadowGlowPrimary : null,
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isCurrent ? AppTheme.primary : AppTheme.surfaceDark2)
                                        .withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCurrent ? Icons.check : Icons.history,
                                    size: 16,
                                    color: isCurrent ? AppTheme.primary : Colors.grey,
                                  ),
                                ),
                                title: Text(rev.message, style: AppTheme.headingSm.copyWith(fontSize: 12)),
                                subtitle: Text(
                                  DateFormat('MMM d, HH:mm:ss').format(rev.timestamp),
                                  style: AppTheme.bodySm.copyWith(fontSize: 10),
                                ),
                                trailing: rev.checkpoint != null
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          rev.checkpoint!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      )
                                    : (!isCurrent
                                        ? TextButton(
                                            child: const Text('Restore', style: TextStyle(fontSize: 11)),
                                            onPressed: () {
                                              context.read<HistoryBloc>().add(
                                                    HistoryRestoreRequested(rev.id),
                                                  );
                                              context.read<TimelineBloc>().add(
                                                    const TimelineRefreshRequested(),
                                                  );
                                            },
                                          )
                                        : null),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showCreateCheckpointDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Checkpoint Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. v2.0-Teaser-Master'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<HistoryBloc>().add(HistoryCheckpointRequested(name));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Tag Version'),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // TAB 4: Export Render Studio
  // =============================================================

  Widget _buildExportTab() {
    return BlocBuilder<ExportBloc, ExportState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RENDER & EXPORT STUDIO',
                style: AppTheme.headingMd.copyWith(letterSpacing: -0.2),
              ),
              const SizedBox(height: 4),
              Text(
                'High-performance GPU/CPU hardware rendering pipeline powered by Parallax backend engine.',
                style: AppTheme.bodySm.copyWith(color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 18),

              // Format Segmented Pills
              Text('OUTPUT FORMAT', style: AppTheme.labelSm.copyWith(color: AppTheme.cyan, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'mp4', label: Text('MP4')),
                  ButtonSegment(value: 'mov', label: Text('MOV')),
                  ButtonSegment(value: 'webm', label: Text('WebM')),
                  ButtonSegment(value: 'gif', label: Text('GIF')),
                  ButtonSegment(value: 'mp3', label: Text('MP3')),
                ],
                selected: {state.format},
                onSelectionChanged: (set) => context.read<ExportBloc>().add(ExportFormatChanged(set.first)),
              ),
              const SizedBox(height: 18),

              // Resolution Segmented Pills
              Text('RESOLUTION', style: AppTheme.labelSm.copyWith(color: AppTheme.secondary, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '1080p', label: Text('1080p FHD')),
                  ButtonSegment(value: '720p', label: Text('720p HD')),
                  ButtonSegment(value: '4k', label: Text('4K UHD')),
                  ButtonSegment(value: 'source', label: Text('Source')),
                ],
                selected: {state.resolution},
                onSelectionChanged: (set) => context.read<ExportBloc>().add(ExportResolutionChanged(set.first)),
              ),
              const SizedBox(height: 18),

              // Framerate
              Text('FRAMERATE (FPS)', style: AppTheme.labelSm.copyWith(color: const Color(0xFF94A3B8), letterSpacing: 0.8)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: state.fps,
                dropdownColor: AppTheme.cardDark,
                items: const [
                  DropdownMenuItem(value: 24, child: Text('24 FPS (Cinematic Look)')),
                  DropdownMenuItem(value: 30, child: Text('30 FPS (Standard)')),
                  DropdownMenuItem(value: 60, child: Text('60 FPS (Ultra Smooth)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    context.read<ExportBloc>().add(ExportFpsChanged(val));
                  }
                },
              ),
              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: SwitchListTile(
                  title: const Text('Burn Subtitles / Captions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text('Hardcode visible captions directly into the rendered video sequence', style: TextStyle(fontSize: 11)),
                  value: state.burnCaptions,
                  activeThumbColor: AppTheme.primary,
                  onChanged: (val) => context.read<ExportBloc>().add(ExportBurnCaptionsToggled(val)),
                ),
              ),
              const SizedBox(height: 20),

              // Error
              if (state.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(state.error!, style: const TextStyle(color: AppTheme.error, fontSize: 11)),
                ),
              ],

              // Start Render Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: state.isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.movie_creation, size: 18),
                  label: Text(
                    state.isExporting ? 'Rendering Master Sequence...' : 'Start Export Render',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: state.isExporting ? null : () => context.read<ExportBloc>().add(const ExportStartRequested()),
                ),
              ),

              // Export Result
              if (state.result != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.success),
                    boxShadow: [
                      BoxShadow(color: AppTheme.success.withValues(alpha: 0.2), blurRadius: 12),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                          SizedBox(width: 8),
                          Text('Render Completed Successfully!', style: AppTheme.headingSm),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (state.result!.outputPath != null)
                        Text(
                          'File: ${state.result!.outputPath}',
                          style: AppTheme.bodySm.copyWith(color: Colors.white70),
                        ),
                      if (state.result!.downloadUrl != null) ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Download Master Render'),
                          onPressed: () {},
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
