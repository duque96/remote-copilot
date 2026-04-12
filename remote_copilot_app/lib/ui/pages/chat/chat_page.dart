import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/domain/model/workspace_definition.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/l10n/app_localizations.dart';
import 'package:remote_copilot_app/ui/components/chat_message_bubble.dart';
import 'package:remote_copilot_app/ui/pages/chat/chat_page_controller.dart';
import 'package:remote_copilot_app/ui/pages/chat/chat_page_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({required this.repository, required this.sessionBundle, this.workspace, super.key});

  final RemoteCopilotRepository repository;
  final WorkspaceDefinition? workspace;
  final RemoteSessionBundle sessionBundle;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _SendMessageIntent extends Intent {
  const _SendMessageIntent();
}

class _ChatPageState extends State<ChatPage> {
  static const _autoScrollThreshold = 120.0;

  late final ChatPageController _controller;
  late final TextEditingController _inputController;
  late final FocusNode _inputFocusNode;
  late final ScrollController _messagesScrollController;
  int _lastRenderedMessageCount = 0;
  String _lastRenderedTailSignature = '';

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _inputFocusNode = FocusNode();
    _messagesScrollController = ScrollController();
    _lastRenderedMessageCount = widget.sessionBundle.conversation.messages.length;
    _lastRenderedTailSignature = _buildTailSignature(widget.sessionBundle.conversation.messages);
    _controller = ChatPageController(repository: widget.repository, workspace: widget.workspace, sessionBundle: widget.sessionBundle)..initialize();
  }

  @override
  void dispose() {
    _messagesScrollController.dispose();
    _inputFocusNode.dispose();
    _inputController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendCurrentMessage() async {
    final content = _inputController.text;
    _inputController.clear();
    await _controller.sendMessage(content);
  }

  void _maybeScrollToBottom(ChatPageState state) {
    final hasNewMessage = state.messages.length > _lastRenderedMessageCount;
    final tailSignature = _buildTailSignature(state.messages);
    final hasTailChanged = tailSignature != _lastRenderedTailSignature;

    _lastRenderedMessageCount = state.messages.length;
    _lastRenderedTailSignature = tailSignature;

    if (!hasNewMessage && !hasTailChanged) {
      return;
    }

    final isNearBottom =
        !_messagesScrollController.hasClients ||
        (_messagesScrollController.position.maxScrollExtent - _messagesScrollController.position.pixels) <= _autoScrollThreshold;
    if (!isNearBottom) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_messagesScrollController.hasClients) {
        return;
      }

      final position = _messagesScrollController.position;
      _messagesScrollController.animateTo(position.maxScrollExtent, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    });
  }

  String _buildTailSignature(List<ConversationMessage> messages) {
    if (messages.isEmpty) {
      return 'empty';
    }

    final last = messages.last;
    return '${last.id}|${last.status}|${last.content.length}|${last.error ?? ''}';
  }

  String _buildModelLabel(CopilotModelOption model) {
    final multiplier = model.multiplier;
    if (multiplier == null) {
      return model.name;
    }

    return '${model.name} (x${_formatMultiplier(multiplier)})';
  }

  String _formatMultiplier(double multiplier) {
    return multiplier == multiplier.roundToDouble()
        ? multiplier.toStringAsFixed(0)
        : multiplier.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  Widget _buildMessagesList(ChatPageState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.separated(
      controller: _messagesScrollController,
      reverse: false,
      padding: const EdgeInsets.all(16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return ChatMessageBubble(message: message);
      },
      separatorBuilder: (_, _) => const SizedBox(height: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        final l10n = AppLocalizations.of(context)!;
        final isCompact = MediaQuery.sizeOf(context).width < 600;
        final workspaceTitle = state.workspace?.name ?? l10n.generalConversationTitle;
        final workspaceSubtitle = state.workspace?.mountedPath ?? l10n.generalConversationDescription;
        _maybeScrollToBottom(state);

        return Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workspaceTitle),
                Text(workspaceSubtitle, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(child: _buildMessagesList(state)),
                if (state.errorMessage case final error?)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(error, style: TextStyle(color: Colors.red.shade700)),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(isCompact ? 20 : 24),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    padding: EdgeInsets.fromLTRB(isCompact ? 12 : 14, isCompact ? 12 : 14, isCompact ? 12 : 14, isCompact ? 10 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Shortcuts(
                          shortcuts: const {SingleActivator(LogicalKeyboardKey.enter): _SendMessageIntent()},
                          child: Actions(
                            actions: {
                              _SendMessageIntent: CallbackAction<_SendMessageIntent>(
                                onInvoke: (_) {
                                  if (!state.isSending) {
                                    _sendCurrentMessage();
                                  }

                                  return null;
                                },
                              ),
                            },
                            child: TextField(
                              focusNode: _inputFocusNode,
                              controller: _inputController,
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 6,
                              textInputAction: TextInputAction.newline,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: l10n.messageInputHint,
                                hintStyle: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isCompact ? 10 : 14),
                        Row(
                          children: [
                            Container(
                              width: isCompact ? 34 : 36,
                              height: isCompact ? 34 : 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                              ),
                              child: IconButton(onPressed: null, icon: const Icon(Icons.add), iconSize: 18, tooltip: l10n.attachmentsComingSoon),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: isCompact ? 34 : 36,
                                padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: state.selectedModel,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                                    selectedItemBuilder: (context) {
                                      return state.availableModels
                                          .map(
                                            (model) => Row(
                                              children: [
                                                const Icon(Icons.auto_awesome, size: 16),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _buildModelLabel(model),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: Theme.of(context).textTheme.bodyMedium,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList();
                                    },
                                    items: state.availableModels
                                        .map(
                                          (model) => DropdownMenuItem<String>(
                                            value: model.id,
                                            child: Text(_buildModelLabel(model), overflow: TextOverflow.ellipsis),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: state.isSending
                                        ? null
                                        : (value) {
                                            if (value == null || value == state.selectedModel) {
                                              return;
                                            }

                                            _controller.selectModel(value);
                                          },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: isCompact ? 38 : 42,
                              height: isCompact ? 38 : 42,
                              decoration: BoxDecoration(
                                color: state.isSending
                                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                                    : Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: state.isSending ? null : _sendCurrentMessage,
                                icon: state.isSending
                                    ? SizedBox.square(
                                        dimension: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      )
                                    : Icon(Icons.arrow_upward_rounded, color: Theme.of(context).colorScheme.onPrimary),
                                tooltip: l10n.sendTooltip,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
