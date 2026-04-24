import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/fcm_sender.dart'; // Import the file we just made

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _send() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call our Service to send the message
      await FCMSender.sendNotification(
        title: _titleController.text,
        body: _bodyController.text,
      );

      Get.snackbar("Success", "Notification sent to all users!",
          backgroundColor: Colors.green, colorText: Colors.white);

      // Clear fields
      _titleController.clear();
      _bodyController.clear();

    } catch (e) {
      Get.snackbar("Error", "Failed to send: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Broadcast")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Send Message to All Users",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "⚠️ This will alert every user installed on the app.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Title Input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title (e.g., 'New Workout Added')",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 20),

            // Body Input
            TextField(
              controller: _bodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Message Body",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
            ),
            const SizedBox(height: 40),

            // Send Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.send),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SEND NOW", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
