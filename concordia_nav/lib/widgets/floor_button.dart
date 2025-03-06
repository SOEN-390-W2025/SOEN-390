import 'package:flutter/material.dart';
import '../data/domain-model/concordia_building.dart';

class FloorButton extends StatelessWidget {
  final String floor;
  final ConcordiaBuilding building;

  const FloorButton({
    super.key,
    required this.floor,
    required this.building,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, // Ensures it looks the same as the container
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3, // Match the shadow
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/FloorChange',
            arguments: building
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 45,
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(0, 1), // Shadow position
              ),
            ],
          ),
          child: Text(
            floor,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
