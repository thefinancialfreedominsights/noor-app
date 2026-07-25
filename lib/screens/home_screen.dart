import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/prayer_times.dart';
import '../services/prayer_times_service.dart';
import '../theme/app_theme.dart';
import '../theme/arch_motif.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = PrayerTimesService();
  PrayerTimes? _times;
  String? _error;
  bool _loading = true;
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  static const _prayerIcons = {
    'Fajr': Icons.nights_stay_outlined,
    'Sunrise': Icons.wb_twilight_rounded,
    'Dhuhr': Icons.wb_sunny_outlined,
    'Asr': Icons.light_mode_outlined,
    'Maghrib': Icons.wb_twilight_rounded,
    'Isha': Icons.dark_mode_outlined,
  };

  @override
  void initState() {
    super.initState();
    _load();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await _service.getCurrentLocation();
      final times = await _service.fetchToday(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      setState(() {
        _times = times;
        _loading = false;
      });
      _updateCountdown();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _updateCountdown() {
    if (_times == null) return;
    final next = _times!.nextPrayer(DateTime.now());
    final diff = next.value.difference(DateTime.now());
    if (mounted) {
      setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatTime(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NOOR')),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.gold),
              )
            : _error != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_rounded, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            FilledButton(onPressed: _load, child: const Text('TRY AGAIN')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final next = _times!.nextPrayer(DateTime.now());
    return RefreshIndicator(
      color: AppTheme.gold,
      backgroundColor: AppTheme.surfaceCard,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _NextPrayerHero(
            name: next.key,
            time: _formatTime(next.value),
            countdown: _formatDuration(_remaining),
          ),
          const SizedBox(height: 32),
          Text('TODAY', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _times!.asList.length; i++) ...[
                  if (i != 0)
                    const Divider(height: 1, color: AppTheme.divider, indent: 20, endIndent: 20),
                  _PrayerRow(
                    name: _times!.asList[i].key,
                    time: _formatTime(_times!.asList[i].value),
                    icon: _prayerIcons[_times!.asList[i].key] ?? Icons.circle,
                    isNext: _times!.asList[i].key == next.key,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextPrayerHero extends StatelessWidget {
  final String name;
  final String time;
  final String countdown;

  const _NextPrayerHero({required this.name, required this.time, required this.countdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.surfaceCardLight, AppTheme.surfaceCard],
        ),
        boxShadow: AppTheme.goldGlow,
        border: Border.all(color: AppTheme.gold.withOpacity(0.25)),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -6,
            child: ArchMotif(
              width: 180,
              height: 130,
              color: AppTheme.gold.withOpacity(0.14),
            ),
          ),
          Column(
            children: [
              Text('NEXT PRAYER', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 14),
              Text(name, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 6),
              Text(
                time,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.goldLight,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 22),
              Container(
                height: 1,
                width: 60,
                color: AppTheme.gold.withOpacity(0.4),
              ),
              const SizedBox(height: 22),
              Text(
                countdown,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 4),
              Text('TIME REMAINING', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String name;
  final String time;
  final IconData icon;
  final bool isNext;

  const _PrayerRow({
    required this.name,
    required this.time,
    required this.icon,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isNext ? AppTheme.gold.withOpacity(0.15) : Colors.transparent,
              border: Border.all(
                color: isNext ? AppTheme.gold : AppTheme.divider,
              ),
            ),
            child: Icon(icon, size: 18, color: isNext ? AppTheme.gold : AppTheme.textMuted),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isNext ? AppTheme.goldLight : AppTheme.textPrimary,
                  ),
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isNext ? AppTheme.goldLight : AppTheme.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}
