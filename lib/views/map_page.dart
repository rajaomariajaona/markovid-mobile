import 'dart:async';
import 'package:Markovid/provider/fokontany_provider.dart';
import 'package:Markovid/views/drawer.dart';
import 'package:Markovid/views/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:map_controller/map_controller.dart';
import 'package:provider/provider.dart';

class SearchWidgetController {
  void Function() goToMyLocation;
}

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SearchWidgetController controller = SearchWidgetController();
    final GlobalKey<ScaffoldState> scaffKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffKey,
      drawer: Drawer(
        child: MyDrawer(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.goToMyLocation();
        },
        child: Icon(Icons.location_searching),
      ),
      body: SafeArea(
        child: _MapPageContent(
            key: key,
            searchWidgetController: controller,
            openDrawer: () {
              scaffKey.currentState.openDrawer();
            }),
      ),
    );
  }
}

class _MapPageContent extends StatefulWidget {
  _MapPageContent(
      {Key key,
      @required this.searchWidgetController,
      @required this.openDrawer})
      : super(key: key);
  final SearchWidgetController searchWidgetController;
  final Function() openDrawer;
  @override
  __MapPageContentState createState() =>
      __MapPageContentState(searchWidgetController);
}

class __MapPageContentState extends State<_MapPageContent> {
  __MapPageContentState(SearchWidgetController searchWidgetController) {
    searchWidgetController.goToMyLocation = goToMyLocation;
  }
  MapController mapController;

  StatefulMapController statefulMapController;

  StreamSubscription<StatefulMapControllerStateChange> sub;

  Location location = new Location();

  bool _serviceEnabled;

  PermissionStatus _permissionGranted;

  IconData iconData = Icons.mic;

  bool isReady = false;

  @override
  void initState() {
    // intialize the controllers
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    statefulMapController.onReady.then((_) async {
      isReady = true;
      context.read<FokontanyProvider>().addListener(_addZone, ['zone']);
      context.read<FokontanyProvider>().fetchZone();
    });
    sub = statefulMapController.changeFeed.listen((change) => setState(() {}));
    super.initState();
  }

  _addZone() async {
    final List<String> keys = statefulMapController.namedPolygons.keys.toList();
    for (String key in keys) {
      if (key.startsWith('MG')) await statefulMapController.removePolygon(key);
    }
    await statefulMapController.removeMarkers(
        names: statefulMapController.namedMarkers.keys
            .where((String key) => key.startsWith('MG'))
            .toList());
    context.read<FokontanyProvider>().zoneRouge.forEach((element) {
      statefulMapController.addMarker(
          marker: element.getCentreMarker(), name: element.name);
      statefulMapController.addPolygon(
        name: element.name,
        points: element.points,
        color: element.color,
        borderColor: element.borderColor,
        borderWidth: element.borderWidth,
      );
    });
    context.read<FokontanyProvider>().zoneJaune.forEach((element) {
      statefulMapController.addMarker(
          marker: element.getCentreMarker(), name: element.name);
      statefulMapController.addPolygon(
        name: element.name,
        points: element.points,
        color: element.color,
        borderColor: element.borderColor,
        borderWidth: element.borderWidth,
      );
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  Future<void> goToMyLocation() async {
    if (!isReady) return;
    if (!await _isServiceEnabled()) return;
    if (!await _hasPermission()) return;
    LatLng myLocation = await _getMyLocation();
    await _moveAndMark(myLocation);
  }

  Future _moveAndMark(LatLng myLocation) async {
    print(statefulMapController.zoom);
    statefulMapController.centerOnPoint(myLocation);
    statefulMapController.zoomTo(16);
    try {
      await statefulMapController.removeMarker(name: "myLocation");
    } catch (e) {}
    await statefulMapController.addMarker(
        marker: Marker(
            point: myLocation,
            builder: (ctx) => Icon(
                  Icons.location_on,
                  color: Colors.blue,
                )),
        name: "myLocation");
  }

  Future<LatLng> _getMyLocation() async {
    LocationData _locationData = await location.getLocation();
    return LatLng(_locationData.latitude, _locationData.longitude);
  }

  Future<bool> _hasPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      _permissionGranted = await location.requestPermission();
    }
    return _permissionGranted == PermissionStatus.granted;
  }

  Future<bool> _isServiceEnabled() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      return _serviceEnabled;
    }
    return _serviceEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            nePanBoundary: LatLng(-11.767007, 50.842285),
            swPanBoundary: LatLng(-26.023899, 43.65000),
            center: LatLng(-18.91368, 47.53613),
            minZoom: 5.760635842425313,
            maxZoom: 20,
            onPositionChanged: (MapPosition p, __) {
              if (statefulMapController.namedMarkers["myLocation"] != null &&
                  !p.bounds.contains(
                      statefulMapController.namedMarkers["myLocation"].point))
                statefulMapController.removeMarker(name: "myLocation");

              if (statefulMapController.namedMarkers["searchedLocation"] !=
                      null &&
                  !p.bounds.contains(statefulMapController
                      .namedMarkers["searchedLocation"].point))
                statefulMapController.removeMarker(name: "searchedLocation");
            },
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/{id}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
              additionalOptions: {
                'accessToken':
                    'pk.eyJ1IjoicmFqYW9tYXJpYWphb25hIiwiYSI6ImNrYmptYmplNzBxZ2syeWxzZGpqazM5OTgifQ.o0gKXrpg0veDwXuvooRmRA',
                'id': 'rajaomariajaona/ckbjppdr600h81iqj3lczkbon',
              },
            ),
            MarkerLayerOptions(markers: statefulMapController.markers),
            PolylineLayerOptions(polylines: statefulMapController.lines),
            PolygonLayerOptions(
              polygons: statefulMapController.polygons,
            ),
          ],
        ),
        SearchWidget(
          goToLocation: goToLocation,
          openDrawer: widget.openDrawer,
        )
      ],
    );
  }

  goToLocation(LatLng centre) {
    if (!isReady) return;
    statefulMapController.addMarker(
        name: "searchedLocation",
        marker: Marker(
          point: LatLng(centre.latitude + 0.00001, centre.longitude + 0.00001),
          builder: (ctx) => Icon(
            Icons.location_on,
            color: Colors.teal,
            size: 30,
          ),
        ));
    statefulMapController.centerOnPoint(centre);
    statefulMapController.zoomTo(16);
  }
}
