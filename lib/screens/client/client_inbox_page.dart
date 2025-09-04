import 'package:flutter/material.dart';

class ClientInboxPage extends StatelessWidget {
  const ClientInboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inbox")),
      body: const Center(child: Text("Your messages will appear here.")),
    );
  }
}
