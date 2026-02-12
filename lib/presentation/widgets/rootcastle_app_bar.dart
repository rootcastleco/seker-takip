import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Rootcastle markalı AppBar.
class RootcastleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RootcastleAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      backgroundColor: RootcastleColors.blue,
      foregroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
