class PrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Builds a PrayerTimes object from the Aladhan API JSON response.
  /// Aladhan returns times as "HH:mm" strings (24hr) for the given date.
  factory PrayerTimes.fromAladhan(Map<String, dynamic> json, DateTime forDate) {
    DateTime parse(String hhmm) {
      final cleaned = hhmm.split(' ').first; // strips timezone suffix if present
      final parts = cleaned.split(':');
      return DateTime(
        forDate.year,
        forDate.month,
        forDate.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    final timings = json['timings'] as Map<String, dynamic>;
    return PrayerTimes(
      fajr: parse(timings['Fajr']),
      sunrise: parse(timings['Sunrise']),
      dhuhr: parse(timings['Dhuhr']),
      asr: parse(timings['Asr']),
      maghrib: parse(timings['Maghrib']),
      isha: parse(timings['Isha']),
    );
  }

  /// Ordered list of (name, time) pairs — used to render the list and to
  /// figure out which prayer is "next".
  List<MapEntry<String, DateTime>> get asList => [
        MapEntry('Fajr', fajr),
        MapEntry('Sunrise', sunrise),
        MapEntry('Dhuhr', dhuhr),
        MapEntry('Asr', asr),
        MapEntry('Maghrib', maghrib),
        MapEntry('Isha', isha),
      ];

  /// Returns the next upcoming prayer relative to [now].
  /// If all of today's prayers have passed, falls back to Fajr (tomorrow's,
  /// conceptually — the caller re-fetches at midnight in a later iteration).
  MapEntry<String, DateTime> nextPrayer(DateTime now) {
    for (final entry in asList) {
      if (entry.value.isAfter(now)) return entry;
    }
    return asList.first;
  }
}
