import 'package:flutter/material.dart';

class ClientFavoritePage extends StatelessWidget {
  const ClientFavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: const Center(child: Text("Your saved creatives will appear here.")),
    );
  }
}
