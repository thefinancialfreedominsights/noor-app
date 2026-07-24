import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/prayer_times.dart';

/// Talks to the free, no-key-required Aladhan API (https://aladhan.com/prayer-times-api)
/// This is the only external service the MVP depends on — no backend/server
/// of our own to host or pay for.
class PrayerTimesService {
  /// Aladhan calculation method codes (method=1 is University of Islamic
  /// Sciences, Karachi — the default most Pakistani users expect).
  static const int defaultMethod = 1;

  /// Gets the device's current GPS coordinates.
  /// Throws if location permission is denied — caller should catch and
  /// fall back to manual city selection (Phase 1 also needs that fallback
  /// screen; wired in once this core flow is confirmed working).
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  /// Fetches today's prayer times for the given coordinates.
  Future<PrayerTimes> fetchToday({
    required double latitude,
    required double longitude,
    int method = defaultMethod,
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-${now.year}';

    final uri = Uri.parse(
      'https://api.aladhan.com/v1/timings/$dateStr'
      '?latitude=$latitude&longitude=$longitude&method=$method',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch prayer times (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return PrayerTimes.fromAladhan(data, now);
  }
}
