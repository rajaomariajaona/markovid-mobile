import 'package:Markovid/entities/fokontany.dart';
import 'package:Markovid/entities/zone.dart';
import 'package:Markovid/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:async/async.dart';

class FokontanyProvider extends PropertyChangeNotifier<String> {
  List<Fokontany> recherche = [];
  bool loading = false;
  CancelableOperation cancelableOperation;
  Future getFokontany(String text) async {
    loading = true;
    notifyListeners();
    if (text.length < 3) {
      recherche = [];
      loading = false;
      notifyListeners();
      return;
    }
    if (cancelableOperation != null && !cancelableOperation.isCompleted) {
      await cancelableOperation.cancel();
    }
    cancelableOperation = CancelableOperation.fromFuture(
      Future.delayed(Duration(seconds: 1)).then((_) async {
        recherche = await _fetchFokontany(text);
        loading = false;
        notifyListeners();
      }),
    );
  }

  Future<List<Fokontany>> _fetchFokontany(String text) async {
    Dio dio = await RestRequest().getDioInstance();
    Response res = await dio.get("/?nom=$text");
    List<Fokontany> liste = [];
    for (dynamic d in res.data) {
      liste.add(Fokontany(
          centre: LatLng(d["centre"]["coordinates"][1] as double,
              d["centre"]["coordinates"][0] as double),
          id: d["id"],
          nom: d["nom"],
          province: d["province"]));
    }
    return liste;
  }

  List<Zone> zoneRouge = [];
  List<Zone> zoneJaune = [];

  Future fetchZone() async {
    Dio dio = await RestRequest().getDioInstance();
    Response res = await dio.get("/zone");
    zoneJaune.clear();
    zoneRouge.clear();

    for (dynamic d in res.data["zone_rouge"]) {
      List centre = d["centre"]["coordinates"];
      for (List coordsPoly in d["trace"]["coordinates"]) {
        zoneRouge.add(Zone(
            centre: LatLng(centre[1] as double, centre[0] as double),
            name: d["id"],
            points: <LatLng>[
              for (List coords in coordsPoly)
                LatLng(coords[1] as double, coords[0] as double)
            ],
            color: Colors.red.withAlpha(128),
            borderColor: Colors.red.withAlpha(240),
            centreColor: Colors.red));
      }
    }

    for (dynamic d in res.data["zone_jaune"]) {
      List centre = d["centre"]["coordinates"];
      for (List coordsPoly in d["trace"]["coordinates"]) {
        zoneJaune.add(Zone(
            centre: LatLng(centre[1] as double, centre[0] as double),
            name: d["id"],
            points: <LatLng>[
              for (List coords in coordsPoly)
                LatLng(coords[1] as double, coords[0] as double)
            ],
            color: Colors.orange.withAlpha(128),
            borderColor: Colors.orange.withAlpha(240),
            centreColor: Colors.orange));
      }
    }
    notifyListeners('zone');
  }
}
