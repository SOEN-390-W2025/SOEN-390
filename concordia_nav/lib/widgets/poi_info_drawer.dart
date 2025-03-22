import 'package:flutter/material.dart';
import '../data/domain-model/place.dart';
import '../data/services/places_service.dart';

class POIInfoDrawer extends StatelessWidget {
  final Place place;
  final VoidCallback onClose;
  final VoidCallback onDirections;

  const POIInfoDrawer({
    super.key,
    required this.place,
    required this.onClose,
    required this.onDirections,
  });

  IconData _getTravelModeIcon(TravelMode? mode) {
    if (mode == null) return Icons.directions_car;
    
    switch (mode) {
      case TravelMode.DRIVE:
        return Icons.directions_car;
      case TravelMode.WALK:
        return Icons.directions_walk;
      case TravelMode.BICYCLE:
        return Icons.directions_bike;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar for draggable UI
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          
          // Header with close button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address
                if (place.address != null) ...[
                  _buildInfoRow(
                    context: context,
                    icon: Icons.location_on,
                    text: place.address!,
                  ),
                  const SizedBox(height: 12),
                ],

                // Travel information
                if (place.distanceMeters != null || place.durationSeconds != null) ...[
                  _buildInfoRow(
                    context: context,
                    icon: _getTravelModeIcon(place.travelMode),
                    text: [
                      if (place.formattedDistance != null) place.formattedDistance!,
                      if (place.formattedDistance != null && place.formattedDuration != null) '•',
                      if (place.formattedDuration != null) place.formattedDuration!,
                    ].join(' '),
                  ),
                  const SizedBox(height: 12),
                ],

                // Rating
                if (place.rating != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${place.rating!.toStringAsFixed(1)} (${place.userRatingCount ?? 0} reviews)',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Open status
                if (place.isOpen != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: place.isOpen! ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      place.isOpen! ? 'Open now' : 'Closed',
                      style: TextStyle(
                        color: place.isOpen! ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDirections,
                        icon: const Icon(
                          Icons.directions,
                          color: Colors.white,
                        ),
                        label: const Text('Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}