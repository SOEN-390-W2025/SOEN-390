import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    
    return Card(
      color: cardColor,
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: primaryColor.withOpacity(0.7),
          size: 16,
        ),
        contentPadding: const EdgeInsets.all(10),
        onTap: onTap,
      ),
    );
  }
}