import 'package:flutter/material.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  final Function(double latitude, double longitude) onLocationSelected;

  const MapScreen({Key? key, required this.onLocationSelected}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecionar Localização'),
      ),
      body: Center(
        child: _locationData == null
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Latitude: ${_locationData!.latitude}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Longitude: ${_locationData!.longitude}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_locationData != null) {
                  widget.onLocationSelected(
                    _locationData!.latitude!,
                    _locationData!.longitude!,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Salvar Localização'),
            ),
          ],
        ),
      ),
    );
  }
}
