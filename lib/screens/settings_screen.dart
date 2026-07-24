import 'package:flutter/material.dart';

/// PLACEHOLDER — next build step will add:
/// - Calculation method selector (default: Karachi)
/// - Language toggle (Urdu / English)
/// - Notification on/off + the short Arabic recitation-cue sound setting
/// - Theme (light/dark) override
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Settings — coming in the next build step.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
