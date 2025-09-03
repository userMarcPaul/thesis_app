import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';

class BookingsList extends StatelessWidget {
  const BookingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(Constants.bookingsCollection)
            .where('creativeId', isEqualTo: "CURRENT_USER_ID")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final bookings = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (_, index) {
              final data = bookings[index];
              return ListTile(
                title: Text(data['clientName']),
                subtitle: Text("${data['date'].toDate()} - ${data['status']}"),
              );
            },
          );
        },
      ),
    );
  }
}
