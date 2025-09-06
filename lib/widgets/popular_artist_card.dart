// lib/widgets/popular_artist_card.dart
import 'package:flutter/material.dart';

class PopularArtistCard extends StatelessWidget {
  final bool isVenue;

  const PopularArtistCard({super.key, required this.isVenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.teal[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                color: isVenue ? Colors.purple[100] : Colors.amber[100],
              ),
              child: Center(
                child: isVenue
                    ? Icon(Icons.event, size: 60, color: Colors.purple[300])
                    : Icon(Icons.restaurant,
                        size: 60, color: Colors.amber[600]),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Name",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Location",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
