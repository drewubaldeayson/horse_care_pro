import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/horse_auth_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final double? elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<HorseAuthProvider>(context);

    return AppBar(
      leading: showBackButton
          ? Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      elevation: elevation ?? 4,
      actions: [
        // User profile or avatar
        if (authProvider.user != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                authProvider.userModel?.name?.substring(0, 1).toUpperCase() ??
                    'U',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ),

        // Additional actions
        ...?actions,

        // Logout option
        if (authProvider.user != null)
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
