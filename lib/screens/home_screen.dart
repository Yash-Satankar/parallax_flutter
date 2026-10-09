import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parallax_mobile/blocs/health/health_bloc.dart';
import 'package:parallax_mobile/blocs/health/health_event.dart';
import 'package:parallax_mobile/blocs/health/health_state.dart';
import 'package:parallax_mobile/blocs/projects/projects_bloc.dart';
import 'package:parallax_mobile/blocs/projects/projects_event.dart';
import 'package:parallax_mobile/blocs/projects/projects_state.dart';
import 'package:parallax_mobile/blocs/server/server_cubit.dart';
import 'package:parallax_mobile/config/theme.dart';
import 'package:parallax_mobile/widgets/motion.dart';
import 'package:parallax_mobile/data/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'All Projects',
    '4K Cinema',
    'Social 9:16',
    'Audio Masters',
    'Drafts',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverUrl = context.watch<ServerCubit>().state;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark.withValues(alpha: 0.95),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: AppTheme.shadowGlowPrimary,
              ),
              child: const Icon(Icons.movie_creation_outlined,
                  size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PARALLAX',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'AI PRODUCTION STUDIO',
                    style: AppTheme.labelSm.copyWith(
                      color: AppTheme.cyan,
                      fontSize: 8,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Live Engine Status Pill
          BlocBuilder<HealthBloc, HealthState>(
            builder: (context, state) {
              if (state is HealthLoaded) {
                return GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.success.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.success.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 110),
                          child: Text(
                            state.health.model.isNotEmpty
                                ? state.health.model
                                : 'Online',
                            style: AppTheme.labelSm
                                .copyWith(color: Colors.white, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is HealthLoading) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.cyan),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.error.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Offline',
                          style: AppTheme.labelSm
                              .copyWith(color: AppTheme.error, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                size: 20, color: Color(0xFFCBD5E1)),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.cardDark,
        onRefresh: () async {
          context.read<ProjectsBloc>().add(const ProjectsLoadRequested());
          context.read<HealthBloc>().add(const HealthCheckRequested());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Overview Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroBannerGradient,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppTheme.borderSubtleGlow, width: 1.2),
                  boxShadow: AppTheme.shadowGlowPrimary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'AI DIRECTOR STUDIO',
                            style: AppTheme.labelSm
                                .copyWith(color: Colors.white, fontSize: 9),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.dns_outlined,
                                  size: 10, color: AppTheme.cyan),
                              const SizedBox(width: 4),
                              Text(
                                serverUrl,
                                style: const TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  fontSize: 9,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Conversational Video Studio',
                      style: AppTheme.headingLg,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Direct the AI editor in natural language to cut footage, snap beat drops, search speech transcripts, and export master sequences.',
                      style: AppTheme.bodyMd
                          .copyWith(color: const Color(0xFFCBD5E1)),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('New Sequence'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _showCreateProjectModal(context),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.tune, size: 16),
                          label: const Text('Engine Settings'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: AppTheme.borderSubtle),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 1-Tap Quick Start Presets Carousel
              Text(
                'QUICK START TEMPLATES',
                style: AppTheme.labelSm
                    .copyWith(color: AppTheme.cyan, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 86,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ProjectPreset.presets.length,
                  itemBuilder: (context, index) {
                    final preset = ProjectPreset.presets[index];
                    return GestureDetector(
                      onTap: () => _showCreateProjectModal(context,
                          preselectedPreset: preset),
                      child: Container(
                        width: 156,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderSubtle),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    preset.badge,
                                    style: AppTheme.labelSm.copyWith(
                                        color: AppTheme.cyan, fontSize: 8),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward,
                                    size: 12, color: Color(0xFF64748B)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              preset.title,
                              style: AppTheme.headingSm.copyWith(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              preset.subtitle,
                              style: AppTheme.bodySm.copyWith(
                                  fontSize: 9, color: const Color(0xFF94A3B8)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Search Box & Category Filter
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search projects by title...',
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),

              const SizedBox(height: 12),

              // Category Pills
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilterIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.surfaceDark2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.borderSubtle,
                          ),
                        ),
                        child: Text(
                          _filters[index],
                          style: AppTheme.labelSm.copyWith(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Projects Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT SEQUENCES',
                    style: AppTheme.labelSm
                        .copyWith(color: const Color(0xFF94A3B8), fontSize: 10),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        size: 18, color: Color(0xFF94A3B8)),
                    onPressed: () => context
                        .read<ProjectsBloc>()
                        .add(const ProjectsLoadRequested()),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Projects Grid
              BlocConsumer<ProjectsBloc, ProjectsState>(
                listener: (context, state) {
                  if (state is ProjectCreated) {
                    context.push('/project/${state.project.id}');
                  } else if (state is ProjectsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.cardElevated,
                        content: Text(state.message,
                            style: const TextStyle(color: AppTheme.error)),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ProjectsLoading || state is ProjectsInitial) {
                    return const CardGridSkeleton(aspectRatio: 0.84);
                  }

                  if (state is ProjectsError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(Icons.cloud_off,
                                size: 48, color: AppTheme.error),
                            const SizedBox(height: 12),
                            const Text('Backend Connection Offline',
                                style: AppTheme.headingSm),
                            const SizedBox(height: 4),
                            Text(
                              state.message,
                              style: AppTheme.bodySm,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry Connection'),
                              onPressed: () {
                                context
                                    .read<ProjectsBloc>()
                                    .add(const ProjectsLoadRequested());
                                context
                                    .read<HealthBloc>()
                                    .add(const HealthCheckRequested());
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final projects = state is ProjectsLoaded
                      ? state.projects
                      : state is ProjectCreated
                          ? state.projects
                          : <ProjectRecord>[];

                  final filtered = _searchQuery.isEmpty
                      ? projects
                      : projects
                          .where((p) => p.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark2,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: AppTheme.borderSubtle),
                              ),
                              child: const Icon(Icons.movie_filter_outlined,
                                  size: 36, color: AppTheme.cyan),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No studio projects yet'
                                  : 'No matching projects',
                              style: AppTheme.headingSm,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Create a new sequence or start from a preset template.',
                              style: AppTheme.bodySm
                                  .copyWith(color: const Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Create New Sequence'),
                              onPressed: () => _showCreateProjectModal(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.84,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return StaggeredEntrance(
                        index: index,
                        child: _ProProjectCard(project: filtered[index]),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateProjectModal(BuildContext context,
      {ProjectPreset? preselectedPreset}) {
    final controller = TextEditingController(
      text:
          preselectedPreset != null ? '${preselectedPreset.title} Project' : '',
    );
    String selectedRatio = preselectedPreset?.aspectRatio ?? '16:9';
    int selectedFps = preselectedPreset?.fps ?? 30;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) {
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
                      color: Colors.grey[700],
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
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_to_photos_outlined,
                          size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('New Studio Sequence',
                            style: AppTheme.headingSm),
                        Text(
                          'PROVISION WORKSPACE TIMELINE',
                          style: AppTheme.labelSm
                              .copyWith(color: AppTheme.cyan, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Cyberpunk Teaser 2026',
                    labelText: 'Sequence Title',
                  ),
                ),
                const SizedBox(height: 16),
                Text('ASPECT RATIO PRESET',
                    style: AppTheme.labelSm
                        .copyWith(color: const Color(0xFF94A3B8))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPresetOption(
                      title: '16:9 YouTube',
                      ratio: '16:9',
                      isSelected: selectedRatio == '16:9',
                      onTap: () => setModalState(() => selectedRatio = '16:9'),
                    ),
                    const SizedBox(width: 8),
                    _buildPresetOption(
                      title: '9:16 Reel/Short',
                      ratio: '9:16',
                      isSelected: selectedRatio == '9:16',
                      onTap: () => setModalState(() => selectedRatio = '9:16'),
                    ),
                    const SizedBox(width: 8),
                    _buildPresetOption(
                      title: '1:1 Square',
                      ratio: '1:1',
                      isSelected: selectedRatio == '1:1',
                      onTap: () => setModalState(() => selectedRatio = '1:1'),
                    ),
                    const SizedBox(width: 8),
                    _buildPresetOption(
                      title: '4:5 Social',
                      ratio: '4:5',
                      isSelected: selectedRatio == '4:5',
                      onTap: () => setModalState(() => selectedRatio = '4:5'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('FRAMERATE',
                    style: AppTheme.labelSm
                        .copyWith(color: const Color(0xFF94A3B8))),
                const SizedBox(height: 8),
                Row(
                  children: [24, 30, 60].map((fps) {
                    final isSelected = selectedFps == fps;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedFps = fps),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.surfaceDark2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.borderSubtle),
                        ),
                        child: Text(
                          '$fps FPS',
                          style: AppTheme.labelSm
                              .copyWith(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(modalContext),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final name = controller.text.trim();
                          if (name.isNotEmpty) {
                            context
                                .read<ProjectsBloc>()
                                .add(ProjectCreateRequested(name));
                            Navigator.pop(modalContext);
                          }
                        },
                        child: const Text('Create Sequence'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetOption({
    required String title,
    required String ratio,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.2)
                : AppTheme.surfaceDark2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.borderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                ratio,
                style: AppTheme.headingSm.copyWith(
                  fontSize: 11,
                  color: isSelected ? AppTheme.cyan : Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title.split(' ').last,
                style: AppTheme.bodySm.copyWith(fontSize: 8),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProProjectCard extends StatelessWidget {
  final ProjectRecord project;

  const _ProProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final relativeDate = FormatUtils.formatRelativeTime(project.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: AppTheme.shadowSm,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/project/${project.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Preview Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.35),
                      AppTheme.surfaceDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.play_arrow,
                            size: 20, color: Colors.white),
                      ),
                    ),
                    // Pro Tag Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppTheme.cyan.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'STUDIO NLE',
                          style: AppTheme.monospaceCode.copyWith(fontSize: 8),
                        ),
                      ),
                    ),
                    // Context Menu
                    Positioned(
                      top: 4,
                      right: 4,
                      child: PopupMenuButton(
                        icon: const Icon(Icons.more_vert,
                            size: 16, color: Colors.white70),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Row(children: [
                              Icon(Icons.open_in_new, size: 15),
                              SizedBox(width: 8),
                              Text('Open Studio'),
                            ]),
                            onTap: () => context.push('/project/${project.id}'),
                          ),
                          PopupMenuItem(
                            child: const Row(children: [
                              Icon(Icons.delete_outline,
                                  size: 15, color: AppTheme.error),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: AppTheme.error)),
                            ]),
                            onTap: () => _confirmDelete(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Card Body Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: AppTheme.headingSm.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.video_library_outlined,
                          size: 11, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        '${project.mediaCount} items',
                        style: AppTheme.bodySm.copyWith(fontSize: 10),
                      ),
                      const Spacer(),
                      Text(
                        relativeDate,
                        style: AppTheme.bodySm.copyWith(
                            fontSize: 9, color: const Color(0xFF64748B)),
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Sequence'),
        content: Text(
          'Are you sure you want to permanently delete "${project.name}"?\n'
          'All associated media, chats, transcripts, and timeline data will be deleted.',
          style: AppTheme.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              context
                  .read<ProjectsBloc>()
                  .add(ProjectDeleteRequested(project.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
