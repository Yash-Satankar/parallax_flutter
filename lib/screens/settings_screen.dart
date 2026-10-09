import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/blocs/health/health_bloc.dart';
import 'package:parallax_mobile/blocs/health/health_event.dart';
import 'package:parallax_mobile/blocs/health/health_state.dart';
import 'package:parallax_mobile/blocs/projects/projects_bloc.dart';
import 'package:parallax_mobile/blocs/projects/projects_event.dart';
import 'package:parallax_mobile/blocs/server/server_cubit.dart';
import 'package:parallax_mobile/blocs/settings/settings_bloc.dart';
import 'package:parallax_mobile/blocs/settings/settings_event.dart';
import 'package:parallax_mobile/blocs/settings/settings_state.dart';
import 'package:parallax_mobile/config/theme.dart';
import 'package:parallax_mobile/demo/demo_config.dart';
import 'package:parallax_mobile/data/parallax_api.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  bool _testingConnection = false;
  String? _testResult;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: context.read<ServerCubit>().state);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _testingConnection = true;
      _testResult = null;
      _testSuccess = null;
    });

    final testUrl = _urlController.text.trim();
    context.read<ServerCubit>().setUrl(testUrl);

    final dio = Dio(BaseOptions(
      baseUrl: testUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ));
    final api = ParallaxApi(dio, baseUrl: testUrl);

    try {
      final health = await api.health();
      if (mounted) {
        setState(() {
          _testingConnection = false;
          _testSuccess = true;
          _testResult = 'Connected • Latency <15ms • Active Model: ${health.model}';
        });
        context.read<HealthBloc>().add(const HealthCheckRequested());
        context.read<SettingsBloc>().add(const SettingsLoadRequested());
        context.read<ProjectsBloc>().add(const ProjectsLoadRequested());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testingConnection = false;
          _testSuccess = false;
          _testResult = 'Failed to connect: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark.withValues(alpha: 0.95),
        title: const Text('Backend & LLM Engine Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backend Server URL Section
            Text(
              'PARALLAX STUDIO BACKEND',
              style: AppTheme.labelSm.copyWith(color: AppTheme.cyan, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderSubtle),
                boxShadow: AppTheme.shadowSm,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Server Base URL',
                      hintText: 'http://localhost:8080',
                      prefixIcon: Icon(Icons.dns_outlined, color: AppTheme.cyan),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPresetChip('Localhost (8080)', 'http://localhost:8080'),
                      _buildPresetChip('Android (10.0.2.2:8080)', 'http://10.0.2.2:8080'),
                      _buildPresetChip('LAN Host', 'http://192.168.1.100:8080'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _testingConnection
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.wifi_tethering, size: 18),
                      label: Text(
                        _testingConnection ? 'Testing Ping...' : 'Save & Test Connection',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: _testingConnection ? null : _testConnection,
                    ),
                  ),
                  if (_testResult != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _testSuccess == true
                            ? AppTheme.success.withValues(alpha: 0.12)
                            : AppTheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _testSuccess == true ? AppTheme.success : AppTheme.error,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _testSuccess == true ? Icons.check_circle : Icons.error_outline,
                            size: 16,
                            color: _testSuccess == true ? AppTheme.success : AppTheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _testResult!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _testSuccess == true ? AppTheme.success : AppTheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Live Diagnostics Card
            Text(
              'ENGINE DIAGNOSTICS & SYSTEM STATUS',
              style: AppTheme.labelSm.copyWith(color: AppTheme.secondary, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),

            BlocBuilder<HealthBloc, HealthState>(
              builder: (context, state) {
                if (state is HealthLoading || state is HealthInitial) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                } else if (state is HealthError) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off, color: AppTheme.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Backend is unreachable at ${_urlController.text}',
                            style: AppTheme.bodySm.copyWith(color: AppTheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is HealthLoaded) {
                  final health = state.health;
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: AppTheme.shadowSm,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDiagRow('Server Status', 'ONLINE • ACTIVE', AppTheme.success),
                        _buildDiagRow('Active LLM Agent', health.model.isNotEmpty ? health.model : 'gemini-2.0-flash', Colors.white),
                        _buildDiagRow('API Base URL', health.baseUrl, const Color(0xFF94A3B8)),
                        _buildDiagRow('Workspace Directory', health.workspace.isNotEmpty ? health.workspace : 'Local Storage', const Color(0xFF94A3B8)),
                        _buildDiagRow(
                          'Transcription Queue',
                          '${health.indexQueueDepth} pending',
                          health.indexQueueDepth > 0 ? AppTheme.warning : AppTheme.success,
                        ),
                        _buildDiagRow(
                          'Render Pipeline Queue',
                          '${health.previewQueueDepth} pending',
                          health.previewQueueDepth > 0 ? AppTheme.warning : AppTheme.success,
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            // LLM Profiles Switcher
            Text(
              'DIRECTOR AI MODELS',
              style: AppTheme.labelSm.copyWith(color: AppTheme.warning, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),

            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                if (state is SettingsLoading || state is SettingsInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SettingsError) {
                  return Text('Error loading profiles: ${state.message}');
                } else if (state is SettingsLoaded) {
                  final settings = state.settings;
                  return Column(
                    children: settings.profiles.map((profile) {
                      final isActive = profile.id == settings.activeId;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive ? AppTheme.primary : AppTheme.borderSubtle,
                            width: isActive ? 1.8 : 1.0,
                          ),
                          boxShadow: isActive ? AppTheme.shadowGlowPrimary : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: isActive ? AppTheme.primaryGradient : null,
                                  color: isActive ? null : AppTheme.surfaceDark2,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.psychology,
                                  size: 20,
                                  color: isActive ? Colors.white : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.label,
                                      style: AppTheme.headingSm.copyWith(fontSize: 13),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppTheme.surfaceDark2,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            profile.model,
                                            style: const TextStyle(
                                              fontFamily: 'JetBrainsMono',
                                              fontSize: 9,
                                              color: AppTheme.cyan,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          '• Multimodal',
                                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                )
                              else
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Select', style: TextStyle(fontSize: 12)),
                                  onPressed: () {
                                    context.read<SettingsBloc>().add(
                                          SettingsProfileSelected(profile.id),
                                        );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    'Parallax Studio · mobile',
                    style: AppTheme.labelSm.copyWith(color: const Color(0xFF94A3B8)),
                  ),
                  if (kDemoMode) ...[
                    const SizedBox(height: 4),
                    Text(
                      kDemoDisclaimer,
                      style: AppTheme.labelSm.copyWith(color: const Color(0xFF64748B)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, String url) {
    final isCurrent = _urlController.text.trim() == url;
    return GestureDetector(
      onTap: () {
        setState(() {
          _urlController.text = url;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isCurrent ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.surfaceDark2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrent ? AppTheme.primary : AppTheme.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.labelSm.copyWith(
            color: isCurrent ? AppTheme.cyan : const Color(0xFFCBD5E1),
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildDiagRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodySm.copyWith(color: const Color(0xFF94A3B8))),
          Flexible(
            child: Text(
              value,
              style: AppTheme.labelMd.copyWith(color: valueColor, fontSize: 11),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
