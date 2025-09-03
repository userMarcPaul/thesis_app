import 'package:flutter/material.dart';

class CreativeCard extends StatelessWidget {
  final dynamic data;
  const CreativeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(data['name']),
        subtitle: Text(data['categories'] != null ? (data['categories'] as List).join(", ") : ""),
      ),
    );
  }
}
