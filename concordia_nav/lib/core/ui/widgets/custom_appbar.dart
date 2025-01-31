import 'package:flutter/material.dart';

// Custom AppBar widget that accepts a title
PreferredSizeWidget customAppBar(BuildContext context, String title) {
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
    leading: IconButton(
      onPressed: () {
        // TODO: Implement the settings page.
      },
      icon: const Icon(
        Icons.settings,
        color: Colors.white,
      ),
    ),
    actions: [
      IconButton(
        onPressed: () {
          // TODO: Implement the menu page.
        },
        icon: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
      ),
    ],
  );
}
