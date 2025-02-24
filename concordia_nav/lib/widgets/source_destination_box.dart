import 'package:flutter/material.dart';
import '../../widgets/search_bar.dart';

class SourceDestinationBox extends StatelessWidget {
  final TextEditingController sourceController;
  final TextEditingController destinationController;

  const SourceDestinationBox({
    super.key,
    required this.sourceController,
    required this.destinationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SearchBarWidget(
            controller: sourceController,
            hintText: 'Your Location',
            icon: Icons.location_on,
            iconColor: Theme.of(context).primaryColor,
          ),
          SearchBarWidget(
            controller: destinationController,
            hintText: 'Enter Destination',
            icon: Icons.location_on,
            iconColor: const Color(0xFFDA3A16),
          ),
        ],
      ),
    );
  }
}
