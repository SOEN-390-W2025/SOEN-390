import 'package:flutter/material.dart';

class AccessibilityTile extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>>? subOptions;

  const AccessibilityTile({
    required this.title,
    this.subOptions,
    super.key,
  });

  @override
  State<AccessibilityTile> createState() => _AccessibilityTileState();
}

class _AccessibilityTileState extends State<AccessibilityTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final primaryTextColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ??
                               Theme.of(context).colorScheme.onSurface.withAlpha(35);
    final cardColor = Theme.of(context).cardColor;

    return Semantics(
      container: true,
      label: widget.title + (_isExpanded ? " category expanded" : " category collapsed"),
      hint: _isExpanded ? "Tap to collapse" : "Tap to expand options",
      child: Card(
        color: cardColor,
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                color: primaryColor,
                semanticLabel: _isExpanded ? "Collapse" : "Expand",
              ),
              title: Text(
                widget.title,
                style: TextStyle(
                  color: primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              contentPadding: const EdgeInsets.all(7),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
            if (_isExpanded && widget.subOptions != null)
              ...widget.subOptions!.map(
                (option) {
                  return Semantics(
                    button: true,
                    label: "${option['title']} option",
                    hint: "Double tap to select",
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ListTile(
                        title: Text(
                          option['title'],
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_right,
                          color: primaryTextColor?.withAlpha(100),
                          semanticLabel: "Go to ${option['title']}",
                        ),
                        onTap: option.containsKey('onTap') &&
                                option['onTap'] is Function
                            ? option['onTap']
                            : () {},
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}