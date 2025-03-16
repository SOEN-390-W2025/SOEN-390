import 'package:flutter/material.dart';

// Custom AppBar widget that accepts a title
PreferredSizeWidget customAppBar(BuildContext context, String title,
    {Icon? actionIcon, Function? onActionPressed}) {
  final isHomePage = ModalRoute.of(context)?.settings.name == '/HomePage';
  final isCampusMapPage =
      ModalRoute.of(context)?.settings.name == '/CampusMapPage';

  Widget leadingIcon;

  if (isHomePage) {
    leadingIcon = IconButton(
      onPressed: () {
        Navigator.pushNamed(context, '/SettingsPage');
      },
      icon: const Icon(
        Icons.settings,
        color: Colors.white,
      ),
    );
  } else if (isCampusMapPage) {
    leadingIcon = IconButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/HomePage'); // Navigate back
      },
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
    );
  } else {
    leadingIcon = IconButton(
      onPressed: () {
        Navigator.pop(context); // Navigate back
      },
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
    );
  }

  return AppBar(
    backgroundColor: Theme.of(context).primaryColor,
    title: FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          )),
    ),
    centerTitle: true,
    leading: leadingIcon,
    actions: [
      IconButton(
        onPressed: () {
          // If a custom function is provided, use it; otherwise, use the default function
          if (onActionPressed != null) {
            onActionPressed();
          } else if (isHomePage) {
            Navigator.pushNamed(context, '/SmartPlannerView');
          }
        },
        icon: actionIcon ??
            const Icon(
              Icons.edit_note,
              color: Colors.white,
            ),
      ),
    ],
  );
}
