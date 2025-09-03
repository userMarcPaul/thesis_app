import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'booking_form.dart';
import 'search_creatives.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, '/role_selection', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Client Home"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2193b0),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6dd5ed), Color(0xFF2193b0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Welcome Back, Client 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Quick actions
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.book_online, color: Colors.green),
                title: const Text("Book a Creative"),
                subtitle: const Text("Fill out a form to make a booking"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingForm(
                        creativeId: "sampleCreativeId",
                        creativeName: "Sample Creative",
                        clientId: FirebaseAuth.instance.currentUser!.uid,
                        clientName:
                            FirebaseAuth.instance.currentUser!.displayName ??
                                "Client",
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.people, color: Colors.blue),
                title: const Text("Search Creatives"),
                subtitle: const Text("Find talents & professionals"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchCreatives(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
