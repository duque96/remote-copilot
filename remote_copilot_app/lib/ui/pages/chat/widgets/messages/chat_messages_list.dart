import 'package:flutter/material.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/ui/components/chat_message_bubble.dart';
import 'package:remote_copilot_app/ui/pages/chat/widgets/messages/chat_empty_state.dart';

class ChatMessagesList extends StatelessWidget {
  const ChatMessagesList({required this.isLoading, required this.messages, required this.scrollController, required this.emptyMessage, super.key});

  final bool isLoading;
  final List<ConversationMessage> messages;
  final ScrollController scrollController;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messages.isEmpty) {
      return ChatEmptyState(message: emptyMessage);
    }

    return ListView.separated(
      controller: scrollController,
      reverse: false,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) => ChatMessageBubble(message: messages[index]),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
    );
  }
}
