import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import 'booking_form.dart';

class SearchCreatives extends StatelessWidget {
  const SearchCreatives({super.key});

  Future<Map<String, String>> _getClientInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {"id": "", "name": ""};

    final doc = await FirebaseFirestore.instance
        .collection(Constants.usersCollection)
        .doc(user.uid)
        .get();

    return {
      "id": user.uid,
      "name": doc['name'] ?? "Client",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Creatives")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(Constants.usersCollection)
            .where('role', isEqualTo: 'creative')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final creatives = snapshot.data!.docs;

          return ListView.builder(
            itemCount: creatives.length,
            itemBuilder: (_, index) {
              final creative = creatives[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(creative['name']),
                  subtitle: Text(creative['specialization'] ?? "Creative"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () async {
                    final clientInfo = await _getClientInfo();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingForm(
                          creativeId: creative.id,
                          creativeName: creative['name'],
                          clientId: clientInfo["id"]!,
                          clientName: clientInfo["name"]!,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
