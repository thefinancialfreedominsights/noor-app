import 'package:flutter/material.dart';

/// PLACEHOLDER — next build step will add:
/// - Live compass reading via flutter_compass
/// - Calculated bearing to the Kaaba from the user's GPS position
/// - Simple rotating needle UI pointing to Qibla direction
class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Qibla compass — coming in the next build step.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
