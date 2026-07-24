import 'package:flutter/material.dart';

/// PLACEHOLDER — next build step will add:
/// - List of all 114 Surahs (name in Arabic + English + Urdu meaning)
/// - Tapping a Surah opens full Arabic text with Urdu/English translation
/// - Bookmark + "last read" tracking (Phase 2)
class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quran')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Quran reader — coming in the next build step.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
