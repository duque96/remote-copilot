import 'package:flutter/material.dart';

enum ChatNavigationDrawerItem { newConversation, chats, projects }

class HomeNavigationDrawer extends StatelessWidget {
  const HomeNavigationDrawer({
    required this.title,
    required this.newConversationLabel,
    required this.chatsLabel,
    required this.projectsLabel,
    required this.settingsTooltip,
    required this.selectedItem,
    this.onStartNewConversation,
    this.onOpenChats,
    this.onOpenProjects,
    this.onOpenSettings,
    super.key,
  });

  final String title;
  final String newConversationLabel;
  final String chatsLabel;
  final String projectsLabel;
  final String settingsTooltip;
  final ChatNavigationDrawerItem selectedItem;
  final Future<void> Function()? onStartNewConversation;
  final Future<void> Function()? onOpenChats;
  final Future<void> Function()? onOpenProjects;
  final Future<void> Function()? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ),
              _DrawerItem(
                icon: Icons.add_comment_outlined,
                label: newConversationLabel,
                selected: selectedItem == ChatNavigationDrawerItem.newConversation,
                onTap: onStartNewConversation == null
                    ? null
                    : () async {
                        Navigator.of(context).maybePop();
                        await onStartNewConversation!.call();
                      },
              ),
              _DrawerItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: chatsLabel,
                selected: selectedItem == ChatNavigationDrawerItem.chats,
                onTap: onOpenChats == null
                    ? null
                    : () async {
                        Navigator.of(context).maybePop();
                        await onOpenChats!.call();
                      },
              ),
              _DrawerItem(
                icon: Icons.folder_copy_outlined,
                label: projectsLabel,
                selected: selectedItem == ChatNavigationDrawerItem.projects,
                onTap: onOpenProjects == null
                    ? null
                    : () async {
                        Navigator.of(context).maybePop();
                        await onOpenProjects!.call();
                      },
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  onPressed: onOpenSettings == null
                      ? null
                      : () async {
                          Navigator.of(context).maybePop();
                          await onOpenSettings!.call();
                        },
                  icon: const Icon(Icons.settings_rounded),
                  tooltip: settingsTooltip,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.icon, required this.label, this.selected = false, this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      selectedTileColor: colorScheme.secondaryContainer,
      selectedColor: colorScheme.onSecondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap == null ? null : () => onTap!.call(),
    );
  }
}
