import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategorySelectionPage extends StatefulWidget {
  final String uid; // user id to save categories
  const CategorySelectionPage({super.key, required this.uid});

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  String? selectedMainCategory;
  List<String> subCategories = [];
  List<String> selectedSubCategories = [];

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> loadSubCategories(String mainCategory) async {
    final doc = await _db.collection('categories').doc(mainCategory).get();
    if (doc.exists) {
      setState(() {
        subCategories = List<String>.from(doc['items']);
        selectedSubCategories = [];
      });
    }
  }

  void saveSelection() async {
    if (selectedMainCategory == null || selectedSubCategories.isEmpty) return;

    await _db.collection('users').doc(widget.uid).update({
      'categories': selectedSubCategories,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Categories saved successfully!")),
    );

    Navigator.pushReplacementNamed(context, "/creative_home");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Categories")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedMainCategory,
              decoration: const InputDecoration(labelText: "Main Category"),
              items: const [
                DropdownMenuItem(
                    value: "audiovisualMedia",
                    child: Text("Audiovisual Media")),
                DropdownMenuItem(
                    value: "digitalInteractiveMedia",
                    child: Text("Digital & Interactive Media")),
                DropdownMenuItem(
                    value: "creativeServices",
                    child: Text("Creative Services")),
                DropdownMenuItem(value: "design", child: Text("Design")),
                DropdownMenuItem(
                    value: "publishingAndPrintMedia",
                    child: Text("Publishing & Print Media")),
                DropdownMenuItem(
                    value: "performingArts",
                    child: Text("Performing Arts")),
                DropdownMenuItem(value: "visualArts", child: Text("Visual Arts")),
                DropdownMenuItem(
                    value: "traditionalAndCulturalExpressions",
                    child: Text("Traditional & Cultural Expressions")),
                DropdownMenuItem(value: "culturalSites", child: Text("Cultural Sites")),
              ],
              onChanged: (value) {
                setState(() => selectedMainCategory = value);
                if (value != null) loadSubCategories(value);
              },
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: subCategories.map((subCat) {
                  return CheckboxListTile(
                    title: Text(subCat),
                    value: selectedSubCategories.contains(subCat),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          selectedSubCategories.add(subCat);
                        } else {
                          selectedSubCategories.remove(subCat);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            ElevatedButton(
              onPressed: saveSelection,
              child: const Text("Save Categories"),
            ),
          ],
        ),
      ),
    );
  }
}
