import 'package:flutter/material.dart';

class IndoorSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final Color iconColor;
  final Function(String)? onChanged;

  const IndoorSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.iconColor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: iconColor),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
