import 'package:flutter/material.dart';
import 'package:parallax_mobile/screens/project_workspace_screen.dart';

class TimelineScreen extends StatelessWidget {
  final String projectId;

  const TimelineScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return ProjectWorkspaceScreen(projectId: projectId, initialTab: 2);
  }
}
