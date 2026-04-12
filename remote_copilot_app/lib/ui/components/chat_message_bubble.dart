import 'package:flutter/material.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/l10n/app_localizations.dart';
import 'package:remote_copilot_app/ui/components/animated_text_sheen.dart';
import 'package:remote_copilot_app/ui/components/copilot_markdown_view.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({required this.message, super.key});

  final ConversationMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUser = message.role == 'user';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = colorScheme.primary;
    final foregroundColor = isUser ? colorScheme.onPrimary : colorScheme.onSurface;
    final content = message.content.isEmpty && message.status == 'streaming' ? l10n.thinkingLabel : message.content;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Card(
            color: backgroundColor,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.youLabel,
                    style: TextStyle(color: foregroundColor.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(content, style: TextStyle(color: foregroundColor)),
                  if (message.error case final error?)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(error, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(999)),
                    child: Image.asset("assets/images/copilot_icon.png"),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.assistantLabel,
                    style: theme.textTheme.titleSmall?.copyWith(color: foregroundColor.withValues(alpha: 0.86), fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: message.content.isEmpty && message.status == 'streaming'
                    ? AnimatedTextSheen(
                        baseColor: foregroundColor.withValues(alpha: 0.9),
                        child: Text(content, style: theme.textTheme.bodyMedium?.copyWith(color: foregroundColor, height: 1.45)),
                      )
                    : CopilotMarkdownView(data: content, foregroundColor: foregroundColor),
              ),
              if (message.error case final error?)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(error, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
