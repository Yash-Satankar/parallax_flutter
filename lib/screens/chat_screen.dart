import 'package:flutter/material.dart';
import 'package:parallax_mobile/screens/project_workspace_screen.dart';

class ChatScreen extends StatelessWidget {
  final String projectId;
  final String chatId;

  const ChatScreen({
    Key? key,
    required this.projectId,
    required this.chatId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProjectWorkspaceScreen(projectId: projectId, initialTab: 0);
  }
}
