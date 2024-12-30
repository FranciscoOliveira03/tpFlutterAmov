import 'package:flutter/material.dart';
import 'map_screen.dart';

class ContactDetailsScreen extends StatefulWidget {
  final Map<String, String> contact;

  const ContactDetailsScreen({Key? key, required this.contact}) : super(key: key);

  @override
  _ContactDetailsScreenState createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  double? latitude;
  double? longitude;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact['name']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${widget.contact['name']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Email: ${widget.contact['email']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Phone: ${widget.contact['phone']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            latitude == null || longitude == null
                ? Text('Nenhuma localização associada')
                : Text(
              'Localização: ($latitude, $longitude)',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to the map screen where the user can select a location
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      onLocationSelected: (lat, lng) {
                        setState(() {
                          latitude = lat;
                          longitude = lng;
                        });
                      },
                    ),
                  ),
                );
              },
              child: Text('Selecionar Localização'),
            ),
          ],
        ),
      ),
    );
  }
}
