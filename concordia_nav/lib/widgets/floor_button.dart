import 'package:flutter/material.dart';
import '../data/domain-model/concordia_building.dart';
import '../ui/indoor_map/floor_selection.dart';

class FloorButton extends StatelessWidget {
  final String floor;
  final ConcordiaBuilding building;
  final Function(String)? onFloorChanged;
  final String? poiName;
  final dynamic poiChoiceViewModel;

  const FloorButton({
    super.key,
    required this.floor,
    required this.building,
    this.onFloorChanged,
    this.poiName,
    this.poiChoiceViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: InkWell(
        onTap: () async {
          // Navigate to floor selection screen and await result
          final selectedFloor = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (context) => FloorSelection(
                building: building.name,
                isSearch: true,
                poiName: poiName,
                poiChoiceViewModel: poiChoiceViewModel,
              ),
            ),
          );

          // If a floor was selected and callback exists, call it
          if (selectedFloor != null && onFloorChanged != null) {
            onFloorChanged!(selectedFloor);
          }
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
                offset: Offset(0, 1),
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
