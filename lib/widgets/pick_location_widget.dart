import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sdui_flutter_sample/models/error_model.dart';
import 'package:sdui_flutter_sample/models/picked_location.dart';
import 'package:sdui_flutter_sample/models/widget_model.dart';

import '../models/notifications.dart';

class PickLocationWidget extends StatelessWidget {
  final PickLocationModel model;
  final PickLocationValue fieldValue;
  final PickLocationError? error;

  const PickLocationWidget({
    super.key,
    required this.model,
    required this.fieldValue,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final errorValue = error?.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(model.placeholder),
        const SizedBox(height: 20),
        InkWell(
          onTap: () async {
            final location = await Navigator.of(context)
                .push(MaterialPageRoute<PickedLocation?>(builder: (_) {
              return PickLocationScreen(lastLocation: fieldValue.value);
            }));
            if (!context.mounted) return;
            if (location != null) {
              PickLocationNotification(
                key: model.key,
                value: PickLocationValue(location),
              ).dispatch(context);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(20.0),
            ),
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Center(
                child: _buildMap(fieldValue),
              ),
            ),
          ),
        ),
        if (errorValue != null)
          Text(errorValue,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.red)),
      ],
    );
  }

  Widget _buildMap(PickLocationValue value) {
    final latLng = value.value;
    if (latLng == null) {
      return const Text('No location selected');
    } else {
      return Stack(
        children: [
          Image.asset(
            'assets/images/map.jpg',
            fit: BoxFit.cover,
            height: double.maxFinite,
            width: double.maxFinite,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.location_pin),
                const SizedBox(height: 12),
                Text('${latLng.latitude}, ${latLng.longitude}'),
              ],
            ),
          ),
        ],
      );
    }
  }
}

class PickLocationScreen extends StatefulWidget {
  final PickedLocation? lastLocation;

  const PickLocationScreen({super.key, required this.lastLocation});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  PickedLocation? _location;

  @override
  void initState() {
    _location = widget.lastLocation;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = _location;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose location on map'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_location != null) Navigator.pop(context, _location);
        },
        child: const Icon(Icons.check),
      ),
      body: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          children: [
            Image.asset(
              'assets/images/map.jpg',
              fit: BoxFit.cover,
              height: double.maxFinite,
              width: double.maxFinite,
            ),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _location = generateRandomLocation();
                  });
                },
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (loc != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.pin_drop_rounded),
                            Text('${loc.latitude}, ${loc.longitude}'),
                          ],
                        ),
                      const SizedBox(height: 24),
                      const Text('Tap to change location')
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PickedLocation generateRandomLocation() {
    const double minLat = -90;
    const double maxLat = 90;
    const double minLng = -180;
    const double maxLng = 180;

    final random = Random();
    final latitude = truncate(minLat + random.nextDouble() * (maxLat - minLat));
    final longitude =
        truncate(minLng + random.nextDouble() * (maxLng - minLng));
    return PickedLocation(latitude, longitude);
  }

  double truncate(double value, {int decimalPlaces = 5}) {
    final mod = pow(10.0, decimalPlaces);
    return (value * mod).truncateToDouble() / mod;
  }
}
