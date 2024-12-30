import 'package:aulaflutter/screens/add_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:aulaflutter/screens/contact_details.dart';
import 'dart:io';

class ContactsListScreen extends StatefulWidget {
  @override
  _ContactsListScreenState createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  final List<Map<String, dynamic>> _contacts = [
    // Mock data for demonstration
    {'name': 'John Doe', 'email': 'john.doe@example.com', 'phone': '123456789'},
    {'name': 'Jane Smith', 'email': 'jane.smith@example.com', 'phone': '987654321'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddContactScreen(
                      onSave: (newContact) {
                        setState(() {
                          _contacts.add(newContact);
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: _contacts.isEmpty
          ? Center(child: Text('Nenhum contato adicionado'))
          : ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return ListTile(
            leading: contact['imagePath'] != null
                ? CircleAvatar(backgroundImage: FileImage(File(contact['imagePath'])))
                : CircleAvatar(child: Text(contact['name']![0])),
            title: Text(contact['name']),
            subtitle: Text(contact['email']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailsScreen(
                    contact: {
                      'name': contact['name'] ?? '',
                      'email': contact['email'] ?? '',
                      'phone': contact['phone'] ?? '',
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
