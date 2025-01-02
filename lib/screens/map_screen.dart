import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    await getLocation();
  }

  Future<void> getLocation() async {
    if (!_serviceEnabled || _permissionGranted != PermissionStatus.granted) {
      return;
    }

    try {
      final locationData = await location.getLocation();
      setState(() {
        _locationData = locationData;
      });
    } catch (e) {
      print("Erro ao obter localização: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text('Localização'),
      ),
      body: _locationData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isLandscape)
                Column(
                  children: [
                    Text(
                      'Latitude: ${_locationData!.latitude}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Longitude: ${_locationData!.longitude}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              if (isLandscape) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Latitude: ${_locationData!.latitude}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Longitude: ${_locationData!.longitude}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
              Container(
                height: isLandscape
                    ? mediaQuery.size.height * 0.5
                    : mediaQuery.size.height * 0.3,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      _locationData!.latitude!,
                      _locationData!.longitude!,
                    ),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            _locationData!.latitude!,
                            _locationData!.longitude!,
                          ),
                          width: 40.0,
                          height: 40.0,
                          child: Icon(
                            Icons.pin_drop,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_locationData != null) {
                    Navigator.pop(context, {
                      'latitude': _locationData!.latitude!,
                      'longitude': _locationData!.longitude!,
                    });
                  }
                },
                child: Text('Guardar Localização'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
