import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SendMessageIntent extends Intent {
  const SendMessageIntent();
}

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    required this.inputController,
    required this.inputFocusNode,
    required this.isSending,
    required this.messageHint,
    required this.attachmentsTooltip,
    required this.sendTooltip,
    required this.onSend,
    super.key,
  });

  final TextEditingController inputController;
  final FocusNode inputFocusNode;
  final bool isSending;
  final String messageHint;
  final String attachmentsTooltip;
  final String sendTooltip;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Shortcuts(
              shortcuts: const {SingleActivator(LogicalKeyboardKey.enter): SendMessageIntent()},
              child: Actions(
                actions: {
                  SendMessageIntent: CallbackAction<SendMessageIntent>(
                    onInvoke: (_) {
                      if (!isSending) {
                        onSend();
                      }

                      return null;
                    },
                  ),
                },
                child: TextField(
                  focusNode: inputFocusNode,
                  controller: inputController,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: messageHint,
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: IconButton(onPressed: null, icon: const Icon(Icons.add), iconSize: 18, tooltip: attachmentsTooltip),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSending ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: isSending ? null : onSend,
                    icon: isSending
                        ? SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onSurfaceVariant))
                        : Icon(Icons.arrow_upward_rounded, color: theme.colorScheme.onPrimary),
                    tooltip: sendTooltip,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
