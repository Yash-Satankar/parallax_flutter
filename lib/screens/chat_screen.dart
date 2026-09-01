import 'package:flutter/material.dart';
import 'package:parallax_mobile/screens/project_workspace_screen.dart';

class ChatScreen extends StatelessWidget {
  final String projectId;
  final String chatId;

  const ChatScreen({
    super.key,
    required this.projectId,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectWorkspaceScreen(projectId: projectId, initialTab: 0);
  }
}
