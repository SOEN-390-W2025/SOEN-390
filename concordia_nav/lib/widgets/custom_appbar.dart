import 'package:flutter/material.dart';

// Custom AppBar widget that accepts a title
PreferredSizeWidget customAppBar(BuildContext context, String title,
    {Icon? actionIcon, Function? onActionPressed}) {
  final isHomePage = ModalRoute.of(context)?.settings.name == '/HomePage';
  final isCampusMapPage =
      ModalRoute.of(context)?.settings.name == '/CampusMapPage';

  // Get theme colors
  final primaryColor = Theme.of(context).primaryColor;
  final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
  
  Widget leadingIcon;

  if (isHomePage) {
    leadingIcon = IconButton(
      onPressed: () {
        Navigator.pushNamed(context, '/SettingsPage');
      },
      icon: Icon(
        Icons.settings,
        color: onPrimaryColor,
      ),
    );
  } else if (isCampusMapPage) {
    leadingIcon = IconButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/HomePage'); // Navigate back
      },
      icon: Icon(
        Icons.arrow_back,
        color: onPrimaryColor,
      ),
    );
  } else {
    leadingIcon = IconButton(
      onPressed: () {
        Navigator.pop(context); // Navigate back
      },
      icon: Icon(
        Icons.arrow_back,
        color: onPrimaryColor,
      ),
    );
  }

  return PreferredSize(
    preferredSize: const Size.fromHeight(56.0),
    child: Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).toInt()),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: primaryColor,
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            title,
            style: TextStyle(
              color: onPrimaryColor,
              fontSize: 20,
            ),
          ),
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
                Icon(
                  Icons.edit_note,
                  color: onPrimaryColor,
                ),
          ),
        ],
        elevation: 0,
      ),
    ),
  );
}