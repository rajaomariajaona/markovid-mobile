import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class Zone {
  final String name;
  final Color color;
  final Color centreColor;
  final Color borderColor;
  final double borderWidth;
  final List<LatLng> points;
  final LatLng centre;
  Zone({
    @required this.centre,
    @required this.name,
    this.centreColor = Colors.blue,
    this.color = Colors.lightBlue,
    this.borderColor = const Color(0xFFFFFF00),
    this.borderWidth = 0.0,
    @required this.points,
  });

  Marker getCentreMarker() {
    return Marker(
      point: centre,
      builder: (ctx) => Icon(
        Icons.warning,
        color: centreColor,
      ),
    );
  }
}
