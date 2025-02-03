import 'package:flutter/material.dart';
import 'settings_page.dart';

// Custom AppBar widget that accepts a title
PreferredSizeWidget customAppBar(
  BuildContext context,
  String title, {
  Icon? actionIcon,
  Function? onActionPressed
  }) {
  final isHomePage = ModalRoute.of(context)?.settings.name == '/';

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
              Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return const SettingsPage();
                }),
              );
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
