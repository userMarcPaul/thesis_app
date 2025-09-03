import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';

class BookingForm extends StatefulWidget {
  final String creativeId;
  final String creativeName;
  final String clientId;
  final String clientName;

  const BookingForm({
    super.key,
    required this.creativeId,
    required this.creativeName,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final detailsController = TextEditingController();

  void submit() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection(Constants.bookingsCollection)
        .add({
      'bookingId': DateTime.now().millisecondsSinceEpoch.toString(),
      'creativeId': widget.creativeId,
      'clientId': widget.clientId,
      'creativeName': widget.creativeName,
      'clientName': widget.clientName,
      'date': dateController.text,
      'time': timeController.text,
      'status': 'pending',
      'details': detailsController.text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking Created")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Form")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Booking with ${widget.creativeName}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: dateController,
                decoration:
                    const InputDecoration(labelText: "Date (YYYY-MM-DD)"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter a date" : null,
              ),
              TextFormField(
                controller: timeController,
                decoration: const InputDecoration(labelText: "Time"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter a time" : null,
              ),
              TextFormField(
                controller: detailsController,
                decoration: const InputDecoration(labelText: "Details"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter details" : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: submit,
                child: const Text("Submit Booking"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
