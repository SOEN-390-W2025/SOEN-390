import 'package:flutter/material.dart';

// Custom AppBar widget that accepts a title
PreferredSizeWidget customAppBar(
  BuildContext context,
  String title, {
  Icon? actionIcon,
  Function? onActionPressed
  }) {
  bool isHomePage = ModalRoute.of(context)?.settings.name == '/';

  return AppBar(
    backgroundColor: Theme.of(context).primaryColor,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ),
    centerTitle: true,
    leading: isHomePage
        ? IconButton(
            onPressed: () {
              // TODO: Implement the settings page.
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          )
        : IconButton(
            onPressed: () {
              Navigator.pop(context); // Navigate back
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
    actions: [
      IconButton(
        onPressed: () {
          // If a custom function is provided, use it; otherwise, use the default function
          (onActionPressed ?? () {});
        },
        icon: actionIcon ?? const Icon(
          Icons.menu,
          color: Colors.white,
        ),
      ),
    ],
  );
}
