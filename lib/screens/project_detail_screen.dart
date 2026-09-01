import 'package:flutter/material.dart';
import 'package:parallax_mobile/screens/project_workspace_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return ProjectWorkspaceScreen(projectId: projectId, initialTab: 0);
  }
}
