import 'package:flutter/material.dart';

class HomeNavigationScaffold extends StatelessWidget {
  const HomeNavigationScaffold({required this.body, this.appBarTitle, this.centerTitle = false, this.onOpenDrawer, super.key});

  final Widget body;
  final Widget? appBarTitle;
  final bool centerTitle;
  final VoidCallback? onOpenDrawer;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            leading: onOpenDrawer == null
                ? null
                : IconButton(
                    onPressed: onOpenDrawer,
                    icon: const Icon(Icons.menu_rounded),
                    tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  ),
            forceMaterialTransparency: true,
            centerTitle: centerTitle,
            titleSpacing: centerTitle ? 0 : null,
            title: appBarTitle,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
