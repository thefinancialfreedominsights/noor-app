import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import '../theme/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _loading = true;
  String? _error;
  bool _hasSensor = true;

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
      final permission = await FlutterQiblah.requestPermissions();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        throw Exception('Location permission is required for Qibla direction.');
      }

      final hasSensor = await FlutterQiblah.androidDeviceSensorSupport();
      if (hasSensor == false) {
        setState(() {
          _hasSensor = false;
          _loading = false;
        });
        return;
      }

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : !_hasSensor
                    ? _buildNoSensor()
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
            const Icon(Icons.explore_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _init, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSensor() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'This device does not have the sensors needed for a live '
          'compass (accelerometer/magnetometer).',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final qiblahDirection = snapshot.data!;
        final angle = (qiblahDirection.qiblah) * (pi / 180) * -1;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryTeal, width: 2),
                      ),
                    ),
                    Transform.rotate(
                      angle: angle,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mosque_rounded,
                              size: 40, color: AppTheme.accentGold),
                          Container(
                            width: 4,
                            height: 90,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Hold your phone flat. The mosque icon points toward the '
                  'Qibla.\n\nIf it seems off, move your phone in a figure-8 '
                  'motion a few times — this recalibrates the compass sensor, '
                  'which is a normal thing to do occasionally (all compass '
                  'apps need this, not just this one).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
