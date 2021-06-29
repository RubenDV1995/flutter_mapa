import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map/check_marker.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const MarkerId markerId = MarkerId('marker_id_1');
  static const String polygonIdVal = 'polygon_id_1';
  static PolygonId nameArea1 = const PolygonId(polygonIdVal);
  late Marker myMarker;
  List<Marker> myMarkers = <Marker>[
    const Marker(
        markerId: MarkerId('marker_id_1'),
        infoWindow: InfoWindow(title: "Default Position", snippet: '*'),
        position: LatLng(20.079452070074776, -98.35631959140302),
        draggable: true)
  ];
  Location location = Location();
  late LocationData _currentPosition;
  late String _latitudeData = "";
  late String _longitudeData = "";
  late CameraPosition _newCemarePosition;
  bool isLastLocation = false;

  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(20.079452070074776, -98.35631959140302),
    zoom: 20,
  );

  CheckMarker c = CheckMarker();

  static const List<LatLng> area1Cor = [
    LatLng(19.46382, -99.16388),
    LatLng(19.42303, -99.17933),
    LatLng(19.45249, -99.17212),
    LatLng(19.45573, -99.20027),
    LatLng(19.43695, -99.21984),
    LatLng(19.41008, -99.24147),
    LatLng(19.39162, -99.24387),
    LatLng(19.37412, -99.23013),
    LatLng(19.35923, -99.21641),
    LatLng(19.38644, -99.19581),
    LatLng(19.36636, -99.19272),
    LatLng(19.35308, -99.21194),
    LatLng(19.33267, -99.19306),
    LatLng(19.30902, -99.18894),
    LatLng(19.29833, -99.15392),
    LatLng(19.30999, -99.13984),
    LatLng(19.32165, -99.088),
    LatLng(19.3466, -99.09521),
    LatLng(19.35858, -99.06088),
    LatLng(19.39, -99.06088),
    LatLng(19.43307, -99.05195),
    LatLng(19.48875, -99.02311),
    LatLng(19.54182, -99.0135),
    LatLng(19.57093, -99.0238),
    LatLng(19.54829, -99.05882),
    LatLng(19.55217, -99.07942),
    LatLng(19.48162, -99.09933),
    LatLng(19.48421, -99.10894),
    LatLng(19.52305, -99.10277),
    LatLng(19.53923, -99.12062),
    LatLng(19.53793, -99.14122),
    LatLng(19.55087, -99.19684),
    LatLng(19.51399, -99.23735),
    LatLng(19.46026, -99.24215),
    LatLng(19.48745, -99.21126),
    LatLng(19.47839, -99.18516),
  ];

  static const List<LatLng> area2Cor = [
    LatLng(19.42312, -99.16118),
    LatLng(19.41341, -99.18143),
    LatLng(19.39592, -99.18281),
    LatLng(19.36516, -99.17937),
    LatLng(19.3509, -99.15843),
    LatLng(19.3535, -99.12822),
    LatLng(19.38103, -99.11105),
    LatLng(19.39819, -99.09629),
    LatLng(19.39495, -99.13474),
    LatLng(19.40337, -99.1368),
    LatLng(19.40337, -99.12547),
    LatLng(19.41114, -99.12444),
    LatLng(19.40799, -99.10925),
    LatLng(19.40758, -99.09835),
    LatLng(19.41697, -99.098),
    LatLng(19.42086, -99.09423),
    LatLng(19.42766, -99.11002),
    LatLng(19.42928, -99.13062),
    LatLng(19.40791, -99.13405),
    LatLng(19.40564, -99.1447),
    LatLng(19.38848, -99.14298),
    LatLng(19.38103, -99.12856),
    LatLng(19.3739, -99.14058),
    LatLng(19.38006, -99.15671),
    LatLng(19.40693, -99.15671),
    LatLng(19.42086, -99.15259),
  ];

  List<Polygon> area1 = <Polygon>[
    Polygon(
      polygonId: nameArea1,
      consumeTapEvents: true,
      strokeColor: Colors.orange,
      strokeWidth: 1,
      zIndex: 1,
      fillColor: Colors.green[500]!.withOpacity(0.5),
      points: area1Cor,
    ),
    Polygon(
      polygonId: nameArea1,
      consumeTapEvents: true,
      strokeColor: Colors.blue,
      zIndex: 2,
      strokeWidth: 1,
      fillColor: Colors.red[500]!.withOpacity(0.5),
      points: area2Cor,
    )
  ];

  @override
  void initState() {
    super.initState();
    automaticLocation();
    lastLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("REPARTO"),
        leading: const Icon(Icons.motorcycle),
        actions: <Widget>[
          isLastLocation ?
          IconButton(
            icon: const Icon(
              Icons.last_page,
              color: Colors.white,
            ),
            onPressed: lastLocation,
          ) : const SizedBox(),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: Set.of(myMarkers),
              polygons: Set<Polygon>.of(area1),
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: automaticLocation,
        child: const Icon(Icons.gps_fixed),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> setCameraPosition() async {
    setMarker();
    _newCemarePosition = CameraPosition(
      target: LatLng(
        double.parse(_latitudeData),
        double.parse(_longitudeData),
      ),
      zoom: 11,
    );

    final GoogleMapController controller = await _controller.future;
    controller.showMarkerInfoWindow(markerId);
    controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCemarePosition),
    );
  }

  automaticLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

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

    _currentPosition = await location.getLocation();
    _latitudeData = _currentPosition.latitude.toString();
    _longitudeData = _currentPosition.longitude.toString();
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
        setCameraPosition();
      });
    });
  }

  setMarker() {
    myMarkers.clear();
    late LatLng newLatLng =
        LatLng(double.parse(_latitudeData), double.parse(_longitudeData));
    myMarker = Marker(
      onTap: () {},
      draggable: true,
      markerId: markerId,
      position: newLatLng,
      infoWindow: InfoWindow(title: checkMarkerArea(), snippet: '*'),
      onDragEnd: ((newPosition) {
        setState(() {
          _latitudeData = newPosition.latitude.toString();
          _longitudeData = newPosition.longitude.toString();
          setCameraPosition();
          saveLastLocation();
        });
      }),
    );
    myMarkers.add(myMarker);
  }

  checkMarkerArea() {
    var isArea1 = mp.PolygonUtil.containsLocation(
      mp.LatLng(
        double.parse(_latitudeData),
        double.parse(_longitudeData),
      ),
      c.listAreaUno(),
      false,
    );
    var isArea2 = mp.PolygonUtil.containsLocation(
      mp.LatLng(
        double.parse(_latitudeData),
        double.parse(_longitudeData),
      ),
      c.listAreaDos(),
      false,
    );
    if (isArea1 == true && isArea2 == false) {
      return "Área 1";
    } else if (isArea2 == true && isArea1 == true) {
      return "Área 2";
    } else {
      return "fuera de zona";
    }
  }

  saveLastLocation() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("Latitude", _latitudeData);
    prefs.setString("longitude", _longitudeData);
    isLastLocation = false;
  }

  lastLocation() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('Latitude')){
      setState(() {
        _latitudeData = prefs.getString('Latitude').toString();
        _longitudeData = prefs.getString('longitude').toString();
        isLastLocation = true;
      });
    }
  }

}
