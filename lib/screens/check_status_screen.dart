import 'package:flutter/material.dart';

class CheckStatusScreen extends StatelessWidget {
  const CheckStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check status')),
      body: const Center(
        child: Text(
          'Status page coming soon',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
