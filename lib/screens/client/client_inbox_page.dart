import 'package:flutter/material.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> messages = [
      {'title': 'Booking Confirmed', 'subtitle': 'Your booking with Artist A is confirmed'},
      {'title': 'New Message', 'subtitle': 'You have a message from Artist B'},
      {'title': 'Event Update', 'subtitle': 'Venue X has updated the schedule'},
    ];

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.message, color: Colors.teal),
              title: Text(msg['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(msg['subtitle']!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => debugPrint("Tapped on ${msg['title']}"),
            ),
          );
        },
      ),
    );
  }
}
