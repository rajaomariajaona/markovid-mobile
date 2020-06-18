import 'dart:async';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:map_controller/map_controller.dart';

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _MapPageContent(),
      ),
    );
  }
}

class _MapPageContent extends StatefulWidget {
  _MapPageContent({
    Key key,
  }) : super(key: key);

  @override
  __MapPageContentState createState() => __MapPageContentState();
}

class __MapPageContentState extends State<_MapPageContent> {
  MapController mapController;

  StatefulMapController statefulMapController;

  StreamSubscription<StatefulMapControllerStateChange> sub;

  Location location = new Location();

  bool _serviceEnabled;

  PermissionStatus _permissionGranted;

  LocationData _locationData;

  IconData iconData = Icons.mic;

  bool isReady = false;

  @override
  void initState() {
    // intialize the controllers
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    statefulMapController.onReady.then((_) => isReady = true);
    sub = statefulMapController.changeFeed.listen((change) => setState(() {}));
    super.initState();
  }

  Future<void> goToMyLocation() async {
    if (!isReady) return;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    statefulMapController.mapController.move(
        LatLng(_locationData.latitude, _locationData.longitude),
        mapController.zoom);
    statefulMapController.removeMarker(name: "myLocation");
    statefulMapController.addMarker(
        marker: Marker(
            builder: (ctx) => Icon(
                  Icons.location_on,
                  color: Colors.blue,
                )),
        name: "myLocation");
  }

  final SearchBarController<Fokontany> _searchBarController = SearchBarController();
  bool isReplay = false;

  Future<List<Fokontany>> _getFokontany(String text) async {
    
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: LatLng(-18.91368, 47.53613),
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/{id}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
              additionalOptions: {
                'accessToken':
                    'pk.eyJ1IjoicmFqYW9tYXJpYWphb25hIiwiYSI6ImNrYmptYmplNzBxZ2syeWxzZGpqazM5OTgifQ.o0gKXrpg0veDwXuvooRmRA',
                'id': 'rajaomaria/ckbjppdr600h81iqj3lczkbon',
              },
            ),
            MarkerLayerOptions(
              markers: [],
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: GestureDetector(
                    onTap: () async {
                      await goToMyLocation();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Icon(Icons.location_searching),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        buildContainer(context),
      ],
    );
  }

  Container buildContainer(BuildContext context) {
    return Container(
      child: SearchBar<Fokontany>(
        searchBarPadding: EdgeInsets.all(20),
        listPadding: EdgeInsets.symmetric(horizontal: 10),
        searchBarStyle: SearchBarStyle(
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
        onSearch: _getFokontany,
        searchBarController: _searchBarController,
        cancellationWidget: Icon(Icons.close),
        mainAxisSpacing: 0,
        crossAxisCount: 1,
        onItemFound: (Fokontany fokontany, int index) {
          return Card(
            color: Colors.white,
            child: ListTile(
              title: Text("${fokontany.nom}, ${fokontany.province}"),
              onTap: () {
                statefulMapController.mapController.move(
                    LatLng(fokontany.centre["coordinates"][1],
                        fokontany.centre["coordinates"][0]),
                    statefulMapController.mapController.zoom);
              },
            ),
          );
        },
      ),
    );
  }
}

class Fokontany {
  final String id;
  final String nom;
  final String province;
  final Map centre;
  Fokontany({
    this.id,
    this.nom,
    this.province,
    this.centre,
  });
  static Fokontany fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Fokontany(
      id: map['id'],
      nom: map['nom'],
      province: map['province'],
      centre: Map.from(map['centre']),
    );
  }
}
