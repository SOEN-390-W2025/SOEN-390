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
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              _isExpanded
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
            ),
            title: Text(widget.title),
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
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: Text(
                      option['title'],
                      style: const TextStyle(
                        color: Color.fromARGB(255, 110, 110, 110),
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Color.fromARGB(255, 110, 110, 110),
                    ),
                    onTap: option.containsKey('onTap') &&
                            option['onTap'] is Function
                        ? option['onTap']
                        : () {},
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
