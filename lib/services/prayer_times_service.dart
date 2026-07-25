import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/prayer_times.dart';

/// Talks to the free, no-key-required Aladhan API (https://aladhan.com/prayer-times-api)
class PrayerTimesService {
  static const int defaultMethod = 1;

  /// Gets the device's current coordinates.
  /// Prayer times only need city-level precision, so we use low accuracy
  /// (resolves quickly via network/cell location) instead of waiting for a
  /// full GPS lock, and wrap everything in our own timeout so this can
  /// never hang indefinitely no matter what the plugin does internally -
  /// this is what fixes the "loading forever" issue.
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

    // Try a cached last-known position first - returns instantly if the
    // OS has one, avoiding any wait at all in the common case.
    try {
      final last = await Geolocator.getLastKnownPosition()
          .timeout(const Duration(seconds: 3));
      if (last != null) return last;
    } catch (_) {
      // No cached position available - fall through to a fresh fix below.
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 12),
      ),
    ).timeout(
      const Duration(seconds: 14),
      onTimeout: () => throw Exception(
          'Could not get your location in time. Make sure location/GPS is '
          'turned on, then try again.'),
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

    final response = await http.get(uri).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception(
          'Prayer times request timed out. Check your internet connection.'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch prayer times (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return PrayerTimes.fromAladhan(data, now);
  }
}
