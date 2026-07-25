import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import '../theme/arch_motif.dart';

const double _kaabaLat = 21.4225;
const double _kaabaLng = 39.8262;

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaBearing;
  String? _error;
  bool _loading = true;

  double? _smoothedHeading;
  static const double _smoothingFactor = 0.15;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

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

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final bearing = _calculateQiblaBearing(pos.latitude, pos.longitude);

      setState(() {
        _qiblaBearing = bearing;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  double _calculateQiblaBearing(double lat, double lng) {
    final lat1 = lat * pi / 180;
    final lat2 = _kaabaLat * pi / 180;
    final dLng = (_kaabaLng - lng) * pi / 180;

    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  double _smooth(double previous, double next) {
    double delta = next - previous;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    return (previous + delta * _smoothingFactor + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QIBLA')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
            : _error != null
                ? _buildError()
                : _buildCompass(),
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
            const Icon(Icons.explore_off_rounded, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            FilledButton(onPressed: _init, child: const Text('TRY AGAIN')),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'This device does not have a compass sensor, or it is '
                'still starting up.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final rawHeading = snapshot.data!.heading ?? 0;
        _smoothedHeading = _smooth(_smoothedHeading ?? rawHeading, rawHeading);
        final heading = _smoothedHeading!;

        final accuracy = snapshot.data!.accuracy;
        final needsCalibration = accuracy != null && accuracy > 0.5;

        final needleAngle = ((_qiblaBearing! - heading + 360) % 360) * pi / 180;

        return Stack(
          children: [
            Positioned(
              bottom: -40,
              left: 0,
              right: 0,
              child: Center(
                child: ArchMotif(
                  width: 320,
                  height: 260,
                  color: AppTheme.gold.withOpacity(0.06),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (needsCalibration) _CalibrationBanner(onRecalibrate: _init),
                  Text(
                    'QIBLA · ${_qiblaBearing!.toStringAsFixed(0)}° FROM NORTH',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 28),
                  _CompassRing(needleAngle: needleAngle),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Hold your phone flat. The mosque icon points toward the Qibla.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _init,
                    icon: const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.gold),
                    label: const Text('RECALIBRATE',
                        style: TextStyle(color: AppTheme.gold, letterSpacing: 1.2, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CompassRing extends StatelessWidget {
  final double needleAngle;
  const _CompassRing({required this.needleAngle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppTheme.goldGlow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(140),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.surfaceCardLight.withOpacity(0.9),
                  AppTheme.surfaceCard.withOpacity(0.95),
                ],
              ),
              border: Border.all(color: AppTheme.gold.withOpacity(0.5), width: 1.4),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (int i = 0; i < 12; i++)
                  Transform.rotate(
                    angle: i * (pi / 6),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 14),
                        width: 2,
                        height: i % 3 == 0 ? 12 : 6,
                        color: AppTheme.gold.withOpacity(i % 3 == 0 ? 0.6 : 0.25),
                      ),
                    ),
                  ),
                Transform.rotate(
                  angle: needleAngle,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mosque_rounded, size: 36, color: AppTheme.gold),
                      Container(
                        width: 3,
                        height: 78,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppTheme.gold, AppTheme.gold.withOpacity(0.15)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.gold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalibrationBanner extends StatelessWidget {
  final VoidCallback onRecalibrate;
  const _CalibrationBanner({required this.onRecalibrate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.goldLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore_outlined, size: 16, color: AppTheme.goldLight),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Low accuracy — move your phone in a figure-8 to calibrate',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12, color: AppTheme.goldLight),
            ),
          ),
        ],
      ),
    );
  }
}
