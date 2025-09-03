import 'package:flutter/material.dart';

class PortfolioGrid extends StatelessWidget {
  final List<String> images;
  const PortfolioGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (_, index) {
        return Image.network(images[index], fit: BoxFit.cover);
      },
    );
  }
}
