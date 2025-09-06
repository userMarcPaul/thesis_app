import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> savedItems = [
      {'title': 'Artist A', 'subtitle': 'Visual Arts'},
      {'title': 'Venue B', 'subtitle': 'Performing Arts'},
      {'title': 'Artist C', 'subtitle': 'Design'},
    ];

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savedItems.length,
        itemBuilder: (context, index) {
          final item = savedItems[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.bookmark, color: Colors.green),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['subtitle']!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => debugPrint("Tapped on ${item['title']}"),
            ),
          );
        },
      ),
    );
  }
}
