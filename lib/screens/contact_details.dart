import 'package:flutter/material.dart';
import 'package:tpflutter/models/contact.dart';
import 'package:tpflutter/database_helper.dart';
import 'package:tpflutter/models/location.dart';
import 'package:tpflutter/shared_recent.dart';
import 'package:tpflutter/screens/edit_contact.dart';
import 'map_screen.dart';

class ContactDetailsScreen extends StatefulWidget {
  final Contact contact;
  final Function(Contact) onContactUpdated;

  const ContactDetailsScreen({Key? key, required this.contact, required this.onContactUpdated}) : super(key: key);

  @override
  _ContactDetailsScreenState createState() =>  _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  bool _expanded = false;
  late List<Location> _locations;

  @override
  void initState() {
    super.initState();
    _locations = widget.contact.locations;
  }

  Future<void> _deleteContact() async {
    await DatabaseHelper().deleteContact(widget.contact.id);
    Navigator.pop(context, true);
  }

  Future<void> _updateContact(Contact updatedContact) async {
    await DatabaseHelper().updateContact(updatedContact);

    setState(() {
      widget.contact.name = updatedContact.name;
      widget.contact.email = updatedContact.email;
      widget.contact.phone = updatedContact.phone;
      widget.contact.birthDate = updatedContact.birthDate;
      widget.contact.imagePath = updatedContact.imagePath;
      widget.contact.locations = updatedContact.locations;
    });

    widget.onContactUpdated(updatedContact);
  }

  Future<void> _addLocation() async {
    final location = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );

    if (location != null) {
      final newLocation = Location(
        latitude: location['latitude'],
        longitude: location['longitude'],
        timestamp: DateTime.now(),
      );

      await DatabaseHelper().insertLocation(newLocation, widget.contact.id);

      setState(() {
        widget.contact.locations.add(newLocation);
      });

      widget.onContactUpdated(widget.contact);

      final recentManager = RecentContactsManager();
      await recentManager.saveRecentContact(widget.contact);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Remover contato'),
                  content: Text('Tem certeza que deseja remover este contato?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Confirmar'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _deleteContact();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditContactScreen(
                    contact: widget.contact,
                    onUpdate: (updatedContact) async {
                      await _updateContact(updatedContact);
                      await RecentContactsManager().saveRecentContact(updatedContact);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${widget.contact.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Email: ${widget.contact.email}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Phone: ${widget.contact.phone}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            ExpansionTile(
              title: Text('Localizações', style: TextStyle(fontSize: 18)),
              leading: Icon(Icons.location_on),
              initiallyExpanded: _expanded,
              onExpansionChanged: (bool expanded) {
                setState(() {
                  _expanded = expanded;
                });
              },
              children: _locations.map((location) {
                return ListTile(
                  leading: Icon(Icons.pin_drop, color: Colors.red),
                  title: Text('Localização (${location.latitude}, ${location.longitude})'),
                  subtitle: Text('Timestamp: ${location.timestamp}'),
                );
              }).toList(),
            ),

            ElevatedButton(
              onPressed: _addLocation,
              child: Text('Adicionar Nova Localização'),
            ),
          ],
        ),
      ),
    );
  }
}
