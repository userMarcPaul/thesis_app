import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_input.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final bioController = TextEditingController();
  final rateController = TextEditingController();
  List<String> selectedCategories = [];
  final categoriesList = Constants.creativeCategories;

  void saveProfile() async {
    // Example: update Firestore
    await FirebaseFirestore.instance.collection(Constants.usersCollection).doc("CURRENT_USER_ID").update({
      'bio': bioController.text,
      'rate': rateController.text,
      'categories': selectedCategories,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomInput(controller: bioController, label: "Bio"),
            CustomInput(controller: rateController, label: "Rate"),
            DropdownButtonFormField<String>(
              items: categoriesList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null && !selectedCategories.contains(val)) setState(() => selectedCategories.add(val));
              },
              decoration: const InputDecoration(labelText: "Select Category"),
            ),
            Wrap(
              spacing: 8,
              children: selectedCategories
                  .map((c) => Chip(label: Text(c), onDeleted: () => setState(() => selectedCategories.remove(c))))
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: saveProfile, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
