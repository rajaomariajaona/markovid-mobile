import 'package:flutter/widgets.dart';
import 'package:latlong/latlong.dart';

class Fokontany {
  final String id;
  final String nom;
  final String province;
  final LatLng centre;
  final int casSuspect;
  final int casConfirme;

  Fokontany({
    @required this.casSuspect,
    @required this.casConfirme,
    @required this.id,
    @required this.nom,
    @required this.province,
    @required this.centre,
  });
}
